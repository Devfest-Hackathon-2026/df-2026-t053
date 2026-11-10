// 会場GLBを区画（タイル）に分割し、近景用の高精細モデルと遠景用の簡略モデル、
// 区画範囲のmanifestを生成する。手順と既定値は README.md を参照する。
//
//   npm run generate            # 既定値で app/assets/models/tiles を作り直す
//   node generate.mjs --help    # オプション一覧
import { createHash } from 'node:crypto';
import { mkdir, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { NodeIO } from '@gltf-transform/core';
import { ALL_EXTENSIONS, KHRDracoMeshCompression } from '@gltf-transform/extensions';
import {
  cloneDocument,
  compactPrimitive,
  prune,
  textureCompress,
} from '@gltf-transform/functions';
import draco3d from 'draco3dgltf';
import sharp from 'sharp';

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const appDir = path.resolve(toolDir, '../..');

/** 生成の既定値。値を変えたら README.md の記録も更新する。 */
export const DEFAULTS = Object.freeze({
  source: path.join(appDir, 'assets_src/models/merged_model_draco.glb'),
  out: path.join(appDir, 'assets/models/tiles'),
  // アプリのloadSceneへ渡す、パッケージルートからの出力ディレクトリ。
  assetPrefix: 'assets/models/tiles',
  tileSize: 200,
  // 遠景の頂点クラスタリングの格子（m）。誤差は格子の対角（約0.87m）以下で、
  // 高精細距離200mの境界では最大約4.5px（縦画角60°・縦1080px）。
  coarseCell: 0.5,
  coarseTextureSize: 64,
  detailPositionBits: 16,
  coarsePositionBits: 14,
});

const MANIFEST_VERSION = 1;

/**
 * GLBの座標を、アプリ（flutter_scene）の座標へ変換する。
 * flutter_sceneのビルド時変換（GltfCoordinatePolicy.bakeNative）はZを反転する。
 */
export function toRuntimeXZ(x, z) {
  return { x, z: -z };
}

/** ランタイム座標の水平位置が属する区画の添字。 */
export function tileIndexOf(x, z, tileSize) {
  const runtime = toRuntimeXZ(x, z);
  return {
    ix: Math.floor(runtime.x / tileSize),
    iz: Math.floor(runtime.z / tileSize),
  };
}

export function tileId(ix, iz) {
  return `x${ix}_z${iz}`;
}

function parseArgs(argv) {
  const options = { ...DEFAULTS };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--help') {
      options.help = true;
      continue;
    }
    const match = /^--([a-z-]+)$/.exec(arg);
    if (!match || i + 1 >= argv.length) {
      throw new Error(`不明な引数です: ${arg}`);
    }
    const key = match[1].replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    if (!(key in DEFAULTS)) {
      throw new Error(`不明なオプションです: ${arg}`);
    }
    const value = argv[++i];
    options[key] = typeof DEFAULTS[key] === 'number' ? Number(value) : value;
    if (typeof DEFAULTS[key] === 'number' && !Number.isFinite(options[key])) {
      throw new Error(`${arg} には数値を指定してください: ${value}`);
    }
  }
  return options;
}

export async function createIO() {
  return new NodeIO()
    .registerExtensions(ALL_EXTENSIONS)
    .registerDependencies({
      'draco3d.decoder': await draco3d.createDecoderModule(),
      'draco3d.encoder': await draco3d.createEncoderModule(),
    });
}

/** 単位行列でないノードがあれば中止する。頂点をワールド座標として扱うため。 */
function assertIdentityTransforms(document) {
  for (const node of document.getRoot().listNodes()) {
    const matrix = node.getMatrix();
    const identity = matrix.every((v, i) => Math.abs(v - (i % 5 === 0 ? 1 : 0)) < 1e-9);
    if (!identity) {
      throw new Error(`ノード ${node.getName()} に変換行列があります。区画分割の前に平坦化してください。`);
    }
  }
}

export function triangleCount(document) {
  let total = 0;
  for (const mesh of document.getRoot().listMeshes()) {
    for (const prim of mesh.listPrimitives()) {
      const indices = prim.getIndices();
      total += (indices ? indices.getCount() : prim.getAttribute('POSITION').getCount()) / 3;
    }
  }
  return total;
}

