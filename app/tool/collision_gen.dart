// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_scene/src/importer/src/gltf/accessor.dart';
import 'package:flutter_scene/src/importer/src/gltf/draco/gltf_draco.dart';
import 'package:flutter_scene/src/importer/src/gltf/glb.dart';
import 'package:flutter_scene/src/importer/src/gltf/parser.dart';
import 'package:flutter_scene/src/importer/src/gltf/types.dart';
import 'package:vector_math/vector_math.dart';

const double kCellSize = 1.0;
const double kMinX = -860;
const double kMaxX = 773;
// GLB uses +Z south, runtime uses +Z north. Flip during rasterization so the
// grid matches the world-coordinate spot table.
const double kMinZ = -602;
const double kMaxZ = 701;
const double kPlayerRadius = 0.5;
const double kMaxPrimitiveDiagonal = 200.0;

final Set<String> _collisionMeshes = {
  'Buildings_建物パビリオン',
  'Facilities_都市設備',
};

void main(List<String> args) {
  final inputPath = args.isNotEmpty
      ? args.first
      : 'assets_src/models/merged_model_draco.glb';
  final outputPath = args.length > 1 ? args[1] : 'assets/collision.bin';

  final watch = Stopwatch()..start();
  final bytes = File(inputPath).readAsBytesSync();
  final glb = parseGlb(bytes);
  final doc = parseGltfJson(glb.json);

  final grid = CollisionGridBuilder(
    minX: kMinX,
    minZ: kMinZ,
    maxX: kMaxX,
    maxZ: kMaxZ,
    cellSize: kCellSize,
  );

  final nodeTransforms = _computeNodeTransforms(doc);

  for (int nodeIndex = 0; nodeIndex < doc.nodes.length; nodeIndex++) {
    final node = doc.nodes[nodeIndex];
    final meshIndex = node.mesh;
    if (meshIndex == null) continue;
    final mesh = doc.meshes[meshIndex];
    if (!_collisionMeshes.contains(mesh.name)) continue;

    final transform = nodeTransforms[nodeIndex];
    if (transform == null) continue;

    for (int pi = 0; pi < mesh.primitives.length; pi++) {
      final primitive = mesh.primitives[pi];
      // Skip the venue plate ( Buildings #0 ) and the full-site facility mesh
      // ( Facilities #209 ). Also skip East Gate (#282) and West Gate (#202)
      // structures so players can walk freely through the entrances.
      // Everything else with a diagonal over 200 m is also too large to be
      // a walkable-structure primitive.
      if (meshIndex == 1 && (pi == 0 || pi == 282 || pi == 202)) continue;
      if (meshIndex == 2 && pi == 209) continue;
      _rasterizePrimitive(
        doc,
        glb.binaryChunk,
        primitive,
        transform,
        grid,
        fullFootprint: meshIndex == 1,
      );
    }
    print('Processed ${mesh.name}: ${mesh.primitives.length} primitives');
  }

  final buffer = grid.build();
  File(outputPath).writeAsBytesSync(buffer);
  watch.stop();
  print(
    'Wrote $outputPath (${buffer.length} bytes) in '
    '${watch.elapsedMilliseconds} ms. '
    'Grid: ${grid.width}x${grid.height}, '
    'blocked cells: ${grid.blockedCount}',
  );
}

List<Matrix4?> _computeNodeTransforms(GltfDocument doc) {
  final transforms = List<Matrix4?>.filled(doc.nodes.length, null);

  Matrix4 nodeLocalTransform(GltfNode node) {
    if (node.matrix != null) return node.matrix!;
    final translation = node.translation ?? Vector3.zero();
    final rotation = node.rotation ?? Quaternion.identity();
    final scale = node.scale ?? Vector3(1, 1, 1);
    return Matrix4.compose(translation, rotation, scale);
  }

  void visit(int nodeIndex, Matrix4 parent) {
    final node = doc.nodes[nodeIndex];
    final local = nodeLocalTransform(node);
    final world = parent * local;
    transforms[nodeIndex] = world;
    for (final child in node.children) {
      visit(child, world);
    }
  }

  final rootSceneIndex = doc.scene ?? 0;
  final rootScene = doc.scenes[rootSceneIndex];
  for (final rootNode in rootScene.nodes) {
    visit(rootNode, Matrix4.identity());
  }

  return transforms;
}

