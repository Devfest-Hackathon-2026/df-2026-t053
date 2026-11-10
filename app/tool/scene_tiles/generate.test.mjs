// 加工コマンドの単体テストと、生成済み区画の検査。
//   npm test   （先に npm run generate で区画を生成しておく）
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { test } from 'node:test';

import { getBounds } from '@gltf-transform/core';

import {
  DEFAULTS,
  clusterTriangles,
  createIO,
  dominantAxis,
  listOutputFiles,
  tileIndexOf,
  toRuntimeXZ,
  triangleCount,
} from './generate.mjs';

test('GLBのZをアプリの座標へ反転し、区画の添字を求める', () => {
  assert.deepEqual(toRuntimeXZ(10, 20), { x: 10, z: -20 });
  assert.deepEqual(tileIndexOf(250, -10, 200), { ix: 1, iz: 0 });
  assert.deepEqual(tileIndexOf(-1, 1, 200), { ix: -1, iz: -1 });
});

test('頂点クラスタリングは潰れた三角形と重複を除き、大きい三角形を残す', () => {
  const positions = Float32Array.from([
    0, 0, 0, // 0
    0.1, 0, 0, // 1: 0と同じ格子
    10, 0, 0, // 2
    0, 0, 10, // 3
  ]);
  const indices = Uint32Array.from([
    0, 2, 3, // 残る
    1, 2, 3, // 0へ寄せると上と重複
    0, 1, 2, // 潰れる
  ]);
  assert.deepEqual([...clusterTriangles(indices, positions, 0.5)], [0, 2, 3]);
});

test('法線の主軸の向きが違う頂点は、同じ格子でも別に代表させる', () => {
  const positions = Float32Array.from([
    0, 0, 0, // 0: 上向き
    0.1, 0, 0, // 1: 0と同じ格子だが横向き
    10, 0, 0, // 2
    0, 0, 10, // 3
  ]);
  const normals = Float32Array.from([0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0]);
  const indices = Uint32Array.from([0, 2, 3, 1, 2, 3]);
  // 法線を見なければ1は0へ寄って重複として消えるが、向きが違うので残す。
  assert.deepEqual([...clusterTriangles(indices, positions, 0.5)], [0, 2, 3]);
  assert.deepEqual([...clusterTriangles(indices, positions, 0.5, normals)], [0, 2, 3, 1, 2, 3]);
  assert.equal(dominantAxis(0.2, -0.9, 0.1), 3);
});

test('manifestに加工元のハッシュを記録する', async () => {
  const manifest = await readManifest();
  const expected = createHash('sha256').update(await readFile(DEFAULTS.source)).digest('hex');
  assert.equal(manifest.sourceSha256, expected);
});

async function readManifest() {
  return JSON.parse(await readFile(path.join(DEFAULTS.out, 'manifest.json'), 'utf8'));
}

/** 材質ごとの、面積ゼロでない三角形の数。 */
function materialTriangles(document) {
  const counts = new Map();
  const a = [0, 0, 0];
  const b = [0, 0, 0];
  const c = [0, 0, 0];
  const same = (p, q) => p[0] === q[0] && p[1] === q[1] && p[2] === q[2];
  for (const mesh of document.getRoot().listMeshes()) {
    for (const prim of mesh.listPrimitives()) {
      const name = prim.getMaterial()?.getName() ?? '(none)';
      const indices = prim.getIndices().getArray();
      const position = prim.getAttribute('POSITION');
      let visible = 0;
      for (let t = 0; t < indices.length; t += 3) {
        position.getElement(indices[t], a);
        position.getElement(indices[t + 1], b);
        position.getElement(indices[t + 2], c);
        if (!same(a, b) && !same(b, c) && !same(a, c)) visible++;
      }
      counts.set(name, (counts.get(name) ?? 0) + visible);
    }
  }
  return counts;
}

test('生成済みの区画は加工元の三角形・材質・範囲を保つ', async () => {
  const io = await createIO();
  const manifest = await readManifest();
  const source = await io.read(DEFAULTS.source);
  const sourceMaterials = materialTriangles(source);
  const sourceBounds = getBounds(source.getRoot().listScenes()[0]);

  assert.equal(manifest.sourceTriangles, triangleCount(source));
  const detailMaterials = new Map();
  const min = [Infinity, Infinity, Infinity];
  const max = [-Infinity, -Infinity, -Infinity];
  let detailTotal = 0;
  for (const tile of manifest.tiles) {
    const detail = await io.read(path.join(DEFAULTS.out, '..', '..', '..', tile.detailPath));
    const coarse = await io.read(path.join(DEFAULTS.out, '..', '..', '..', tile.coarsePath));
    assert.equal(triangleCount(detail), tile.detailTriangles, tile.id);
    assert.equal(triangleCount(coarse), tile.coarseTriangles, tile.id);
    assert.ok(tile.coarseTriangles <= tile.detailTriangles, tile.id);
    detailTotal += tile.detailTriangles;
    for (const [name, count] of materialTriangles(detail)) {
      detailMaterials.set(name, (detailMaterials.get(name) ?? 0) + count);
    }
    const bounds = getBounds(detail.getRoot().listScenes()[0]);
    for (let k = 0; k < 3; k++) {
      min[k] = Math.min(min[k], bounds.min[k]);
      max[k] = Math.max(max[k], bounds.max[k]);
    }
  }

  assert.equal(detailTotal, manifest.sourceTriangles - manifest.degenerateTriangles);
  // 材質ごとの三角形数（面積ゼロを除く）が一致すれば、材質の欠落や付け替えはない。
  assert.deepEqual(new Map([...detailMaterials].sort()), new Map([...sourceMaterials].sort()));
  // 原点・軸・尺度を保つ。差はDracoの量子化（16bit）の範囲に収まる。
  for (let k = 0; k < 3; k++) {
    assert.ok(Math.abs(min[k] - sourceBounds.min[k]) < 0.05, `min[${k}] ${min[k]} ${sourceBounds.min[k]}`);
    assert.ok(Math.abs(max[k] - sourceBounds.max[k]) < 0.05, `max[${k}] ${max[k]} ${sourceBounds.max[k]}`);
  }
});

test('manifestに載っていない区画ファイルが残っていない', async () => {
  const manifest = await readManifest();
  const expected = manifest.tiles
    .flatMap((tile) => [tile.detailPath, tile.coarsePath])
    .map((p) => p.slice(`${DEFAULTS.assetPrefix}/`.length))
    .sort();
  assert.deepEqual(await listOutputFiles(DEFAULTS.out), expected);
});