/**
 * 各プリミティブの三角形を区画に振り分ける。
 *
 * 水平の大きさが区画以下のプリミティブ（建物1棟など）は、範囲の中心の区画へ
 * 丸ごと入れる。区画をまたいで分けると、同じテクスチャが区画ごとに複製され、
 * 同梱容量とGPUメモリが増えるため。区画より大きいもの（大屋根リング・地面など）
 * だけ、三角形の重心で区画に分ける。三角形は切断しない。
 *
 * 2頂点が同じ位置にある面積ゼロの三角形は描画されず、Draco圧縮でも除かれるため、
 * ここで除いて件数を返す。区画の合計は「加工元 − 面積ゼロ」と一致する。
 */
export function assignTriangles(document, tileSize) {
  const tiles = new Map();
  let degenerate = 0;
  const meshes = document.getRoot().listMeshes();
  meshes.forEach((mesh, meshIndex) => {
    mesh.listPrimitives().forEach((prim, primIndex) => {
      if (prim.getMode() !== 4) {
        throw new Error(`三角形以外のプリミティブは未対応です: ${mesh.getName()}#${primIndex}`);
      }
      const position = prim.getAttribute('POSITION');
      const indices = prim.getIndices();
      const count = indices ? indices.getCount() : position.getCount();
      const min = position.getMin([]);
      const max = position.getMax([]);
      const whole = Math.max(max[0] - min[0], max[2] - min[2]) <= tileSize;
      const center = tileIndexOf((min[0] + max[0]) / 2, (min[2] + max[2]) / 2, tileSize);
      const a = [0, 0, 0];
      const b = [0, 0, 0];
      const c = [0, 0, 0];
      const byTile = new Map();
      for (let t = 0; t < count; t += 3) {
        const i0 = indices ? indices.getScalar(t) : t;
        const i1 = indices ? indices.getScalar(t + 1) : t + 1;
        const i2 = indices ? indices.getScalar(t + 2) : t + 2;
        position.getElement(i0, a);
        position.getElement(i1, b);
        position.getElement(i2, c);
        if (samePosition(a, b) || samePosition(b, c) || samePosition(a, c)) {
          degenerate++;
          continue;
        }
        let ix = center.ix;
        let iz = center.iz;
        if (!whole) {
          ({ ix, iz } = tileIndexOf((a[0] + b[0] + c[0]) / 3, (a[2] + b[2] + c[2]) / 3, tileSize));
        }
        const id = tileId(ix, iz);
        let list = byTile.get(id);
        if (!list) {
          list = [];
          byTile.set(id, list);
          if (!tiles.has(id)) {
            tiles.set(id, { id, ix, iz, primitives: new Map() });
          }
        }
        list.push(i0, i1, i2);
      }
      for (const [id, list] of byTile) {
        tiles.get(id).primitives.set(`${meshIndex}:${primIndex}`, Uint32Array.from(list));
      }
    });
  });
  return {
    tiles: [...tiles.values()].sort((l, r) => l.iz - r.iz || l.ix - r.ix),
    degenerate,
  };
}

function samePosition(p, q) {
  return p[0] === q[0] && p[1] === q[1] && p[2] === q[2];
}

/** 加工元を複製し、区画に属する三角形だけを残した文書を作る。 */
export async function buildDetailDocument(source, tile) {
  const document = cloneDocument(source);
  const root = document.getRoot();
  root.listMeshes().forEach((mesh, meshIndex) => {
    mesh.listPrimitives().forEach((prim, primIndex) => {
      const list = tile.primitives.get(`${meshIndex}:${primIndex}`);
      if (!list) {
        mesh.removePrimitive(prim);
        prim.dispose();
        return;
      }
      const indices = document
        .createAccessor()
        .setType('SCALAR')
        .setArray(list)
        .setBuffer(root.listBuffers()[0]);
      prim.setIndices(indices);
      compactPrimitive(prim);
    });
  });
  for (const node of root.listNodes()) {
    const mesh = node.getMesh();
    if (mesh && mesh.listPrimitives().length === 0) {
      node.setMesh(null);
    }
  }
  await document.transform(prune({ keepLeaves: false }));
  return document;
}

/**
 * 頂点クラスタリングで三角形を間引く。
 *
 * 会場全体で共通の格子（一辺 [cell] m）に頂点を寄せ、同じ格子の頂点を最初の
 * 頂点（属性ごと）で代表させる。潰れた三角形と重複した三角形は除く。
 * 大屋根リングは非多様体の格子材で、位相を保つ簡略化（meshoptimizer）では
 * ほとんど減らないため、位相に依存しないこの方式を使う。誤差は格子の対角以下。
 *
 * [normals]を渡すと、法線の主軸の向き（±X・±Y・±Z）が違う頂点は同じ格子でも
 * 別に代表させる。箱の角で別の面の法線を引き継ぎ、陰影が崩れるのを防ぐ。
 */