void _rasterizePrimitive(
  GltfDocument doc,
  Uint8List bufferData,
  GltfMeshPrimitive primitive,
  Matrix4 transform,
  CollisionGridBuilder grid, {
  required bool fullFootprint,
}) {
  var accessors = doc.accessors;
  var bufferViews = doc.bufferViews;
  var data = bufferData;

  if (primitive.draco != null) {
    final resolved = decodeDracoPrimitive(
      primitive: primitive,
      accessors: accessors,
      bufferViews: bufferViews,
      bufferData: data,
    );
    accessors = resolved.accessors;
    bufferViews = resolved.bufferViews;
    data = resolved.bufferData;
  }

  final positionAccessorIndex = primitive.attributes['POSITION'];
  if (positionAccessorIndex == null) return;

  final positions = readAccessorAsFloat32(
    accessors[positionAccessorIndex],
    bufferViews,
    data,
  );

  List<int> indices;
  if (primitive.indices != null) {
    final rawIndices = readAccessorAsUint32(
      accessors[primitive.indices!],
      bufferViews,
      data,
    );
    indices = rawIndices.toList();
  } else {
    indices = List.generate(positions.length ~/ 3, (i) => i);
  }

  // Compute XZ bounds first to skip ground-plane-like primitives that span
  // the whole mesh area.
  double minX = double.infinity;
  double minZ = double.infinity;
  double maxX = double.negativeInfinity;
  double maxZ = double.negativeInfinity;
  final scratch = Vector3.zero();
  for (int i = 0; i < positions.length ~/ 3; i++) {
    _transformPoint(positions, i, transform, scratch);
    if (scratch.x < minX) minX = scratch.x;
    if (scratch.x > maxX) maxX = scratch.x;
    if (scratch.z < minZ) minZ = scratch.z;
    if (scratch.z > maxZ) maxZ = scratch.z;
  }
  final diagonal = sqrt((maxX - minX) * (maxX - minX) +
      (maxZ - minZ) * (maxZ - minZ));
  if (diagonal > kMaxPrimitiveDiagonal) {
    return;
  }

  final p0 = Vector3.zero();
  final p1 = Vector3.zero();
  final p2 = Vector3.zero();
  final edge0 = Vector3.zero();
  final edge1 = Vector3.zero();
  final normal = Vector3.zero();

  for (int i = 0; i < indices.length; i += 3) {
    if (i + 2 >= indices.length) break;
    final i0 = indices[i];
    final i1 = indices[i + 1];
    final i2 = indices[i + 2];

    _transformPoint(positions, i0, transform, p0);
    _transformPoint(positions, i1, transform, p1);
    _transformPoint(positions, i2, transform, p2);

    // For facilities we keep only wall-like bands to avoid blocking walkable
    // ground tiles. For buildings we paint the full footprint so interiors are
    // not hollow.
    if (!fullFootprint) {
      // Skip nearly-horizontal surfaces (floors, ceilings, ground tiles).
      edge0.setFrom(p1);
      edge0.sub(p0);
      edge1.setFrom(p2);
      edge1.sub(p0);
      normal.setFrom(edge0.cross(edge1));
      final len2 = normal.length2;
      if (len2 > 0) {
        final nyAbs = normal.y.abs();
        if (nyAbs * nyAbs > 0.81 * len2) {
          continue;
        }
      }
    }

    grid.rasterizeTriangle(p0.x, p0.z, p1.x, p1.z, p2.x, p2.z);
  }
}

void _transformPoint(
  Float32List positions,
  int index,
  Matrix4 transform,
  Vector3 out,
) {
  final x = positions[index * 3];
  final y = positions[index * 3 + 1];
  final z = positions[index * 3 + 2];
  final tx = transform.entry(0, 0) * x +
      transform.entry(0, 1) * y +
      transform.entry(0, 2) * z +
      transform.entry(0, 3);
  final ty = transform.entry(1, 0) * x +
      transform.entry(1, 1) * y +
      transform.entry(1, 2) * z +
      transform.entry(1, 3);
  final tz = transform.entry(2, 0) * x +
      transform.entry(2, 1) * y +
      transform.entry(2, 2) * z +
      transform.entry(2, 3);
  // Flip Z so the grid matches runtime world coordinates (+Z = north).
  out.setValues(tx, ty, -tz);
}

class CollisionGridBuilder {
  CollisionGridBuilder({
    required this.minX,
    required this.minZ,
    required this.maxX,
    required this.maxZ,
    required this.cellSize,
  }) {
    width = ((maxX - minX) / cellSize).ceil();
    height = ((maxZ - minZ) / cellSize).ceil();
    cells = Uint8List((width * height + 7) ~/ 8);
  }

