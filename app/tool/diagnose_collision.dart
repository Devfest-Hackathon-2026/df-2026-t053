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

const Set<String> _targetMeshes = {
  'Buildings_建物パビリオン',
  'Facilities_都市設備',
  'GrandRoofRing_大屋根リング',
};

void main() {
  final bytes = File('assets_src/models/merged_model_draco.glb').readAsBytesSync();
  final glb = parseGlb(bytes);
  final doc = parseGltfJson(glb.json);

  final nodeTransforms = _computeNodeTransforms(doc);

  for (int nodeIndex = 0; nodeIndex < doc.nodes.length; nodeIndex++) {
    final node = doc.nodes[nodeIndex];
    final meshIndex = node.mesh;
    if (meshIndex == null) continue;
    final mesh = doc.meshes[meshIndex];
    if (!_targetMeshes.contains(mesh.name)) continue;

    final transform = nodeTransforms[nodeIndex];
    print('\n=== ${mesh.name} (node $nodeIndex) ===');
    print('Transform: $transform');

    double minX = double.infinity, minY = double.infinity, minZ = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity, maxZ = double.negativeInfinity;
    int totalTriangles = 0;

    for (int pi = 0; pi < mesh.primitives.length; pi++) {
      final primitive = mesh.primitives[pi];
      final result = _decodePrimitive(doc, glb.binaryChunk, primitive);
      if (result == null) continue;

      final positions = result.positions;
      final indices = result.indices;
      totalTriangles += indices.length ~/ 3;

      double pminX = double.infinity, pminY = double.infinity, pminZ = double.infinity;
      double pmaxX = double.negativeInfinity, pmaxY = double.negativeInfinity, pmaxZ = double.negativeInfinity;

      for (int i = 0; i < indices.length; i += 3) {
        if (i + 2 >= indices.length) break;
        final p0 = _transformPoint(positions, indices[i], transform);
        final p1 = _transformPoint(positions, indices[i + 1], transform);
        final p2 = _transformPoint(positions, indices[i + 2], transform);
        for (final p in [p0, p1, p2]) {
          minX = min(minX, p.x); maxX = max(maxX, p.x);
          minY = min(minY, p.y); maxY = max(maxY, p.y);
          minZ = min(minZ, p.z); maxZ = max(maxZ, p.z);
          pminX = min(pminX, p.x); pmaxX = max(pmaxX, p.x);
          pminY = min(pminY, p.y); pmaxY = max(pmaxY, p.y);
          pminZ = min(pminZ, p.z); pmaxZ = max(pmaxZ, p.z);
        }
      }

      final dx = pmaxX - pminX;
      final dz = pmaxZ - pminZ;
      final diagonal = sqrt(dx * dx + dz * dz);
      if (diagonal > 50 || dx < 0.1 && dz < 0.1) {
        print('Primitive $pi: ${indices.length ~/ 3} tris, X[$pminX, $pmaxX] Y[$pminY, $pmaxY] Z[$pminZ, $pmaxZ]');
      }
    }

    print('Total triangles: $totalTriangles');
    print('Bounds: X[$minX, $maxX] Y[$minY, $maxY] Z[$minZ, $maxZ]');
  }
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

({Float32List positions, List<int> indices})? _decodePrimitive(
  GltfDocument doc,
  Uint8List bufferData,
  GltfMeshPrimitive primitive,
) {
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
  if (positionAccessorIndex == null) return null;

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

  return (positions: positions, indices: indices);
}

Vector3 _transformPoint(Float32List positions, int index, Matrix4? transform) {
  final x = positions[index * 3];
  final y = positions[index * 3 + 1];
  final z = positions[index * 3 + 2];
  if (transform == null) return Vector3(x, y, z);
  final t = transform.transform3(Vector3(x, y, z));
  return t;
}