export function clusterTriangles(indices, positions, cell, normals = null) {
  const representative = new Map();
  const remap = new Uint32Array(positions.length / 3);
  for (let v = 0; v < remap.length; v++) {
    let key =
      `${Math.floor(positions[v * 3] / cell)},` +
      `${Math.floor(positions[v * 3 + 1] / cell)},` +
      `${Math.floor(positions[v * 3 + 2] / cell)}`;
    if (normals) {
      key += `|${dominantAxis(normals[v * 3], normals[v * 3 + 1], normals[v * 3 + 2])}`;
    }
    let first = representative.get(key);
    if (first === undefined) {
      first = v;
      representative.set(key, v);
    }
    remap[v] = first;
  }
  const seen = new Set();
  const result = [];
  for (let t = 0; t < indices.length; t += 3) {
    const a = remap[indices[t]];
    const b = remap[indices[t + 1]];
    const c = remap[indices[t + 2]];
    if (a === b || b === c || a === c) {
      continue;
    }
    const key = [a, b, c].sort((l, r) => l - r).join(',');
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    result.push(a, b, c);
  }
  return Uint32Array.from(result);
}

/** 法線の主軸の向き。0〜5（+X, −X, +Y, −Y, +Z, −Z）。 */
export function dominantAxis(x, y, z) {
  const ax = Math.abs(x);
  const ay = Math.abs(y);
  const az = Math.abs(z);
  if (ax >= ay && ax >= az) return x >= 0 ? 0 : 1;
  if (ay >= az) return y >= 0 ? 2 : 3;
  return z >= 0 ? 4 : 5;
}

/** 1つのプリミティブを頂点クラスタリングで簡略化する。空になればfalse。 */
function simplifyCoarsePrimitive(document, prim, options) {
  const position = prim.getAttribute('POSITION');
  const positions = new Float32Array(position.getCount() * 3);
  const v = [0, 0, 0];
  for (let i = 0; i < position.getCount(); i++) {
    position.getElement(i, v);
    positions.set(v, i * 3);
  }
  const normal = prim.getAttribute('NORMAL');
  let normals = null;
  if (normal) {
    normals = new Float32Array(normal.getCount() * 3);
    for (let i = 0; i < normal.getCount(); i++) {
      normal.getElement(i, v);
      normals.set(v, i * 3);
    }
  }
  const source = prim.getIndices();
  const simplified = clusterTriangles(source.getArray(), positions, options.coarseCell, normals);
  if (simplified.length === 0) {
    return false;
  }
  prim.setIndices(document.createAccessor().setType('SCALAR').setArray(simplified).setBuffer(source.getBuffer()));
  compactPrimitive(prim);
  return true;
}

/** 高精細の区画から、遠景用に形状とテクスチャを簡略化した文書を作る。 */
export async function buildCoarseDocument(detail, options) {
  const document = cloneDocument(detail);
  for (const mesh of document.getRoot().listMeshes()) {
    for (const prim of mesh.listPrimitives()) {
      if (!simplifyCoarsePrimitive(document, prim, options)) {
        mesh.removePrimitive(prim);
        prim.dispose();
      }
    }
  }
  for (const node of document.getRoot().listNodes()) {
    const mesh = node.getMesh();
    if (mesh && mesh.listPrimitives().length === 0) {
      node.setMesh(null);
    }
  }
  await document.transform(
    prune({ keepLeaves: false }),
    textureCompress({
      encoder: sharp,
      targetFormat: 'jpeg',
      resize: [options.coarseTextureSize, options.coarseTextureSize],
      quality: 70,
    }),
  );
  return document;
}

/** 区画のランタイム座標の範囲（m）。三角形は切断しないため区画の格子より広がり得る。 */
export function runtimeBounds(document) {
  const min = [Infinity, Infinity, Infinity];
  const max = [-Infinity, -Infinity, -Infinity];
  const v = [0, 0, 0];
  for (const mesh of document.getRoot().listMeshes()) {
    for (const prim of mesh.listPrimitives()) {
      const position = prim.getAttribute('POSITION');
      for (let i = 0; i < position.getCount(); i++) {
        position.getElement(i, v);
        const runtime = toRuntimeXZ(v[0], v[2]);
        const p = [runtime.x, v[1], runtime.z];
        for (let k = 0; k < 3; k++) {
          if (p[k] < min[k]) min[k] = p[k];
          if (p[k] > max[k]) max[k] = p[k];
        }
      }
    }
  }
  return { min, max };
}