  final double minX;
  final double minZ;
  final double maxX;
  final double maxZ;
  final double cellSize;
  late final int width;
  late final int height;
  late final Uint8List cells;
  int blockedCount = 0;

  void markBlocked(int gx, int gz) {
    if (gx < 0 || gx >= width || gz < 0 || gz >= height) return;
    final index = gz * width + gx;
    final byteIndex = index ~/ 8;
    final bitIndex = index % 8;
    final mask = 1 << bitIndex;
    if ((cells[byteIndex] & mask) == 0) {
      cells[byteIndex] |= mask;
      blockedCount++;
    }
  }

  void rasterizeTriangle(
    double x0,
    double z0,
    double x1,
    double z1,
    double x2,
    double z2,
  ) {
    final minTX = min(x0, min(x1, x2)) - kPlayerRadius;
    final maxTX = max(x0, max(x1, x2)) + kPlayerRadius;
    final minTZ = min(z0, min(z1, z2)) - kPlayerRadius;
    final maxTZ = max(z0, max(z1, z2)) + kPlayerRadius;

    final startGX = _worldToGridX(minTX);
    final endGX = _worldToGridX(maxTX);
    final startGZ = _worldToGridZ(minTZ);
    final endGZ = _worldToGridZ(maxTZ);

    for (int gz = startGZ; gz <= endGZ; gz++) {
      for (int gx = startGX; gx <= endGX; gx++) {
        final cx = minX + (gx + 0.5) * cellSize;
        final cz = minZ + (gz + 0.5) * cellSize;
        if (_pointInTriangle(cx, cz, x0, z0, x1, z1, x2, z2)) {
          markBlocked(gx, gz);
          continue;
        }
        if (_circleIntersectsTriangle(
          cx, cz, kPlayerRadius, x0, z0, x1, z1, x2, z2,
        )) {
          markBlocked(gx, gz);
        }
      }
    }
  }

  int _worldToGridX(double x) => ((x - minX) / cellSize).floor();
  int _worldToGridZ(double z) => ((z - minZ) / cellSize).floor();

  bool _pointInTriangle(
    double px,
    double pz,
    double x0,
    double z0,
    double x1,
    double z1,
    double x2,
    double z2,
  ) {
    final dX = px - x0;
    final dZ = pz - z0;
    final dX10 = x1 - x0;
    final dZ10 = z1 - z0;
    final dX20 = x2 - x0;
    final dZ20 = z2 - z0;

    final dot00 = dX20 * dX20 + dZ20 * dZ20;
    final dot01 = dX20 * dX10 + dZ20 * dZ10;
    final dot02 = dX20 * dX + dZ20 * dZ;
    final dot11 = dX10 * dX10 + dZ10 * dZ10;
    final dot12 = dX10 * dX + dZ10 * dZ;

    final invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    final u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    final v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return u >= 0 && v >= 0 && u + v <= 1;
  }

  bool _circleIntersectsTriangle(
    double cx,
    double cz,
    double r,
    double x0,
    double z0,
    double x1,
    double z1,
    double x2,
    double z2,
  ) {
    if (_pointNearSegment(cx, cz, r, x0, z0, x1, z1)) return true;
    if (_pointNearSegment(cx, cz, r, x1, z1, x2, z2)) return true;
    if (_pointNearSegment(cx, cz, r, x2, z2, x0, z0)) return true;
    return false;
  }

  bool _pointNearSegment(
    double px,
    double pz,
    double r,
    double x0,
    double z0,
    double x1,
    double z1,
  ) {
    final dx = x1 - x0;
    final dz = z1 - z0;
    final len2 = dx * dx + dz * dz;
    if (len2 == 0) {
      final dpx = px - x0;
      final dpz = pz - z0;
      return dpx * dpx + dpz * dpz <= r * r;
    }
    var t = ((px - x0) * dx + (pz - z0) * dz) / len2;
    t = t.clamp(0.0, 1.0);
    final nearestX = x0 + t * dx;
    final nearestZ = z0 + t * dz;
    final dpx = px - nearestX;
    final dpz = pz - nearestZ;
    return dpx * dpx + dpz * dpz <= r * r;
  }

  Uint8List build() {
    final header = ByteData(24);
    header.setFloat64(0, minX, Endian.little);
    header.setFloat64(8, minZ, Endian.little);
    header.setUint32(16, width, Endian.little);
    header.setUint32(20, height, Endian.little);
    final out = BytesBuilder(copy: false);
    out.add(Uint8List.view(header.buffer, 0, 24));
    out.add(cells);
    return out.toBytes();
  }
}
