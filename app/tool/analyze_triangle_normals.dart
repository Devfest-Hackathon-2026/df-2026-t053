// ignore_for_file: avoid_print

import 'dart:io';
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
};

void main() {
  final bytes = File('assets_src/models/merged_model_draco.glb').readAsBytesSync();
  final glb = parseGlb(bytes);
  final doc = parseGltfJson(glb.json);
  final transforms = _computeNodeTransforms(doc);

  int horizontalTris = 0;
  int verticalTris = 0;
  int otherTris = 0;
  int totalTris = 0;

  for (int nodeIndex = 0; nodeIndex < doc.nodes.length; nodeIndex++) {
    final node = doc.nodes[nodeIndex];
    final meshIndex = node.mesh;
    if (meshIndex == null) continue;
    final mesh = doc.meshes[meshIndex];
    if (!_targetMeshes.contains(mesh.name)) continue;

    final transform = transforms[nodeIndex];

    for (final primitive in mesh.primitives) {
      final result = _decodePrimitive(doc, glb.binaryChunk, primitive);
      if (result == null) continue;

      final positions = result.positions;
      final indices = result.indices;

      for (int i = 0; i < indices.length; i += 3) {
        if (i + 2 >= indices.length) break;
        final p0 = _transformPoint(positions, indices[i], transform);
        final p1 = _transformPoint(positions, indices[i + 1], transform);
        final p2 = _transformPoint(positions, indices[i + 2], transform);

        final v0 = p1 - p0;
        final v1 = p2 - p0;
        final normal = v0.cross(v1);
        final len = normal.length;
        if (len == 0) continue;
        normal.scale(1 / len);

        totalTris++;
        final nyAbs = normal.y.abs();
        if (nyAbs > 0.9) {
          horizontalTris++;
        } else if (nyAbs < 0.1) {
          verticalTris++;
        } else {
          otherTris++;
        }
      }
    }
  }

  print('Total triangles: $totalTris');
  print('Horizontal (floor/ceiling, |Ny|>0.9): $horizontalTris '
      '(${horizontalTris / totalTris * 100}%)');
  print('Vertical (walls, |Ny|<0.1): $verticalTris '
      '(${verticalTris / totalTris * 100}%)');
  print('Other slopes: $otherTris (${otherTris / totalTris * 100}%)');
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
  return transform.transform3(Vector3(x, y, z));
}