async function writeCompressed(io, document, filePath, positionBits) {
  document
    .createExtension(KHRDracoMeshCompression)
    .setRequired(true)
    .setEncoderOptions({
      method: KHRDracoMeshCompression.EncoderMethod.EDGEBREAKER,
      quantizationBits: {
        POSITION: positionBits,
        NORMAL: 10,
        TEXCOORD: 12,
      },
    });
  await mkdir(path.dirname(filePath), { recursive: true });
  await io.write(filePath, document);
  return (await stat(filePath)).size;
}

function round(value, digits = 2) {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

export async function generate(options = DEFAULTS, log = console.log) {
  const io = await createIO();
  const source = await io.read(options.source);
  assertIdentityTransforms(source);
  const sourceTriangles = triangleCount(source);
  const { tiles, degenerate } = assignTriangles(source, options.tileSize);
  log(
    `加工元: ${path.relative(appDir, options.source)} 三角形 ${sourceTriangles}` +
      `（面積ゼロ ${degenerate} を除外）→ 区画 ${tiles.length}`,
  );

  await rm(options.out, { recursive: true, force: true });
  const entries = [];
  for (const tile of tiles) {
    const detail = await buildDetailDocument(source, tile);
    const coarse = await buildCoarseDocument(detail, options);
    const bounds = runtimeBounds(detail);
    const detailTriangles = triangleCount(detail);
    const coarseTriangles = triangleCount(coarse);
    const detailFile = `detail/${tile.id}.glb`;
    const coarseFile = `coarse/${tile.id}.glb`;
    const detailBytes = await writeCompressed(io, detail, path.join(options.out, detailFile), options.detailPositionBits);
    const coarseBytes = await writeCompressed(io, coarse, path.join(options.out, coarseFile), options.coarsePositionBits);
    entries.push({
      id: tile.id,
      minX: round(bounds.min[0]),
      maxX: round(bounds.max[0]),
      minY: round(bounds.min[1]),
      maxY: round(bounds.max[1]),
      minZ: round(bounds.min[2]),
      maxZ: round(bounds.max[2]),
      detailPath: `${options.assetPrefix}/${detailFile}`,
      coarsePath: `${options.assetPrefix}/${coarseFile}`,
      detailTriangles,
      coarseTriangles,
      detailBytes,
      coarseBytes,
    });
    log(
      `${tile.id}: 三角形 ${detailTriangles} → ${coarseTriangles} ` +
        `容量 ${(detailBytes / 1024).toFixed(0)} KiB / ${(coarseBytes / 1024).toFixed(0)} KiB`,
    );
  }

  const manifest = {
    version: MANIFEST_VERSION,
    source: path.basename(options.source),
    // 加工元と生成物の対応をアプリのテストで照合するため、加工元のハッシュを残す。
    sourceSha256: createHash('sha256').update(await readFile(options.source)).digest('hex'),
    sourceTriangles,
    degenerateTriangles: degenerate,
    tileSizeMeters: options.tileSize,
    coarseCell: options.coarseCell,
    coarseTextureSize: options.coarseTextureSize,
    tiles: entries,
  };
  await writeFile(path.join(options.out, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);

  const sum = (key) => entries.reduce((total, entry) => total + entry[key], 0);
  log(
    `合計: 高精細 三角形 ${sum('detailTriangles')} 容量 ${(sum('detailBytes') / 1048576).toFixed(2)} MiB / ` +
      `簡略 三角形 ${sum('coarseTriangles')} 容量 ${(sum('coarseBytes') / 1048576).toFixed(2)} MiB`,
  );
  if (sum('detailTriangles') !== sourceTriangles - degenerate) {
    throw new Error(
      `高精細区画の三角形数 ${sum('detailTriangles')} が加工元 ${sourceTriangles} − 面積ゼロ ${degenerate} と一致しません。`,
    );
  }
  return manifest;
}

/** 出力ディレクトリにmanifest外のファイルが残っていないか確認する。 */
export async function listOutputFiles(out) {
  const files = [];
  for (const dir of ['detail', 'coarse']) {
    for (const name of await readdir(path.join(out, dir))) {
      files.push(`${dir}/${name}`);
    }
  }
  return files.sort();
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log('使い方: node generate.mjs [--tile-size m] [--coarse-cell m]');
    console.log('                        [--coarse-texture-size px] [--source glb] [--out dir]');
    console.log('既定値:', DEFAULTS);
  } else {
    await generate(options);
  }
}
