#!/usr/bin/env python3
"""
国土地理院の標準地図タイルを取得して夢洲周辺の地図画像を作成
"""

import math
import os
import requests
from PIL import Image
from io import BytesIO

# 夢洲の範囲
NW_LAT = 34.656621
NW_LON = 135.372784
SE_LAT = 34.6459241
SE_LON = 135.3889618

ZOOM = 18
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "yumeshima_map.png")

# 国土地理院 標準地図
TILE_URL = "https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png"


def latlon_to_tile(lat, lon, zoom):
    n = 2.0 ** zoom
    x = int((lon + 180.0) / 360.0 * n)
    lat_rad = math.radians(lat)
    y = int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    return x, y


def download_tile(x, y, zoom, session):
    url = TILE_URL.format(z=zoom, x=x, y=y)
    resp = session.get(url, timeout=10)
    resp.raise_for_status()
    return Image.open(BytesIO(resp.content))


def main():
    x_min, y_min = latlon_to_tile(NW_LAT, NW_LON, ZOOM)
    x_max, y_max = latlon_to_tile(SE_LAT, SE_LON, ZOOM)

    tile_size = 256
    width = (x_max - x_min + 1) * tile_size
    height = (y_max - y_min + 1) * tile_size
    result = Image.new("RGB", (width, height))

    session = requests.Session()
    count = 0
    total = (x_max - x_min + 1) * (y_max - y_min + 1)

    for x in range(x_min, x_max + 1):
        for y in range(y_min, y_max + 1):
            result.paste(download_tile(x, y, ZOOM, session), ((x - x_min) * tile_size, (y - y_min) * tile_size))
            count += 1
            print(f"\r{count}/{total}", end="")

    print()
    result.save(OUTPUT_FILE)
    print(f"保存: {OUTPUT_FILE} ({width}x{height}px)")


if __name__ == "__main__":
    main()
