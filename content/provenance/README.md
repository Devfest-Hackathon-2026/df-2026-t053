# 出典・許諾・座標照合の記録

`content/seeds/` に置いた出題・施設・素材ごとに、取得元・取得日・利用条件・許諾状況と、
会場図・3D・地理座標の照合結果を残す（docs/specs.md「施設seedと座標照合」）。

| 対象 | 取得元 | 取得日 | 利用条件・許諾 | 座標照合 |
| --- | --- | --- | --- | --- |
| `seeds/pavilions.yaml`（実データ96件） | [expo2025_project_api](https://github.com/penguins-osaka/expo2025_project_api)（ゆめしまっぷAPI）の `src/data/pavilions/`（main f90cd23） | 2026-11-10 | 同一組織の自作データ。`src/data/restaurant/` は対象外。英国パビリオン（sv09）は `uk-pavilion` と重複するため未登録 | 座標系は緯度経度で一致。取得元の lat / lon をそのまま登録（変換なし）。件数・一意性・座標範囲を検証済み |
| `seeds/uk-pavilion/r1` の写真 | チームメンバーが撮影（2025-07-24 11:51、Xperia の超広角） | 2026-11-10 | 撮影者本人の提供。2000×1500 に縮小し、EXIF・XMP を除いた | 下記「英国パビリオンの照合」 |
| `seeds/uk-pavilion/r1` の会場図 | 同梱モデルの当たり判定（`app/assets/collision.bin`）と建物の外形から作成 | 2026-11-10 | 3D都市モデル（Project PLATEAU）の加工物 | 1 m = 8 px、行は Z が増える向き（北が下） |
| `seeds/uk-pavilion/r2` の会場図 | 同梱モデルの当たり判定（`app/assets/collision.bin`）から、建物の周囲約 80 m を塗って作成 | 2026-11-10 | 3D都市モデル（Project PLATEAU）の加工物。写真は r1 と同じ | 行は Z が増える向き（北が下）。bounds −868..784、−610..710。画像は 4096×3273。歩行領域は約 108 ha で、モデルの外接矩形ではない |
| `seeds/uk-pavilion/r1` の会場図 | 同梱モデルの当たり判定（`app/assets/collision.bin`）と建物の外形から作成。2026-11-10 に、他の施設のローカル座標が収まる範囲へ広げ、従来の図は同じ矩形へ縮小して残した | 2026-11-10 | 3D都市モデル（Project PLATEAU）の加工物。広げた部分は下地色だけで、会場全体の新しい書き出しではない | 従来の英国パビリオン付近は 1 m = 8 px の図を 3 px/m のキャンバスへ縮小。全体は 1219 m × 796 m、3657×2388 px。行は Z が増える向き（北が下） |
| `seeds/pavilions.yaml` の `uk-pavilion` | OpenStreetMap way 1381316139（Overpass、2026-06-01 時点のデータ） | 2026-11-10 | ODbL。© OpenStreetMap contributors を表示する | 下記「英国パビリオンの照合」 |
| `seeds/uk-pavilion/r1` の構造物資料 | [Dezeen](https://www.dezeen.com/2025/04/15/uk-pavilion-expo-2025-osaka-woo-architects/) | 2026-11-10 | 事実を要約して記載（本文は転載しない） | なし |
| `seeds/uk-pavilion/r3` の構造物の代表位置 | r2 の構造物資料を引き継ぎ、代表位置だけを変えた（#213） | 2026-11-10 | 資料・写真・会場図は r2 と同じ | 建物中心（−174.9, −99.4）から、南の正面の外壁の約 6 m 手前（−172.0, −118.0）へ移した。ガイドは代表位置から 30 m 以内を対象にするため。周辺探索の開始点から 27.3 m、撮影ゴールから 15.2 m。ランドマークの表示位置（−174.9, −99.4）は変えない |
| `seeds/uk-pavilion/r4` の構造物資料（19件） | 報道・公式サイト（下記「ガイドの解説対象（`seeds/uk-pavilion/r4`）」） | 2026-11-10 | 事実を日本語で要約・言い換えて記載（本文は転載しない）。英国パビリオンの資料は r3 のまま | 代表位置は `uk-pavilion/r1` の landmarks と同じ（緯度経度の重心を変換した位置。建物の外形への照合はしていない） |
| `seeds/uk-pavilion/r5` の構造物資料（76件） | 公式サイト・報道（下記「ガイドの解説対象（`seeds/uk-pavilion/r5`）」） | 2026-11-10 | 事実を日本語で要約・言い換えて記載（本文は転載しない）。r4 の20件は r4 のまま | 代表位置は `uk-pavilion/r1` の landmarks と同じ（緯度経度の重心を変換した位置。建物の外形への照合はしていない） |

## 英国パビリオンの照合（`seeds/uk-pavilion/r1`）

### 地理座標から 3D ローカル座標への変換

OpenStreetMap の施設の外形を当たり判定のグリッド（1 m 格子）に重ね、重なりが最大になる変換を探した。

- 基準点 34.6489°N, 135.3800°E からの東距 e・北距 n（m、正距円筒の近似）に対して
  **x = e − 323.5、z = n − 13.5**。回転は 0°（±0.25° の範囲で最良）、縮尺は 1。
- 重なりを確かめた施設：リングサイドマーケットプレイス西（99.4%）・東（99.5%）、
  西ゲート・東ゲートのアクセシビリティセンター（100%・99.9%）、東ゲートマーケットプレイス（95%）。
  門の建物は通り抜けられる構造なので重ならない（0〜2%）。
- 東ゲート・西ゲートの変換結果は、アプリのテレポート地点（`kSpotCoordinates`。門の前の通路）からそれぞれ約 40 m・約 60 m で、向きと並びが一致する。
- 東距・北距は、基準点緯度での正距円筒で、WGS84 の赤道半径 6378137 m を使う。撮影地点 34.647853°N, 135.381688°E は x = −168.9、z = −130.1 になり、下の照合と一致する。

### 会場図に載せた他の施設

`pavilions.yaml` で緯度経度がある施設を、英国パビリオンを除いて `uk-pavilion/r1` の landmarks に加えた（2026-11-10）。緯度経度はマスターの値をそのまま写した。ローカル座標は上の変換で求め、0.1 m に丸めた。各建物の外形を当たり判定へ個別に重ねてはいない。英国パビリオンの表示位置（x = −174.9、z = −99.4）は外形照合の結果なので、重心を変換した位置では置き換えない。

会場図の範囲は、これらの地点と従来の歩行領域が入る X −683..536、Z −186..610 にした。画像の最大辺は 4096 px までなので 1 m = 3 px とし、従来の英国パビリオン付近の図は同じローカル範囲へ縮小して置いた。

### 実行時の座標の向き

- 同梱モデルの実行時の座標は **+X 東・+Z 北**。flutter_scene が glTF の Z を反転して読み込むため、
  GLB ファイル内の Z の符号を反転した値が当たり判定のグリッドと一致する（建物の頂点の 98% が通行不可のセル）。
- `docs/specs.md`「ローカル座標」も、この向き（＋Z を北）に合わせた（#213。以前は「−Z を北」と書いていた）。yaw はカメラの前方（+Z）を 0° とするため、
  北向き 0°・東向き 90° の規則は実際の方位どおりに成り立つ。
- 会場図の式（`v = (z - minZ) / (maxZ - minZ)`、画像の行は下に増える）に合わせて作ったため、会場図は北が下になる。

### 撮影姿勢

- 提供された撮影地点 34.647853°N, 135.381688°E は、変換すると x = −168.9、z = −130.1（庭の植栽の南端）。
- 写真の空の領域と電話ボックスの赤い枠を、3D モデルの描画結果と重ね合わせて、位置・yaw・pitch・画角を最適化した。
  結果は x = −164.6、z = −131.3、yaw = 359.8°（ほぼ真北）、上向き 14°、縦の画角 83°。提供地点から 4.4 m。
- 足元 Y は付近の地表（9.9 m）、視点は 1.6 m 上（11.5 m）。

## ガイドの解説対象（`seeds/uk-pavilion/r4`）

#227 で、会場の主な施設を AI ガイドの解説対象として足した。施設は、テレポート先と開始点の近くから選んだ。

- 取得日: すべて 2026-11-10（WebFetch で本文を取得し、facts の各記述を照合した）
- 座標: `content/seeds/uk-pavilion/r1/revision.yaml` の `landmarks:` から同じ pavilionKey の positionX / positionZ をそのまま転記
- ライセンス: いずれも報道・公式サイトの著作物。本文は転載せず日本語で要約・言い換えた。引用は固有名・テーマ名など短い語句のみ
- 英語の出典を日本語に訳した語（テーマ名など）は下表の「注記」に書いた。公式の日本語表記と違う可能性があるので、レビューで確認してほしい

| pavilionKey | 出典 URL | 取得日 | 発行元・注記 | 各出典が裏づける facts |
| --- | --- | --- | --- | --- |
| JpPr09 三菱未来館 | https://www.dezeen.com/2025/03/18/mitsubishi-pavilion-expo-2025-osaka/ | 2026-11-10 | Dezeen（建築メディア）。テーマ "life" を「いのち」と訳した | 三菱地所設計の設計、ひし形の上階、"mother ship hovering just above the ground"、足場用鋼管・土のう・ブルーシートなど仮設材の仕上げ利用、解体・再利用、テーマ、上階2シアターの映像体験 |
| JpPr08 パナソニック「ノモの国」 | https://news.panasonic.com/global/stories/17269 / https://www.archdaily.com/1029502/expo-2025-osaka-panasonic-group-pavilion-yuko-nagayama-and-associates | 2026-11-10 | Panasonic Newsroom（出展者の公式発表）/ ArchDaily | Panasonic: 永山祐子の設計、オーガンジー膜730枚・フレーム1,404個、見る角度で変わる外観（永山氏の発言）、使用済み家電や工場から回収した鉄・銅の再利用、子ども向け、"Unlock your nature"。ArchDaily: 設計者（Yuko Nagayama & Associates）、子ども向けのパビリオン |
| co12 サウジアラビア館 | https://www.dezeen.com/2025/04/15/saudi-arabia-pavilion-expo-2025-osaka/ | 2026-11-10 | Dezeen | Foster + Partners の設計、路地状の通路と中央の中庭、"village"、伝統的な街路を手本、サウジ産の石、解体・再利用、中庭の舞台と高さ17mの壁への投影 |
| JpPr14 TECH WORLD館 | https://www.taipeitimes.com/News/taiwan/archives/2025/04/06/2003834703 / https://www.nippon.com/en/guide-to-japan/expo2025077/ | 2026-11-10 | Taipei Times / Nippon.com（ニッポンドットコム） | Taipei Times: MAYU と梓設計（Azusa Sekkei）の設計、台湾の山々に着想。Nippon.com: 山々に着想、生命・自然・未来の3シアター、AI と3D映像、台湾の文化と技術の紹介 |
| emp10 フランス館 | https://www.dezeen.com/2025/04/14/france-pavilion-expo-2025-osaka/ | 2026-11-10 | Dezeen | Coldefy と Carlo Ratti Associati の設計、銅で覆われたらせん階段、赤い糸（Akai Ito）の言い伝えと劇場の大階段、高さ17mの白い布のファサード（舞台の幕）、樹齢1000年のオリーブの木の庭 |
| emp11 ベトナム館 | https://www.nippon.com/en/guide-to-japan/expo2025087/ | 2026-11-10 | Nippon.com。テーマは記事見出し "An Inclusive Society Where People Are Centered" の訳。建築・外観の記述は出典になく、facts は館内展示のみ | 天井のランタンの絵、プロジェクションマッピングと3D技術で民族衣装・産品を紹介、水上人形劇（伝統楽器の生演奏、1日4回） |
| sv01 イタリア・バチカンパビリオン | https://kyodonewsprwire.jp/release/202410188385 / https://www.nippon.com/en/guide-to-japan/expo2025019/ | 2026-11-10 | イタリア政府代表部のプレスリリース（Kyodo News PR Wire 配信）/ Nippon.com。"Art regenerates life" を「芸術が生命を再生する」、"Deposition" を一般的な邦題「キリストの埋葬」と訳した。リリースの「万博最大の木造建築」という主張は採らなかった | Kyodo: Mario Cucinella Architects の設計、全木造、ルネサンスの理想都市、テーマ、屋上の庭園。Nippon.com: テーマ、2世紀の大理石像ファルネーゼのアトラス、屋上の空中庭園、聖座（バチカン）の展示とカラヴァッジョの作品 |
| sv17 ベルギー王国館 | https://www.nippon.com/en/guide-to-japan/expo2025057/ / https://focusonbelgium.be/en/international/belgium-puts-water-building-blocks-life-centre-stage-world-expo-osaka-2025 | 2026-11-10 | Nippon.com / Focus on Belgium（ベルギー連邦外務省のサイト、2023年7月の設計案の記事）。設計段階の記事なので、建物の記述は完成後の Nippon.com に合わせ、Focus on Belgium からは設計者のみ採用した | Nippon.com: 水がテーマ、水の三態に対応する3層、3つの地域、生命科学・ヘルスケアを AI とロボットで紹介。Focus on Belgium: Cyril Rousseaux（シリル・ルソー）のチームの案 |
| sig03 いのちの遊び場クラゲ館 | https://expokurage-2025.com/en/concept/ / https://www.nippon.com/en/guide-to-japan/expo2025008/ | 2026-11-10 | 公式サイト（旧 expo2025-kuragepj.com から 301 で移転）/ Nippon.com。"Jellyfish Festival" は「祭りの舞台」と一般化した | 公式: 中島さち子の経歴（ジャズピアニスト・数学研究者・STEAM教育者）、創造の木、2階の Play Mountain、1階の祭りの舞台（世界の音楽や芸能）。Nippon.com: クラゲに着想した外観、木製部材を万博後に再利用しやすい設計 |
| sig04 null² | https://www.dezeen.com/2025/06/25/noiz-architects-pavilion-osaka-expo-null2/ | 2026-11-10 | Dezeen | Noiz Architects の設計、落合陽一のプロデュース、シグネチャーパビリオン、ボクセルの形、鉄骨と鏡面の膜、風や音で振動して映り込む空がゆがむ、ウーファーとロボットアームで波のような動き |
| sig01 Better Co-Being | https://co-being.jp/en/architecture/ / https://www.dezeen.com/2025/04/11/expo-2025-osaka-roundup/ | 2026-11-10 | 公式サイト / Dezeen（"Ten stand-out pavilions at Expo 2025 Osaka"）。"Forest of Tranquility" は会場の公式名「静けさの森」とした | 公式: SANAA（妹島和世・西沢立衛）の設計、宮田裕章（ページタイトル）、高さ11m・4層・銀色の格子状の天蓋、細い柱、風雨を防がない、アート体験の舞台、同じ空を分かち合う。Dezeen: 森の木々の間、屋根も壁もない、雲をイメージ |
| JpPr01 日本館 | https://www.dezeen.com/2025/05/02/nikken-sekkei-japan-pavilion-expo-osaka-2025/ | 2026-11-10 | Dezeen | 日建設計と佐藤オオキ（nendo）の設計、高さ12mの CLT パネルを間隔をあけて円状に配置、鉄骨が木材を支える、1階吹き抜けのバイオガス設備（生ごみを微生物発酵、発電）、展示タイトル Between Lives |
| emp13 カタール館 | https://www.dezeen.com/2025/05/21/qatar-pavilion-kengo-kuma-amo-expo-2025-osaka/ | 2026-11-10 | Dezeen | 隈研吾建築都市設計事務所の設計、カタールと日本の木組み技法、曲線の白い布、ダウ船の帆、AMO（OMA）の展示、海岸線と文化・産業 |
| JpPr13 GUNDAM NEXT FUTURE PAVILION | https://www.bandainamco.co.jp/en/gundam-next-future-pavilion/ / https://www.nippon.com/en/guide-to-japan/expo2025076/ | 2026-11-10 | バンダイナムコホールディングス公式 / Nippon.com | 公式: 出展者、RX-78F00/E、約17m（全高16.72m）、関西初の実物大立像、横浜の動くガンダムの部材を再利用。Nippon.com: 約17mの像、2150年の宇宙ステーションの映像体験、18m×8mのスクリーンと床の振動 |
| JpPr12 BLUE OCEAN DOME | https://www.dezeen.com/2025/04/11/expo-2025-osaka-roundup/ / https://www.dezeen.com/2023/05/31/shigeru-ban-domed-expo-2025-osaka-pavilion/ | 2026-11-10 | Dezeen（2025年の紹介記事と2023年の設計発表）。2023年記事は設計発表時点のもの | 2025: 坂茂の設計、3つのドームが紙管・竹・CFRP でできている。2023: 中央の大ドームと2つの小ドーム、ZERI（非営利団体）の出展、海といのちの大切さとプラスチックごみによる汚染の展示 |
| JpPr18 未来の都市 | https://ascii.jp/elem/000/004/256/4256659/ / https://www.travelvoice.jp/english/what-is-the-future-city-in-the-coming-expo-2025-osaka-kansai-12-exhibitors-showcase-their-future-societies | 2026-11-10 | ASCII.jp（2025-03-12）/ Travel Voice（2025-03-21） | ASCII: 博覧会協会と12の協賛企業・団体の共同出展、長さ約150m・幅約33m、テーマ「幸せの都市へ」、Society 5.0、太陽工業の白い光触媒コーティング膜とセルフクリーニング。Travel Voice: 長さ150m、12の出展者 |
| emp03 アイルランド館 | https://api.ireland.ie/en/expo/ireland-pavilion/ / https://www.nippon.com/en/guide-to-japan/expo2025016/ | 2026-11-10 | アイルランド政府公式サイト（正規 URL の www.ireland.ie は取得時 403。同内容の api.ireland.ie で確認）/ Nippon.com。テーマ "Creativity Connects People" を「創造性が人をつなぐ」と訳した | ireland.ie: OPW の建築家の設計、3つの楕円形の空間で立体的なトリスケル、新石器時代からの文様、アイルランド産ダグラスファー、テーマ、Joseph Walsh の彫刻 Magnus RINN。Nippon.com: トリスケルに着想、屋外の円形の彫刻 Magnus Rinn |
| sv10 アンゴラパビリオン | https://www.nippon.com/en/guide-to-japan/expo2025093/ / https://www.angola.or.jp/2025/10/13/angola-bestdesign-osaka2025-2/ | 2026-11-10 | Nippon.com / 在日アンゴラ大使館。"Education for Health" を「健康のための教育」と訳した。大使館の記事は授与団体を明記していないため、facts では「外観デザインの部門で金賞」とだけ書いた。建物の設計者・素材は出典になし | Nippon.com: テーマ、外観に漢字でテーマ、伝統工芸品・民族衣装、マラリアから救われ医療従事者になった女性のドキュメンタリー、感染症対策などの課題と取り組む人々。大使館: Best Pavilion Exterior Design の金賞 |
| sv08 ルーマニアパビリオン | https://www.nippon.com/en/guide-to-japan/expo2025081/ / https://romania-actualitati.ro/news-in-english/romania-participates-in-the-world-expo-in-japan-with-a-700-square-meter-pavilion-id204941.html | 2026-11-10 | Nippon.com / Radio România Actualități（ルーマニア公共ラジオ）。建築・設計者の記述は出典になく、facts はテーマと展示のみ | Nippon.com: テーマ Romanian Magic Box、ペリカン「ハル」のホログラム、インスタレーション・映像・コンサート・料理で自然・芸術・工芸・食を紹介。RRA: 面積約700㎡ |

### 見送った情報

- スキップしたパビリオン: なし（依頼の19件すべてに、取得して照合できた出典が1件以上ある）
- 内容が薄いもの: ベトナム館・ルーマニアパビリオン・アンゴラパビリオンは、建物の設計者や素材を書いた出典を確認できなかった。facts はテーマと展示内容に限っている
- 採らなかった情報（取得できなかった、または出典で確認できなかったもの）
  - ルーマニア館の「学生による設計案」: romania-insider.com が 429、agerpres.ro が 403 で本文を取得できず
  - TECH WORLD館の「台湾産の蛇紋石」「外装の金属」: 検索の要約にのみあり、取得した本文では確認できず
  - 未来の都市の「モアレ模様の外装は世界初」: ASCII.jp にあるが「世界初」の主張なので採らなかった
  - アンゴラ館の授与団体名（BIE の国別ページは 403）
  - ベルギー館の水鏡・雲のような膨張式の屋根: 2023年の設計案の記事のみで、完成後の出典で確認できず
  - ベトナム館の開館日に関わる歴史的な記述、ルーマニア館の「魔女の国」という表現: 国や文化を一括りにする説明になりうるので採らなかった

## ガイドの解説対象（`seeds/uk-pavilion/r5`）

#239 で、会場図に出すパビリオンの残り 76 件を AI ガイドの解説対象として足した。各出典は 2026-11-10 に本文を取得し、facts の各記述を照合した。本文は転載せず日本語で要約・言い換え、英語の出典から訳した語（テーマ名など）は「注記」に書いた。座標は `uk-pavilion/r1` の landmarks と同じ。

| pavilionKey 名前 | 出典 URL | 取得日 | 発行元・注記 | 各出典が裏づける facts |
| --- | --- | --- | --- | --- |
| JpPr02 ウーマンズ パビリオン in collaboration with Cartier | https://www.japan.go.jp/kizuna/2024/05/womens_pavilion_at_osaka_kansai_expo.html | 2026-11-10 | 日本政府（JapanGov KIZUNA、内閣府政府広報室）。2024-05-17 掲載。コンセプト "When women thrive, humanity thrives" ＝「女性が輝くとき、人類も輝く」 | 永山祐子がリード建築家、ドバイ万博日本館のファサード（永山が設計した立体組子格子）を再利用、敷地が細長い、内閣府・経産省・カルティエ・博覧会協会の共同出展、エス・デヴリンが展示の制作とキュレーション、コンセプト |
| JpPr02 | https://www.arup.com/projects/womens-pavilion-in-collaboration-with-cartier-at-expo-2025-osaka/ | 2026-11-10 | Arup（構造・設備・ファサードのコンサルタント）。建築家名はページ上で明記なし（施主欄に Yuko Nagayama & Associates） | ドバイから運んだ約1万点のファサード部材を再利用し、別形状の敷地に合わせて組み直した |
| JpPr03 大阪ヘルスケアパビリオン | https://arch2o.com/osaka-expo-2025-healthcare-pavilion-nest-for-reborn-tohata-architects-engineers | 2026-11-10 | Arch2O（建築メディア）。内容は設計者提供の説明に基づく。ArchDaily（https://www.archdaily.com/1032425/osaka-expo-2025-healthcare-pavilion-nest-for-reborn-tohata-architects-and-engineers）でも設計者・施主・REBORN・「水都大阪」の記述を確認したが、屋根と柱の記述は取得範囲で確認できなかったため出典には採らなかった | 大阪府・大阪市の出展、東畑建築事務所の設計、テーマ REBORN、木と水で栄えた「水都大阪」に着想、形が異なる膜屋根、再生水が屋根を流れて水盤で濾過・循環する Water Veil、DNA に着想を得たらせん状の木の柱 |
| JpPr03 | https://www.nippon.com/en/guide-to-japan/expo2025066/ | 2026-11-10 | Nippon.com（2025-05-14） | 大阪府・大阪市の出展、テーマ Reborn、屋根から水が循環する |
| JpPr04 関西パビリオン | https://www.nippon.com/en/guide-to-japan/expo2025067/ | 2026-11-10 | Nippon.com（2025-05-14）。テーマ "The Brilliance of Kansai's Rich History and Its Present Day" ＝「関西の豊かな歴史と現在の輝き」（facts ではテーマ名を引用していない） | 関西広域連合が主体、9府県（京都・滋賀・兵庫・奈良・和歌山・鳥取・徳島・福井・三重）、各府県の展示を高さ12mの吹き抜け「センターサークル」がつなぐ |
| JpPr04 | https://discoverjapan-web.com/article/142654 | 2026-11-10 | Discover Japan（2025-04-15） | 六角形の建物と白い幕で灯籠を表現、外壁に関西各地を象徴する切り絵、夜は内部の光が幕を透過して大きな灯籠のようになる、高さ12mの吹き抜け |
| JpPr05 NTT Pavilion | https://group.ntt/jp/expo2025/pavilion/ | 2026-11-10 | NTT 公式（出展者） | 体験テーマ「PARALLEL TRAVEL」、「感情を纏う建築」、風にゆらめく布、来場者の笑顔の量に応じて幕が揺れる、カーボンワイヤーで3つのシアターを引っぱり上げるテントのような構造で鋼材を削減、IOWN による空間伝送、1970年万博の電気通信館跡地（吹田）と夢洲を結んだ Perfume のライブ再現 |
| JpPr05 | https://www.nippon.com/en/guide-to-japan/expo2025068/ | 2026-11-10 | Nippon.com（2025-05-14）。"parallel travel" ＝ 時間と空間を超える旅 | NTT の出展、時間と空間を旅するテーマ、糸のような外装が風と来場者の笑顔で揺れる、IOWN |
| JpPr06 電力館 可能性のタマゴたち | https://www.daiwahouse.com/English/expo2025/ | 2026-11-10 | 大和ハウスグループ（施工者）公式 | 電気事業連合会の出展、基本設計は電通ライブと日建設計、実施設計・施工は大和ハウス工業、鉄骨造2階建て・高さ17.4m、銀色のボロノイ構造の外装が天候と時間帯で表情を変える |
| JpPr06 | https://www.nippon.com/en/guide-to-japan/expo2025069/ | 2026-11-10 | Nippon.com（2025-05-14）。"Eggs of Possibilities" ＝ 可能性のタマゴたち | 銀色のドームが時間と天候で表情を変える、エネルギーの多様な可能性、タマゴ型デバイスをブースに置くとゲームや映像が始まり光と振動で応える |
| JpPr07 住友館 | https://www.sumitomo.gr.jp/english/expo2025/arch/ | 2026-11-10 | 住友グループ広報委員会（出展者）公式 | 別子の嶺（別子銅山）に着想した山並みのシルエット、「住友の森」の木を使用、曲面屋根はヒノキ、入口まわりの外壁はスギ |
| JpPr07 | https://www.nippon.com/en/guide-to-japan/expo2025070/ | 2026-11-10 | Nippon.com（2025-05-14）。スローガン "Toward a future from the forest" ＝「森から未来へ」 | 住友グループのパビリオン、木の屋根が別子銅山の稜線に着想、展示「UNKNOWN FOREST」と植樹（Plant a Tree） |
| JpPr10 よしもと waraii myraii館 | https://expo.yoshimoto.co.jp/ | 2026-11-10 | 吉本興業（出展者）公式 | テーマ「こころとからだの健康につながる、笑いのチカラ」、デザイン監修 WHY、設計 大成建設一級建築士事務所、メインエントランスの丘の上に浮かぶ笑顔の球体「タマー」、アシタ広場のコメディショーとノンバーバルパフォーマンス |
| JpPr10 | https://www.nippon.com/en/guide-to-japan/expo2025073/ | 2026-11-10 | Nippon.com（2025-06-11） | 吉本興業ホールディングスの出展、名前が「笑い」と「未来」を掛け合わせたもの、毎日3回のコメディショー |
| JpPr11 PASONA NATUREVERSE | https://www.designboom.com/architecture/spiral-shell-shaped-pavilion-expo-2025-osaka-architecture-ecology-design-labo-09-24-2025/ | 2026-11-10 | designboom（建築メディア） | 設計 the design labo／板坂諭、施主パソナグループ、鉄骨造、アンモナイトに着想を得たらせん形、来場者はらせん状の動線をたどる |
| JpPr11 | https://www.nippon.com/en/guide-to-japan/expo2025074/ | 2026-11-10 | Nippon.com（2025-06-11）。テーマ "Thank You, Life"（facts では引用していない）。ゾーン名 Body / Mind・Bonds / History of Life を「からだ」「こころと絆」「いのちの歴史」と訳した | アンモナイトを生命のモチーフにしたらせん形、3つのゾーン、iPS 細胞からつくられた拍動する心臓 |
| JpPr15 ガスパビリオン おばけワンダーランド | https://kyodonewsprwire.jp/release/202309220032 | 2026-11-10 | 2025年日本国際博覧会協会のリリース（共同通信PRワイヤー配信、2023-09-22） | コンセプト「化けろ、未来！」、鏡面の膜材を使った最大高さ約18mの三角形断面、放射冷却素材 SPACECOOL で室内温度の上昇を抑える |
| JpPr15 | https://www.nippon.com/en/guide-to-japan/expo2025078/ | 2026-11-10 | Nippon.com（2025-06-16）。"Bakero—Shape Our Future!" ＝「化けろ、未来！」 | 日本ガス協会の出展、カーボンニュートラル社会の実現、XR ゴーグルでおばけになる体験、e-メタン（未来の都市ガス）などのパネル展示 |
| JpPr16 飯田グループ×大阪公立大学共同出展館 | https://www.wwdjapan.com/articles/2099750 | 2026-11-10 | WWDJAPAN（2025-04-23）。細尾社長へのインタビュー記事 | 高松伸の設計、メビウスの輪を応用した三次元の構造物、細尾の西陣織で全面を包む、耐久性・耐光性のためシルクでなくポリエステル、半年間の風雨や日光に耐える |
| JpPr16 | https://www.nippon.com/en/guide-to-japan/expo2025079/ | 2026-11-10 | Nippon.com（2025-06-16） | 住宅メーカーの飯田グループと大阪公立大学の共同出展、未来型住宅とまちづくり、15×24m の楕円形ジオラマ「ウェルネス・スマートシティ」 |
| JpPr17 ORA外食パビリオン 宴 | https://www.nippon.com/en/guide-to-japan/expo2025080/ | 2026-11-10 | Nippon.com（2025-06-16） | 大阪外食産業協会（ORA）の出展、外食産業が描く食の未来、江戸時代の大阪は「天下の台所」、1階で外食チェーンや菓子メーカーの万博限定商品、2階で体験型プログラム |
| JpPr17 | https://news.nissyoku.co.jp/news/okum20250410032527420 | 2026-11-10 | 日本食糧新聞・電子版（2025-04-18）。本文の冒頭のみ公開（全文は会員限定） | テーマ「新・天下の台所」、約80社が参加、1階で食の提供・販売、2階で食の展示・体験教室 |
| emp01 アメリカ館 | https://www.dezeen.com/2025/04/09/usa-osaka-pavilion-trahan-cube/ | 2026-11-10 | Dezeen | 設計 Trahan Architects（米国）、V字に開く2棟の三角形の建物、半透明パネルで覆った吊られた立方体、入口の壁の LED スクリーン |
| emp01 | https://www.nippon.com/en/guide-to-japan/expo2025018/ | 2026-11-10 | Nippon.com（2025-04-28）。"Imagine What We Can Create Together" ＝「共に創り出せるものを想像しよう」（facts では引用していない） | 2棟の三角形の建物の間に浮かぶ13.5mの立方体、LED に米国各地の名所や産業、宇宙探査などの分野、1972年採取の月の石 |
| emp02 スイス連邦館 | https://www.dezeen.com/2025/04/25/manuel-herz-switzerland-pavilion-expo-osaka/ | 2026-11-10 | Dezeen | 設計 Manuel Herz Architects、PVC と ETFE を膨らませた二重のクッションを鉄骨で支える球体、Expo '70 の空気膜・メタボリズム建築を参照、中心テーマは「軽さ」、解体・輸送・再利用が可能、展示テーマ Life / Planet / Augmented Human |
| emp02 | https://www.nippon.com/en/guide-to-japan/expo2025037/ | 2026-11-10 | Nippon.com（2025-05-02）。"Life, Planet, Augmented Human" ＝ 生命・地球・拡張された人間 | 展示の3テーマ |
| emp04 マレーシア館 | https://kkaa.co.jp/en/project/expo-2025-malaysia-pavilion/ | 2026-11-10 | 隈研吾建築都市設計事務所（設計者）公式 | 隈研吾建築都市設計事務所の設計、ソンケットに着想、約5,000本の竹をコンピューターを使った設計で編む、布のように柔らかく光を通すファサード |
| emp04 | https://www.nippon.com/en/guide-to-japan/expo2025060/ | 2026-11-10 | Nippon.com（2025-04-28）。"Weaving a Future in Harmony" ＝「調和の中で未来を織りなす」（facts では引用していない） | 隈研吾がソンケットに基づいて設計、夜のライトアップで外装のリボン模様が金糸・銀糸のように見える、伝統工芸の実演 |
| emp05 コモンズA館 | https://www.expo2025.or.jp/en/official-participant/ | 2026-11-10 | 2025年日本国際博覧会 公式サイト（2025-10-13 時点のアーカイブ） | "(Commons-A)" と表記された29の国（Barbados, Bolivia, Burundi, Comoros, Eswatini, Ghana, Grenada, Guinea-Bissau, Kenya, Kosovo, Kyrgyz, Malawi, Mauritius, North Macedonia, Palau, Papua New Guinea, Rwanda, Saint Christopher and Nevis, Saint Lucia, Samoa, Seychelles, Solomon, Sri Lanka, Suriname, Tonga, Trinidad and Tobago, Uganda, Vanuatu, Yemen） |
| emp05 | https://www.jica.go.jp/information/blog/1572398_21942.html | 2026-11-10 | 国際協力機構（JICA）ブログ（2025-08-06） | コモンズは大屋根リングの内側、地域別でなくサブテーマ別に分かれ、A館は Empowering Lives（いのちに力を与える） |
| emp06 ヨルダン館 | https://international.visitjordan.com/mediacenter/shownews?id=53 | 2026-11-10 | ヨルダン政府観光局（2025-04-13）。"Weaving Possibilities" ＝「可能性を織りなす」 | テーマ、シュマーグに着想を得た動く壁のファサードを皇太子財団の CAVT の学生が制作、ワディ・ラムの砂を敷いた360度の没入型ドーム |
| emp06 | https://www.nippon.com/en/guide-to-japan/expo2025062/ | 2026-11-10 | Nippon.com（2025-05-13） | テーマ、メイン展示室は上北山村の杉で囲まれた円形の映像空間、ワディ・ラム保護区から約22トンの砂、砂の上に座って360度でヨルダンの歴史をたどる |
| emp07 ペルー館 | https://www.expo2025.or.jp/en/official-participant/peru | 2026-11-10 | 2025年日本国際博覧会 公式サイト。"Infinite Possibilities" ＝「無限の可能性」 | テーマ、農産物・織物・工芸品などの輸出品、ペルー料理 |
| emp07 | https://www.nippon.com/en/guide-to-japan/expo2025083/ | 2026-11-10 | Nippon.com（2025-07-15） | テーマ、アンデスとアマゾンの自然と古代遺跡、7月12日までシパンのピラミッドから出土した金銀の副葬品、7月13日からナスカ文化 |
| emp08 モザンビーク館 | https://www.expo2025.or.jp/en/official-participant/mozambique | 2026-11-10 | 2025年日本国際博覧会 公式サイト。"Expanding Horizons" ＝「地平を広げる」 | テーマ、教育と仕事を社会を変える主な要因と位置づける |
| emp08 | https://www.nippon.com/en/guide-to-japan/expo2025089/ | 2026-11-10 | Nippon.com（2025-07-09） | 外観にインド洋に面した海岸の風景、帆船形のベンチと周囲のモニター・パネルで海洋研究など SDGs の取り組み、カプラナの展示販売 |
| emp09 フィリピン館 | https://www.arch2o.com/?p=618120 | 2026-11-10 | Arch2O（建築メディア） | 設計 Carlo Calma Consultancy、212枚の手織りパネル、経糸と緯糸の概念、各地のコミュニティの職人が制作、Nature / Culture / Community の展示 |
| emp09 | https://www.nippon.com/en/guide-to-japan/expo2025053/ | 2026-11-10 | Nippon.com（2025-05-12）。テーマ "Nature, Culture, and Community—Woven Together for a Better Future" ＝「自然、文化、コミュニティ ― よりよい未来へ共に織りなす」（facts の和訳は当方による） | テーマ、212枚の手織りタペストリーパネル、Art Forest で各地域の織物、伝統舞踊などのライブ |
| emp12 ミャクミャクハウス | https://gigazine.net/gsc_news/en/20250409-myakumyaku-osaka-kansai-expo | 2026-11-10 | GIGAZINE（2025-04-09、開幕前の現地取材記事）。公式発表ではない点に注意 | ミャクミャクについて知り、会える施設、愛知万博（2005年）のモリゾーとキッコロから引き継いだバトンの展示、公式ストアで売られるぬいぐるみ、コラボしたキャラクターの展示 |
| emp12 | https://www.nippon.com/en/guide-to-japan/expo2025001/ | 2026-11-10 | Nippon.com（2025-04-13） | ミャクミャクが大阪・関西万博の公式キャラクターであること（ハウス自体の記述はない） |
| emp14 アラブ首長国連邦館 | https://www.nippon.com/en/guide-to-japan/expo2025014/ | 2026-11-10 | Nippon.com（2025-04-28）。テーマ「Earth to Ether」は「大地から天空へ」の意 | ガラス張りの館内に木のような柱が立つ、柱は農業廃材製、宇宙開発・医療の展示 |
| emp14 アラブ首長国連邦館 | https://www.thenationalnews.com/news/uae/2025/04/13/uae-pavilion-opens-at-expo-2025-osaka-with-focus-on-heritage-and-future | 2026-11-10 | The National（UAE の英字紙、2025-04-13） | 設計は UAE と日本のクリエイターによる Earth to Ether Design Collective、柱90本・最大16m、ナツメヤシの農業廃材、日本の木工技術 |
| emp15 カナダ館 | https://www.nippon.com/en/guide-to-japan/expo2025030/ | 2026-11-10 | Nippon.com（2025-05-01）。テーマ「Regeneration」は「再生」 | 春に凍った川が解ける様子、青と白の外観、AR タブレットで川をたどる体験、地域の暮らし |
| emp15 カナダ館 | https://www.canadianarchitect.com/canada-unveils-pavilion-concept-for-expo-2025-osaka/ | 2026-11-10 | Canadian Architect（2023-12-08、構想発表時の記事） | 設計チームに Rayside Labossière と Guillaume Pelletier、ロベール・ルパージュが芸術面の助言者（artistic advisor）、外観は春の氷の造形に着想 |
| emp16 ポルトガル館 | https://www.nippon.com/en/guide-to-japan/expo2025058/ | 2026-11-10 | Nippon.com（2025-04-28）。テーマ「Ocean, The Blue Dialogue」は「海、青の対話」 | 隈研吾の設計、内外に吊るした無数のロープで海の色と波を表現、海洋保全、南蛮貿易から約500年の交流 |
| emp16 ポルトガル館 | https://www.expo2025.or.jp/officialblog/blog_20250510_1/ | 2026-11-10 | 2025年日本国際博覧会協会 公式ブログ（隈研吾インタビュー、2025年5月ごろ） | 山が船の木材とロープの植物繊維を生んだことに着目、風が通り抜けるロープの建物 |
| emp17 コロンビア館 | https://www.nippon.com/en/guide-to-japan/expo2025034/ | 2026-11-10 | Nippon.com（2025-05-07）。タイトル「Country of Beauty」は「美の国」 | 氷の立方体を積んだような建物、『百年の孤独』で主人公の少年が初めて氷を見る場面に着想、「美の国」の紹介 |
| emp17 コロンビア館 | https://www.designboom.com/architecture/dancing-translucent-cubes-modular-colombia-pavilion-osaka-expo-2025-morf-07-03-2025/ | 2026-11-10 | designboom（2025-07-03） | 東京の MORF Inc. が設計、半透明ポリカーボネートの立方体を角度を変えて配置、軽量鉄骨のモジュール構造、解体して別の場所で再利用できる設計 |
| emp18 オーストリア館 | https://www.nippon.com/en/guide-to-japan/expo2025026/ | 2026-11-10 | Nippon.com（2025-05-01）。テーマ「Composing the Future」は「未来を作曲する」 | 空へ伸びるらせん（楽譜を表す）、1873年ウィーン万博で明治天皇に贈られたピアノ「エンペラー」の複製、AI 作曲体験 |
| emp18 オーストリア館 | https://www.archdaily.com/1018994/bwm-architects-explores-musical-heritage-for-austria-pavilion-at-expo-osaka-2025 | 2026-11-10 | ArchDaily（2025-04-18） | BWM Designers & Architects の設計、五線譜のような木の板のらせん、部材はねじ留めで解体・再利用可能 |
| emp19 ブラジル館 | https://www.nippon.com/en/guide-to-japan/expo2025084/ | 2026-11-10 | Nippon.com（2025-07-15） | 人と自然の関係がテーマ、2つの建物、再利用木材とビニール袋（plastic bags）のアート作品、人や動物が天井から垂れ下がる、パランゴレと羽衣を合わせた衣装「パランゴロモ」 |
| emp20 クウェート館 | https://www.nippon.com/en/guide-to-japan/expo2025031/ | 2026-11-10 | Nippon.com（2025-05-07） | 翼のような形、夜の照明、2階建て、庭園と中東の伝統的な中庭、真珠を思わせるドーム、砂漠の夜空、過去・現在・未来の展示 |
| emp20 クウェート館 | https://www.designboom.com/architecture/kuwait-visionary-lighthouse-pavilion-design-expo-2025-osaka-lava-03-07-2024/ | 2026-11-10 | designboom（2024-03-07、デザイン発表時の記事）。「Visionary Lighthouse」は「先見の灯台」の意 | LAVA の設計、コンセプト「Visionary Lighthouse」、2つの翼は迎え入れるしぐさ、夜は外観が光る |
| emp21 中華人民共和国館 | https://www.nippon.com/en/guide-to-japan/expo2025044/ | 2026-11-10 | Nippon.com（2025-05-09）。テーマ「Building a Community of Life for Man and Nature—Future Society of Green Development」を「人と自然の生命共同体を築く」と短く訳した | 竹簡のデザイン、5つの書体で漢詩など119の文章、国宝級の文化財、鑑真（Jianzhen）の像、嫦娥6号の月の裏側の試料 |
| emp21 中華人民共和国館 | https://www.archdaily.com/1001039/china-pavilions-plan-for-expo-osaka-2025-a-showcase-of-traditional-chinese-inscribed-slips | 2026-11-10 | ArchDaily（2023-05-26、設計案発表時の記事） | China Architecture Design Group（CADG）の設計、竹簡（Inscribed Slips）がモチーフ |
| emp22 国際機関館 | https://www.nippon.com/en/guide-to-japan/expo2025092/ | 2026-11-10 | Nippon.com（2025-07-09） | 5機関の共同出展（World Expo Museum、ASEAN、International Solar Alliance、ITER、International Science and Technology Center）、ASEAN の世界遺産 VR、ITER の核融合炉模型と CG |
| emp23 国際連合館 | https://www.nippon.com/en/guide-to-japan/expo2025033/ | 2026-11-10 | Nippon.com（2025-05-07）。テーマ「United for a Better Future」は「よりよい未来のために団結を」 | 事務局・部門がひとつの展示に、80年の歩み、地球規模の課題と人道危機、日常とのつながり、持続可能な未来 |
| emp24 国際赤十字・赤新月運動館 | https://www.nippon.com/en/guide-to-japan/expo2025032/ | 2026-11-10 | Nippon.com（2025-05-07）。タイトル「The Power of Humanity」は「人道の力」 | 命・健康・尊厳を守る人道支援、約30分・3ゾーン、写真とプロジェクションマッピング、ドーム型シアター、メッセージの大画面 |
| emp25 バーレーン館 | https://www.nippon.com/en/guide-to-japan/expo2025050/ | 2026-11-10 | Nippon.com（2025-05-11）。タイトル「Connecting Seas」は「海をつなぐ」 | 4階建て、ダウを思わせる形、組み合わせた木の柱、海洋文化の展示 |
| emp25 バーレーン館 | https://www.dezeen.com/2025/04/15/lina-ghotmeh-bahrain-pavilion-expo-2025-osaka/ | 2026-11-10 | Dezeen（2025-04-15） | レバノン出身のリナ・ゴトメの設計、高さ17m・4層、約3,000本の日本のスギ材、正面の半透明膜はダウの帆を参照し日差しを和らげる、吹き抜けを囲む交易・真珠採り・工芸などの展示 |
| emp26 トルクメニスタン館 | https://www.nippon.com/en/guide-to-japan/expo2025046/ | 2026-11-10 | Nippon.com（2025-05-11）。テーマ「Inspiring a Better Tomorrow」は「よりよい明日を目指して」 | 国土の約7割のカラクム砂漠に着想、角の丸い三角形で循環・持続可能性・いのちの流れ、外壁の大型スクリーンの馬の映像、階ごとの展示テーマ |
| emp27 北欧館 | https://www.nippon.com/en/guide-to-japan/expo2025015/ | 2026-11-10 | Nippon.com（2025-04-28）。タイトル「Together Toward a Better Future」は「ともに、よりよい未来へ」 | 5か国の共同出展、3階建ての木造、北欧の伝統的な納屋に着想、1,200m²・17m、捨てられるはずだった米でつくった紙のスクリーン |
| emp27 北欧館 | https://thenordics-expoosaka.com/en/news/nordic-pavilion | 2026-11-10 | Nordic Pavilion 公式サイト「Nordic Circle」（2023-10-23） | ミケーレ・デ・ルッキと AMDL CIRCLE の設計、1,200m²・高さ17mの木造、再利用を前提に設計・製作・設置 |
| emp28 マルタ館 | https://www.nippon.com/en/guide-to-japan/expo2025059/ | 2026-11-10 | Nippon.com（2025-04-28）。テーマ「Catch the Wave, Catch the Opportunity」は「波をつかみ、機会をつかむ」 | 大型モニター壁の「時の門」（石灰岩の壁のような見た目）、古代の美意識と先端技術の没入体験、江戸時代末期の使節団が贈った甲冑、2015年に武器庫で再発見 |
| emp29 チェコ館 | https://www.nippon.com/en/guide-to-japan/expo2025042/ | 2026-11-10 | Nippon.com（2025-05-09）。テーマ「Talent and Creativity for Life」は「いのちのための才能と創造性」 | チェコ産木材の CLT パネル、ボヘミアンクリスタルのファサード、らせんの廊下がギャラリー、ミュシャの作品 |
| emp29 チェコ館 | https://www.dezeen.com/2025/05/12/spiralling-ramp-timber-glass-czech-pavilion-osaka-expo/ | 2026-11-10 | Dezeen（2025-05-12） | Apropos Architects の設計、CLT パネルはねじ留めで解体しやすい、ガラスの外壁、屋上の展望テラス、らせんは1970年大阪万博のチェコ館（Viktor Rudiš 設計）を参照 |
| sig02 いのちの未来 | https://www.nippon.com/en/guide-to-japan/expo2025007/ | 2026-11-10 | Nippon.com（2025-04-25）。タイトル「Amplification of Lives」は「いのちの増幅（拡がり）」の意 | 石黒浩のプロデュース、黒い外壁を水が流れ水はいのちの象徴、3ゾーン（モノにいのちを宿してきた歴史／50年後／1000年後）、約30体のアバターとロボット |
| sig02 いのちの未来 | https://www.expo2025.or.jp/news/news-20241021-02/ | 2026-11-10 | 2025年日本国際博覧会協会 プレスリリース（2024-10-21） | 基本設計・実施設計は石本建築事務所、鉄骨造2階建、屋上から外壁へ水が階段状に流れる「水膜」のファサード |
| sig05 いのちの動的平衡館 | https://www.nippon.com/en/guide-to-japan/expo2025010/ | 2026-11-10 | Nippon.com（2025-04-25）。タイトル「Quest of Life」は「いのちの探究」の意 | 福岡伸一のプロデュース、柱のない膜屋根を周囲の鉄骨リングから伸びるワイヤーと空気チューブが支える、胚（エンブリオ）を表す、32万個の LED の「クラスラ」 |
| sig05 いのちの動的平衡館 | https://www.expo2025.or.jp/expo-archive/project/fukuoka/overview/ | 2026-11-10 | 2025年日本国際博覧会協会 公式アーカイブ（いのち動的平衡館 公式サイト） | 建築は橋本尚樹（NHA）、建築名「エンブリオ」、柱なし、リングやワイヤーのどれかが欠けても支えられない釣り合いの構造、クラスラは32万球・直径約10m |
| sig06 いのちめぐる冒険 | https://www.nippon.com/en/guide-to-japan/expo2025011/ | 2026-11-10 | Nippon.com（2025-04-25）。英語名「Live Earth Journey」、タイトル「Totality of Life」は「いのちの全体」の意 | 河森正治の展示、鉄骨と特殊コンクリートパネルの立方体「セル」を積み重ねた建物、最大30人の VR で宇宙規模の食物連鎖、「ANIMA!」（映像・音楽・振動）、外の球体は PC・携帯電話から回収した金で覆われる |
| sig06 いのちめぐる冒険 | https://www.expo2025.or.jp/news/news-20250410-05/ | 2026-11-10 | 2025年日本国際博覧会協会 プレスリリース（2025-04-10） | 「いのち球」は直径3.5m、廃棄 PC・携帯電話由来の都市鉱山の金で作った金箔、ANIMA! の内容 |
| sig07 EARTH MART | https://www.nippon.com/en/guide-to-japan/expo2025012/ | 2026-11-10 | Nippon.com（2025-04-25）。タイトル「Cycle of Lives」は「いのちの循環」の意 | 小山薫堂（放送作家・脚本家）のプロデュース、食を通じていのちを考える「imaginary marketplace（空想の市場）」、約20のコンテンツを生産者・シェフ・フードテックと共創、茅葺き屋根で隈研吾の設計（写真キャプション）、模型の卵2万8000個のシャンデリア |
| sig07 EARTH MART | https://www.expo2025.or.jp/officialblog/blog_20250510_1/ | 2026-11-10 | 2025年日本国際博覧会協会 公式ブログ（隈研吾インタビュー） | 隈研吾の設計、茅（ススキなど）を日本各地から集めた |
| sig08 Dialogue Theater ‐ いのちのあかし ‐ | https://www.expo2025.or.jp/wp/wp-content/themes/expo2025orjp_2022/assets/pdf/project/pav_kawase.pdf | 2026-11-10 | 2025年日本国際博覧会協会（公式のパビリオン紹介PDF）。WebFetch では PDF を読み込めたが本文を取り出せなかったため、同じ URL を pdftotext で読んで確認した。校舎は「奈良県十津川村立旧折立中学校」と「京都府福知山市立旧細見小学校中出分校」 | 河瀨直美がプロデューサー、テーマ「いのちを守る」、奈良・京都の2つの廃校の木造校舎を解体・移築して3棟に組み直したこと、毎日異なる問いかけ、初対面の二人が脚本なしで約10分間対話し来場者が見届けること |
| sig08 | https://www.nippon.com/en/guide-to-japan/expo2025013/ | 2026-11-10 | Nippon.com「Dialogue Theater: Sign of Life (Embracing Lives)」。コンセプト「Every day is the first dialogue in human history」（毎日が人類史上はじめての対話） | 映画作家の河瀨直美がプロデュース、奈良と京都から移した2つの廃校舎を使う、来場者と世界のどこかにいる相手との台本のない対話 |
| sv02 シンガポールパビリオン | https://www.nippon.com/en/guide-to-japan/expo2025036/ | 2026-11-10 | Nippon.com「Singapore Pavilion: Where Dreams take Shape」（夢が形になる場所）。公式サイト上の和文テーマは「ゆめ・つなぐ・みらい」 | 高さ17メートルの赤い「ドリーム・スフィア」、リサイクル可能なアルミ円盤1万7000枚、絵馬に着想 |
| sv02 | https://www.archdaily.com/1018349/dp-architects-unveil-the-dream-sphere-singapores-national-pavilion-at-expo-osaka-2025 | 2026-11-10 | ArchDaily。Kingsmen Exhibits との協働 | DP Architects の設計、シンガポールのアーティストによる3層のインタラクティブ展示、最上階の「Dream Forest」 |
| sv03 ブルガリア パビリオン | https://www.nippon.com/en/guide-to-japan/expo2025055/ | 2026-11-10 | Nippon.com「Bulgaria Pavilion: Evolving with Nature」（自然とともに進化する）。英文のマスコット名は「Lacto-chan」。日本語版（https://www.nippon.com/ja/guide-to-japan/expo2025055/ 、curl で確認）の表記「ラクトちゃん」「腸内フローラ」に合わせた | 1970年大阪万博でヨーグルトを紹介、乳酸菌がモチーフのマスコット、腸内フローラを思わせる装飾、自然と微生物の世界の没入型展示 |
| sv03 | https://www.expo2025.or.jp/official-participant/bulgaria/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「自然とともに進化する」、インタラクティブな没入型の体験 |
| sv04 オランダパビリオン | https://www.nippon.com/en/guide-to-japan/expo2025028/ | 2026-11-10 | Nippon.com「Netherlands Pavilion: Creating A New Dawn Together on Common Ground」（コモングラウンドで新たな夜明けを共に創る）。公式サイトのテーマは「Common Ground / コモングラウンド」 | テーマ「コモングラウンド」、中央に浮かぶ11メートルの白い球体（再生可能エネルギーと日の出を表す）、来場者に渡される手のひら大の光る球 |
| sv04 | https://www.dezeen.com/2025/04/11/expo-2025-osaka-roundup/ | 2026-11-10 | Dezeen「Ten stand-out pavilions at Expo 2025 Osaka」 | RAU Architects の設計、解体できる（demountable）構造、水を表す波打つルーバー（slatted facade）、小さな球が展示に反応する |
| sv05 オマーン館 | https://www.nippon.com/en/guide-to-japan/expo2025027/ | 2026-11-10 | Nippon.com「Oman Pavilion: Earth, Water, and Humanity」（地球、水、人間性） | 「土地と水と人々」のテーマ、アラビア海・砂漠・山・緑、屋外の赤いオブジェ、ガラス天井の上を水が流れる通路、砂漠緑化の水資源管理と再生可能エネルギーの展示 |
| sv05 | https://www.expo2025.or.jp/official-participant/oman/ | 2026-11-10 | 大阪・関西万博公式Webサイト。テーマ「地球、水、人間性」、見出し「土地と水と人々の物語」 | 多様な自然と地形に着想、土地・水・人々のテーマ |
| sv06 ハンガリー館 | https://www.nippon.com/en/guide-to-japan/expo2025052/ | 2026-11-10 | Nippon.com「Hungary Pavilion: Immersive Experience: One World, One Soul」（没入型体験 ひとつの世界、ひとつの心） | 大平原を思わせる緑の空間、3万本以上の細い帯、落ち葉の山のような「Immersive Dome」、農村を思わせる民族音楽のライブ |
| sv06 | https://www.expo2025.or.jp/official-participant/hungary/ | 2026-11-10 | 大阪・関西万博公式Webサイト | 中心テーマは民族音楽、ハンガリーと日本の文化の類似点 |
| sv07 ポーランドパビリオン | https://www.expo2025.or.jp/official-participant/poland/ | 2026-11-10 | 大阪・関西万博公式Webサイト。画像のクレジットに「パビリオン設計：アリシャ・クビツカ、ボルハ・マルティネス（Interplay Architects）」 | 設計者、テーマ「ポーランド。未来を切り拓く遺産」、木材を基調に創造性と革新の波が広がる外観、コンサートルームでのショパンのリサイタル |
| sv07 | https://www.nippon.com/en/guide-to-japan/expo2025056/ | 2026-11-10 | Nippon.com「Poland Pavilion: Heritage that Drives the Future」（未来を切り拓く遺産） | 日本の伝統的な木組み工法（kigumi kōhō）、波のような形とDNAのらせん、AIを使った空間アート、ショパンのリサイタル |
| sv11 チリパビリオン | https://www.expo2025.or.jp/official-participant/chile/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「マクン：人々を包むチリの織物、私たちが守る未来の社会」、集成材の構造体、マプチェ族の女性200人が織ったマント、壁3面・全長40メートルの映像 |
| sv11 | https://www.nippon.com/en/guide-to-japan/expo2025043/ | 2026-11-10 | Nippon.com「Chile Pavilion」 | 242平方メートルの幾何学模様の織物「makun」、伝統的な技法での手織り、チリの文化と持続可能な社会への取り組みを紹介する映像 |
| sv12 チュニジアパビリオン | https://www.nippon.com/en/guide-to-japan/expo2025086/ | 2026-11-10 | Nippon.com「Tunisia Pavilion: Partnership in Innovation, Science, and Technology for Saving Lives」（いのちを救うためのイノベーション・科学・技術のパートナーシップ） | モザイクと国花ジャスミンのモチーフ、ジャスミンの香り、エリッサのカルタゴ建国・ハンニバル・サハラ・現代の科学技術を紹介するモザイク画と映像 |
| sv12 | https://www.expo2025.or.jp/official-participant/tunisia/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「チュニジアの響き」 |
| sv13 カンボジア パビリオン | https://www.nippon.com/en/guide-to-japan/expo2025085/ | 2026-11-10 | Nippon.com「Cambodia Pavilion: Saving Lives」（いのちを救う） | 約30の寺院のコー・ケー遺跡に着想、アンコール・ワットの外観模型、「乳海攪拌（Churning of the Ocean）」のレリーフの再現、メコン川流域を表す黄金色の稲田、アプサラ・ダンス |
| sv13 | https://www.expo2025.or.jp/official-participant/cambodia/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「いのちを救う」、コー・ケー寺院に着想、クメールの稲作の伝統を祝う黄金色の稲田 |
| sv14 アルジェリア館 | https://www.nippon.com/en/guide-to-japan/expo2025088/ | 2026-11-10 | Nippon.com「Algeria Pavilion: Discover the Lights of Algeria」（アルジェリアの光を発見する） | 外観の「Lights of Algeria」、約240万年前の石器、銀とサンゴの古代の装身具、タッシリ・ナジェールと7つの世界遺産、アラビア語で「光」を意味するAIガイド「Nour」 |
| sv14 | https://www.expo2025.or.jp/official-participant/algeria/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「平和共存の大地」、240万年前の石器から始まる展示、7つのユネスコ世界遺産 |
| sv15 バルト館（ラトビア・リトアニア） | https://www.expo2025.or.jp/official-participant/latvia/ | 2026-11-10 | 大阪・関西万博公式Webサイト（ラトビアのページ。リトアニアのページ https://www.expo2025.or.jp/official-participant/lithuania/ も同文） | ラトビアとリトアニアの共同出展、テーマ「WE ARE ONE」、結露のしずくにメッセージを残すガラスの壁とそのはかなさ |
| sv15 | https://www.nippon.com/en/guide-to-japan/expo2025051/ | 2026-11-10 | Nippon.com「Baltic Pavilion (Latvia and Lithuania)」。マスコット名は日本語版（https://www.nippon.com/ja/guide-to-japan/expo2025051/ 、curl で確認）の「バラビちゃん」に合わせた | バルト地域の多様な自然の紹介、ポルチーニがモチーフで森の豊かさを伝えるマスコット |
| sv16 EUパビリオン | https://www.expo2025.or.jp/official-participant/eu/ | 2026-11-10 | 大阪・関西万博公式Webサイト | テーマ「未来を育む」、新欧州バウハウスの3つの理念（持続可能性・美しさ・包摂性） |
| sv16 | https://www.nippon.com/en/guide-to-japan/expo2025023/ | 2026-11-10 | Nippon.com「The European Union: Nurturing Tomorrow」（未来を育む） | 新欧州バウハウスは建設分野の脱炭素化を目指す政策、インタラクティブな展示・クイズ・トークショー、ロボットアームが手入れする禅の庭（Zen garden）、デジタル折り鶴 |
| sv18 コモンズC館 | https://www.expo2025.or.jp/official-participant/ | 2026-11-10 | 大阪・関西万博公式Webサイト「海外パビリオン アーカイブ」。各パビリオン名の「（コモンズ-C）」表記から出展国を数えた（2025年10月13日時点の情報と明記） | コモンズ-C の11か国（イスラエル、ウクライナ、ウルグアイ、ガボン、グアテマラ、クロアチア、サンマリノ、スロバキア、スロベニア、パナマ、モンテネグロ） |
| sv18 | https://www.jica.go.jp/information/topics/2025/p20250925_01.html | 2026-11-10 | JICA（国際協力機構） | コモンズは複数の国・地域が共同で出展するパビリオン、A～Fまである、予約なしで入れる手軽さが人気 |
| sv19 コモンズD館 | https://www.expo2025.or.jp/official-participant/ | 2026-11-10 | 同上。D の25か国・地域：アンティグア・バーブーダ、カメルーン、ギニア、キューバ、コンゴ、サントメ・プリンシペ、スーダン、赤道ギニア、タジキスタン、トーゴ、ナイジェリア、パキスタン、パレスチナ、ブルキナファソ、ベリーズ、ホンジュラス、マーシャル、マダガスカル、マリ、南スーダン、モルドバ、モンゴル、ラオス、リベリア、ブータン。地域の分類（アジア、アフリカ、中南米、ヨーロッパ、オセアニア）は、この一覧からの集約 | 25の国と地域、facts で挙げた国名 |
| sv19 | https://www.jica.go.jp/information/topics/2025/p20250925_01.html | 2026-11-10 | JICA | sv18 と同じ（コモンズの説明） |
| co01 ルクセンブルク館 | https://luxembourg.public.lu/en/society-and-culture/sustainable-development/architecture-pavillon-osaka.html | 2026-11-10 | Luxembourg.lu（ルクセンブルク政府の公式ポータル） | ルクセンブルクの設計事務所 STDM の設計、軽量な鋼材と膜屋根、切らずに外せる型枠パネル、解体を前提とした設計（design for disassembly） |
| co01 | https://www.nippon.com/en/guide-to-japan/expo2025063/ | 2026-11-10 | Nippon.com「Luxembourg Pavilion: Doki Doki—The Luxembourg Heartbeat」。公式サイトの和文テーマは「Doki Doki – ときめくルクセンブルク」 | テーマ、白い屋根（awning）の下の13の区画からなる箱型の建物、循環経済を意識した設計、VR・3Dスキャンで自然と暮らしを紹介 |
| co02 ドイツ館 | https://www.archdaily.com/1018244/the-german-pavilion-designed-by-lava-architects-explores-circularity-at-expo-osaka-2025 | 2026-11-10 | ArchDaily | ベルリンの LAVA（Laboratory for Visionary Architecture）の設計、木でできた7つの円形の要素、再利用できる素材 |
| co02 | https://www.nippon.com/en/guide-to-japan/expo2025045/ | 2026-11-10 | Nippon.com「Germany Pavilion: Wa! Germany」。和文の名称「わ！ドイツ」と「環・和・わ！」の表記は公式サイト（https://www.expo2025.or.jp/official-participant/germany/ 、curl で確認）に合わせた | テーマは循環経済、「Wa」の3つの意味（円・調和・Wow）、円形の木造の建物、マスコット「Circular」の案内 |
| co03 韓国館 | https://www.nippon.com/ja/guide-to-japan/expo2025041/ | 2026-11-10 | nippon.com（日本語版）「韓国パビリオン」 | 「With Hearts」のテーマ、2040年の未来社会の体験、大屋根リング側の横27メートル・縦10メートルのディスプレー、K-POPのライブ映像と観光名所の映像、来場者の声をAIでオーケストラ音楽に変換 |
| co03 | https://www.expo2025.or.jp/official-participant/korea/ | 2026-11-10 | 大阪・関西万博公式Webサイト。和文テーマ「こころに寄り添う : いのち花開く未来へ」 | テーマ「With Hearts」と和文テーマ |
| co04 コモンズF館 | https://www.expo2025.or.jp/official-participant/ | 2026-11-10 | 同上（コモンズ-F 表記） | コモンズ-F の3か国（アルメニア、カザフスタン、ブルネイ） |
| co04 | https://www.jica.go.jp/information/topics/2025/p20250925_01.html | 2026-11-10 | JICA | sv18 と同じ（コモンズの説明） |
| co05 EXPO 2025 デジタルウォレットパーク | https://www.expo2025.or.jp/news/news-20250418-03/ | 2026-11-10 | 2025年日本国際博覧会協会（公式サイト、プレスリリース 2025-04-18）。正式な表題は「EXPO2025デジタルウォレットパークのサービススタート！〜「ミート・ザ・ミャクミャク」、「デジタルウォレットミャクミャクプリクラ」、ミャクポ！deゲーム、ミャクポ！テラス利用などのサービスを開始！〜」。sources の title は副題を省いた | デジタルウォレット利用者向けの施設、ミート・ザ・ミャクミャク、休憩スペース「ミャクポ！テラス」 |
| 〃 | https://www.expo2025.or.jp/news/news-20250418-02/ | 2026-11-10 | 2025年日本国際博覧会協会（公式サイト、プレスリリース 2025-04-18） | ミャクポ！を使ったアクティビティ・ステータス特典の限定エリア（パークの説明）、デジタルトラベルゾーン（ルーム型LEDビジョン、VRゴーグル、地域の観光映像） |
| co06 アゼルバイジャン館 | https://www.expo2025.or.jp/official-participant/azerbaijan/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ（2025-10-13時点の情報） | テーマ「サステナビリティへの7つの懸け橋」、アーチを通るごとに「七つの美」をめぐる新しい章へ進む |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025017/ | 2026-11-10 | Nippon.com（ニッポンドットコム財団、2025-04-28）。英語の題「Seven Bridges for Sustainability」＝公式和訳「サステナビリティへの7つの懸け橋」 | 外観の7つの大アーチ、7つの特色と未来へのつながり、360度スクリーンで天然資源・伝統・スポーツ・観光を紹介 |
| co07 夜の地球 Earth at Nightパビリオン | https://www.expo2025.or.jp/news/news-20250317-02/ | 2026-11-10 | 博覧会協会公式サイトのプレスリリース（2025-03-17）。展示者は博覧会協会と経済産業省、協力は輪島市・石川県・日本経済団体連合会 | 輪島塗の直径1mの大型地球儀、漆黒と金の発色、能登半島地震でも無傷で復興シンボルの一つ、展示者、都市パネル（東京・ニューヨーク・北京・ロンドン）・能登の復興の様子・伝統的工芸品 |
| co08 モナコ館 | https://www.expo2025.or.jp/official-participant/monaco/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ。テーマは英語表記「Take Care of Wonder」のみ（公式和訳なし。直訳は「驚異を大切に」程度） | テーマ、館内と庭での没入型体験で環境問題への意識を高める、自然のもろさ（fallbackText）、オテル・ド・パリ・モンテカルロのセラーのワインとコニャックのワインバー |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025061/ | 2026-11-10 | Nippon.com（2025-04-28）。末尾スラッシュなしのURLは404になるため、スラッシュ付きで記載 | 地中海と日本の庭園空間に着想、植物の幹や枝を金属の構造物で表す、円筒形の映像空間で「海中」探検 |
| co09 トルコ館 | https://www.expo2025.or.jp/official-participant/turkey/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「文明の黄金時代」、外壁の波模様＝地中海と黒海、入口上の三日月と星、ホウ素でコーティングした木材のインスタレーション、ギョベクリ・テペからオスマン帝国まで |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025047/ | 2026-11-10 | Nippon.com（2025-05-11）。英語の題「Heyday of Civilizations」＝公式和訳「文明の黄金時代」 | ギョベクリ・テペが1万年以上前、館内のホウ素材の木、波模様と三日月・星（公式と重複確認） |
| co10 タイ王国館 | https://www.expo2025.or.jp/official-participant/thailand/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「大きな幸福のため、いのちをつなぐタイ」、パビリオン名「ヴィマン・タイ」 |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025040/thailand-pavilion-thailand-connecting-lives-for-greatest-happiness.html | 2026-11-10 | Nippon.com（2025-05-09）。英語のテーマ「THAILAND Connecting Lives for Greatest Happiness」＝公式和訳「大きな幸福のため、いのちをつなぐタイ」 | サラ・タイ様式の建築を思わせるデザイン、入口の木彫りの象、3つのゾーン（伝統的な健康の知恵／医療・公衆衛生／ハーブ・アロマ） |
| co11 スペイン館 | https://www.accioncultural.es/en/ExpoSpain2025 | 2026-11-10 | Acción Cultural Española（AC/E、スペイン館の出展主体） | 2023年のAC/E公募でNéstor Montenegro・Enorme Studio・Smart and Green Designが受注、黒潮をコンセプト、リサイクル材・再生可能な素材で建設 |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025038/ | 2026-11-10 | Nippon.com（2025-05-02）。英語の題「Kuroshio Current」＝「黒潮」 | テーマ黒潮（大航海時代にアジアへ向かう船を運んだ海流）、深海のように暗い館内、海の生き物・ブルーエコノミー・日本との交流史 |
| co13 オーストラリア館 | https://buchan.au/media/construction-starts-on-australia-pavilion-for-expo-2025-osaka/ | 2026-11-10 | Buchan（設計者の公式サイト、着工時のニュース） | Buchanが主任設計者・建築家、日建設計と協力、ユーカリ（gumnut＝ユーカリの実）を抽象化したデザイン |
| 〃 | https://www.expo2025.or.jp/official-participant/australia/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ。テーマは公式表記「Chasing the Sun ― 太陽の大地へ」 | ユーカリの花から着想した外観、過去の国際的な大規模イベントの建築資材などを再利用、テーマ、太陽を追う没入型体験 |
| co14 インドネシア館 | https://www.expo2025.or.jp/official-participant/indonesia/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「調和の中で繁栄する：自然、文化、未来」、船の形と、前進・成長・困難を越える航海の意味 |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025021/ | 2026-11-10 | Nippon.com（2025-05-01）。英語の題「Thriving in Harmony」＝公式和訳「調和の中で繁栄する」 | 船はインドネシアの大切な象徴、小さな熱帯林、自然保護・再生可能エネルギー、約1,300の民族の工芸・食文化、新首都ヌサンタラ |
| co15 ウズベキスタン館 | https://www.dezeen.com/2025/04/10/uzbekistan-pavilion-expo-2025-osaka-atelier-bruckner/ | 2026-11-10 | Dezeen（2025-04-10） | ドイツのAtelier Brücknerが設計、キャラバンサライに着想、2層構成（レンガで覆った土台／森のような木の柱）、柱の木材は大阪の森から |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025022/ | 2026-11-10 | Nippon.com（2025-05-01）。英語のテーマ「Garden of Knowledge: A Laboratory for a Future Society」＝公式和訳「知識の庭 – 未来社会のための実験室」 | 木材は大阪近郊で伐採したスギ、万博後にウズベキスタンへ運び教育施設に再利用する計画、テーマ |
| co16 セルビア館 | https://www.expo2025.or.jp/official-participant/serbia/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | 副題「浮遊する森（Floating Forest）」、テーマ「Society of Play（遊びの社会）」、都市と自然が出会う風景、2027年ベオグラード万博の予告 |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025039/ | 2026-11-10 | Nippon.com（2025-05-02） | ベオグラード中心部を流れるドナウ川の小さな島々を模したデザイン、学びと交流を組み合わせた9つのステージ |
| co17 バングラデシュ館 | https://www.expo2025.or.jp/official-participant/bangladesh/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「いのちをつなぐ：伝統とイノベーションが調和する国」、環境に配慮した低炭素の素材、ナクシ・カンタ、ジャムダニ、ジュート |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025090/ | 2026-11-10 | Nippon.com（2025-07-09）。英語の題「A Symphony of Tradition and Innovation」 | 展示の中心は伝統工芸で主要輸出品の繊維製品、ジュート＝「黄金の繊維」、大型液晶画面（稲作など）、精巧な模型（河川の地形、暮らしの移り変わり） |
| co18 セネガル館 | https://www.expo2025.or.jp/official-participant/senegal/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「持続可能で公平な開発のために人々を結ぶ交差点」、構想「セネガル2050」 |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025091/ | 2026-11-10 | Nippon.com（2025-07-09）。英語の題「Connecting People Toward Sustainable and Equitable Development」＝公式テーマとほぼ同義 | 映像・パネルで主要産業と2050年までの開発目標、ダカール2026ユースオリンピック、頭上のジュッジ国立鳥類保護区とゴレ島の風景画（いずれも世界遺産） |
| co19 エジプト館 | https://www.expo2025.or.jp/official-participant/egypt/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「モダンエジプト　受け継ぎ、紡ぎ、未来へ」、古代文明と現代の発展を旅としてたどる、新行政首都・スエズ運河経済特区・大エジプト博物館の3つの国家プロジェクト |
| 〃 | https://www.nippon.com/en/articles/-/15476 | 2026-11-10 | Nippon.com（2025-05-08）。guide-to-japan 形式のURLが見つからず、記事ページのURLを記載。英語の題「Legacy Empowering Future」（直訳「未来を力づける遺産」） | 展示室の壁に映す映像で古代遺跡・秘宝、再生可能エネルギーの取り組み |
| co20 インドパビリオン - バーラト | https://www.expo2025.or.jp/official-participant/india/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ | テーマ「バーラト―体験し､記憶し､受け継がれるもの―」、ロータス・コートヤードのパドマパニと菩提樹、チャンドラヤーン3号の縮尺模型、屋根の72,576個のLED |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025020/ | 2026-11-10 | Nippon.com（2025-05-08） | ヒマラヤに着想を得た外観、古代の仏教壁画、薬草で人々を救ったハヌマーンの描写 |
| co21 コモンズB館 | https://www.jica.go.jp/information/blog/1572398_21942.html | 2026-11-10 | 国際協力機構（JICA）ブログ（2025-08-06） | コモンズ＝共同館、従来の地域別ではなく3つのサブテーマ別の展示、ドミニカ共和国がコモンズB館で日本の国際協力を紹介 |
| 〃 | https://www.expo2025.or.jp/official-participant/cote-divoire/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ（ページ名に「コモンズ-B」と明記） | コートジボワールがコモンズ-Bに出展、テーマ「カカオとともに歩む国 コートジボワールの軌跡」（カカオ生産の歩み） |
| co22 ネパール館 | https://www.expo2025.or.jp/official-participant/nepal/ | 2026-11-10 | 博覧会協会公式サイトの出展者ページ（建築家名は本文に記載） | 建築家プラジュワル・ハダの設計、スワヤンブナートのストゥーパに着想、蓮の花から生まれたという言い伝え（スワヤンブ・プラーナ） |
| 〃 | https://www.nippon.com/en/guide-to-japan/expo2025048/nepal-pavilion-sharing-sights-and-culture-from-the-roof-of-the-world.html | 2026-11-10 | Nippon.com（2025-07-19）。英語の題「Sharing Sights and Culture from the Roof of the World」（直訳「世界の屋根から景色と文化を届ける」） | ヒマラヤの景観・多様な文化・仏教美術の展示、シンギングボウルを鳴らす体験 |

### 見送った施設と情報（r5）

- コモンズE館（sv20）は登録していない。公式の海外パビリオン一覧に「コモンズ-E」の表示がある出展がなく、施設を説明する確かな出典を取得できなかった。
- 次の情報は、出典にあっても、確認できない・食い違う・最上級の表現・国民性の記述などの理由で facts に入れなかった。
- **ミャクミャクハウス（emp12）**：ハウス自体を説明する公式ページ（expo2025.or.jp など）は見つからなかった。施設の説明は GIGAZINE の開幕前の取材記事1本だけが根拠。開館時間（10:00〜19:00）と撮影会は、撮影場所に関わるため facts から外した。会期後の巡回展「出張！ミャクミャクハウス」は別の催しのため使っていない。
- **最上級・記録の表現**：次の記述は出典にあったが、方針に従って書かなかった。
  - スイス館「万博で最も CO2 排出の少ない建物」「構造の総重量450kg」（Nippon.com。重量は膜部分だけの数字の可能性があり、誤解を招くおそれがある）
  - 飯田グループ館「世界最大の西陣織で包まれた建物」（ギネス世界記録。面積3,027.75㎡は Guinness 公式ページで確認した）、「世界最大の扇子形の屋根」（検索の抜粋のみで未取得）
  - フィリピン館「フィリピンの織り手による一つのプロジェクトとして最大の協働」（Arch2O）
  - よしもと館「笑顔の検知数1000万でギネス認定」（公式サイトのニュース見出しのみ）
  - ウーマンズ パビリオンのファサード部材の再利用率約98％（Arup）は、数値の裏づけはあるが文字数を抑えるため省いた
- **出典で確認できなかったため書かなかった情報**
  - 住友館：設計者名、館内の行灯・シアターの詳細（時事通信の抜粋のみで未取得）。「住友の森」の木約1,000本（住友グループのファサード公開ページで確認したが、出典を2件に絞るため外した）
  - NTT Pavilion：設計者名（Architizer は 403 で取得できず。受賞記録の検索抜粋に NTT ファシリティーズの名前があるだけ）
  - 関西パビリオン：設計者名（京都府の PDF は本文を読めなかった）
  - 大阪ヘルスケアパビリオン：ETFE 膜、施工の竹中工務店、延床面積（資料ごとに約8,000〜9,800㎡と食い違う）
  - ガスパビリオン：基本設計・日建設計、実施設計・日建設計と奥村組の JV、仮設山留用のリース鉄骨（GBRC の PDF が暗号化されていて読めず、博覧会協会のリリースは役割を明記していない）
  - ORA外食パビリオン：設計者と外観（見つからなかった）
  - ペルー館・モザンビーク館：設計者、建物の構造・素材（見つからなかった）
  - ヨルダン館：建築設計者名（見つからなかった）
  - PASONA NATUREVERSE：会期後に淡路島へ移築する計画（designboom）。計画段階の情報のため外した。鉄腕アトムが建物の先端に立つ演出（Nippon.com）は、方角の記述を伴うため外した
  - マレーシア館：テーマ名「Weaving a Future in Harmony」と設計者側のコンセプト「Interwoven」が出典によって違うため、テーマ名は書かなかった
  - コモンズA館：コモンズの国数は「約80」「89」など資料で幅があるため、A館の29か国（公式一覧）だけを書いた
- **出典の性格**：大阪ヘルスケアパビリオンとフィリピン館は Arch2O（建築メディア。設計者提供の説明を載せる）、飯田グループ館は WWDJAPAN（ファッション業界紙）、ORA は日本食糧新聞（業界紙）を使った。Dezeen や ArchDaily で同じ内容を確認できなかったための代替で、レビューで差し替えを検討してほしい。
- **モザンビーク館の位置づけ**：JICA ブログでは、モザンビークとヨルダンはコモンズではなく「タイプB」の出展とされている。facts では区分に触れていない。
- **アラブ首長国連邦館**：ナツメヤシが「国民性を象徴する」という記述（Nippon.com）。国の文化を一様な特性として語ることになるため。ATELIER BRÜCKNER を展示デザイナーとする Dezeen Awards のロングリストのページは取得できたが、建築の設計者と役割の分担がはっきりしないため使わなかった。BIE の記事は 403 で取得できなかった。
- **カナダ館**：「カナダの温かさと前向きさ」（Nippon.com）。国民性の記述になるため。部材の55%が借りもの・再利用という数字は検索スニペットにしかなく、取得したページで確かめられなかった。公式サイト（canadaexpo2025.ca）は AR タブレットに触れておらず、来場者が自由に歩き回る体験として書いている。タブレットは Nippon.com の記述だけに基づく。ルパージュの役割は、Canadian Architect では「artistic advisor」、公式サイトでは展示演出の「artistic director」となっている。facts は前者（構想発表時の記事）に合わせた。
- **ポルトガル館**：ロープ9,972本・約60トン、来場者230万人超。検索スニペットだけで、取得したページでは確かめていない。
- **オーストリア館**：らせんの高さ16m。取得したページ（ArchDaily）に記載がなかった。ウィーン少年合唱団などの5月の催しは、会期中の一時的な内容なので入れなかった。
- **ブラジル館**：Studio MK27 の設計案（2023年のコンペ）。実際に建った建物と同じかを、取得したページで確かめられなかった。
- **クウェート館**：構造設計 schlaich bergermann partner や施工者などの体制。検索スニペットだけだった。
- **中華人民共和国館**：面積と「国際パビリオンで最大」という記述。Nippon.com は約3,870m²、公式プレスリリース（Kyodo News PR Wire、取得済み）は約3,509m²と食い違っており、最上級の表現でもあるため。嫦娥6号の試料が「初めて採取されたもの」という記述も、最上級の表現なので入れなかった。崔愷（Cui Kai）の関与は ArchDaily に記載があるが、facts は CADG にとどめた。
- **国際機関館・国際連合館・国際赤十字・赤新月運動館**：建物の設計者・構造に触れた出典は取得できなかった。指示に従い、出典にある館の展示内容だけを書いた。
- **トルクメニスタン館**：設計者（Belli Creative／ES "Belli"）と来場者数。トルクメニスタンの政府系サイトの検索スニペットだけで、ページを取得して確かめていない。
- **北欧館**：施工者 RIMOND、屋上レストラン、ムーミン関連の物販。設計に関係しない内容なので省いた。
- **マルタ館**：設計者（Edwin Mintoff Architects と思われる）。検索スニペットだけで、取得したページでは確かめていない。マルタ料理のテラスも省いた。
- **チェコ館**：ギャラリーの長さ。Nippon.com は250m、Dezeen は260mと食い違うため入れなかった。Rony Plesl のガラス彫刻と Masker の壁画は、文字数の都合で省いた。
- **いのちの未来**：展示・空間ディレクターの遠藤治郎、施工の長谷工・不二建設は文字数の都合で省いた。外壁が「真っ黒なポリ塩化ビニールとカーボンファイバーメッシュ膜の二重構成」という記述は、検索スニペットだけで（GBRC の PDF は暗号化されていて読めなかった）入れなかった。
- **いのちの動的平衡館**：構造設計 Arup と施工の鹿島建設。GBRC の PDF を読めず、検索スニペットだけだった。クラスラが表す生命史の年数は、Nippon.com の要約（32億年）と検索スニペット（38億年）が食い違うため入れなかった。r1 の displayName は「いのちの動的平衡館」だが、公式名は「いのち動的平衡館」。name は指示どおり r1 に合わせた。
- **いのちめぐる冒険**：建築の設計者は、取得したどの出典にも記載がなかった。
- **EARTH MART**：「空想のスーパーマーケット」という公式の表現は検索スニペットだけだったので、Nippon.com の「imaginary marketplace」を「空想の市場」と訳した。2025-03-19 の公式プレスリリースも取得したが、建築家と卵の数の記載がないため出典にしなかった。
- **sv20 コモンズE館（エントリーごと見送り）**：公式サイトの「海外パビリオン アーカイブ」には「コモンズ-E」の表記を持つパビリオンが1つもなかった。JICA の記事も A～F の総称にしか触れていない。ハピエル（happyell.co.jp）の記事に「企画展のコモンズEを除く」とあるだけで、出展国や企画展の内容を確かめられる公式・報道の出典を取得できなかった。検索結果にあったブログの「コモンズE：オーストラリア、ジャマイカ、フィジー」は、公式一覧（ジャマイカ・フィジーはコモンズ-B、オーストラリアは単独館）と食い違うため使わなかった。
- **シンガポールのアルミ円盤の枚数**：Nippon.com と DP Architects は約1万7000枚、The Star などの報道は2万枚以上としている。Nippon.com の数字を採った。ArchDaily は枚数を書いていない。デザインの着想も、Nippon.com は「絵馬」、ArchDaily は愛称「Little Red Dot」としている。facts には取得した Nippon.com の「絵馬」を採った。
- **ブルガリアの設計者**：公式ページに「Daiwa Lease Co., Ltd. & Kobayashi Maki Design Workshop (KMDW) & BSMEPA」「arch Mariya Gospodinova, Iskren Krusteff」というクレジットがある。ただ画像のクレジットなのか設計の担当なのかがページから読み取れないため、書かなかった。
- **バルト館の「未来の壁」**：Nippon.com はタッチスクリーンにメッセージが表示されると書き、公式ページは結露のしずくにメッセージを残すガラスの壁と書いている。公式の説明を採った。
- **ルクセンブルク館の会期後の移設**：Nippon.com には、会期後に大阪府交野市へ移して子育て支援施設にするとある。facts の文字数を抑えるため省いた。移設先の現状は確かめていない。
- **Dialogue Theater の設計者**：PDF の画像クレジット「© Naomi Kawase / SUO」はあるが、建築設計者の名前は本文に明記されていなかったため書かなかった。イチョウのシンボルツリー、「記憶の庭」、吉野杉の使用、会期中の対話の回数（Nippon.com は約1840回を予定と記載）も、文字数の都合で省いた。
- **オランダ館の Miffy、ドイツ館・ルクセンブルク館・チリ館などの飲食**：見どころとして小さいため省いた。
- **ポーランドの「創造性遺伝子」**：公式ページには「創造性豊かな人々を主な資源とする国」「創造性遺伝子が代々継承」という記述がある。国民性を一律に語る表現になるため使わなかった。建物の形が表す「創造性と革新」だけを残した。
- **コモンズの「途上国の多くが出展」**：JICA の記事にある記述だが、出展国をひとくくりに特徴づけることになるため使わなかった。
- **各国のナショナルデー**：会期中のイベント日程で、建物の解説ではないため省いた。
- **「最大」「初」などの表現**：該当する公式の明示がないため使っていない。アルジェリアの「アフリカ大陸最大の国」（公式ページ）も、パビリオンの説明ではないため省いた。
- **co06 アゼルバイジャン館の設計者**：公式ページで「ELEVEN & Bellprat Partner」は画像のクレジットにしかなく、本文で設計者と書かれていないため使わなかった。Nippon.com の写真説明にある「伝統的なステンドグラスの格子細工に着想」も、本文の記述ではないため入れなかった。
- **co08 モナコ館の設計者**：公式ページの画像クレジット「Jerome Hein Architecte & Atelier Pierre」は役割が書かれていないため使わなかった。
- **co09 トルコ館の設計者**：公式ページの画像クレジット「Pollmark Corporation」は役割が不明なため使わなかった。
- **co10 タイ王国館**：公式ページの「RMA110」というキャプションは意味が不明なため使わなかった。
- **co11 スペイン館**：BIE の建築部門銀賞は、AC/E のページでニュース見出しとしてしか確認できなかったため入れなかった。入口の大階段（Nippon.com）は facts の字数の都合で省いた。設計者のうちネストル・モンテネグロの事務所名を「EXTUDIO」とする表記もあるが、個人名で記載した。
- **co13 オーストラリア館**：外観の着想は Buchan が「ユーカリの実（gumnut）」、公式が「ユーカリの花」と書き分けているため、facts では「ユーカリに着想」にとどめた。Nippon.com の香りや音、先住民の文化公演、カンガルー像（写真のみ）は使わなかった。
- **co15 ウズベキスタン館**：可動式の床（Dezeen）と、延床面積（Nippon.com は約750㎡、検索結果に出た ArchDaily の記事は 1,272㎡ と 840㎡ で食い違う。ArchDaily は未取得）は入れなかった。Dezeen には会期後の再利用計画の記述がないため、再利用計画は Nippon.com だけを根拠にしている。
- **co16 セルビア館**：公式ページの画像ファイル名から読み取れるレストランやギャラリーは、本文で確認できないため使わなかった。
- **co18 セネガル館**：ダカール2026ユース五輪が「アフリカ大陸で初めての五輪」という Nippon.com の記述は、最上級の表現にあたるため省いた。ゴレ島が奴隷貿易の拠点だったという説明は、字数とガイドの文脈を考えて facts に入れず、世界遺産としてのみ記載した。
- **co19 エジプト館**：建物の設計者・構造・延床面積（3,000㎡という報道もある）は、取得した公式・Nippon.com のページに記述がなく、検索スニペットだけでは採用しなかった。JICA のページでエジプト・セネガル・バングラデシュは「タイプB（博覧会協会が建てた施設内に独立した展示スペースを設ける形態）」とされているが、各館の sources を 2 件に収めるため使わなかった。
- **co20 インドパビリオン - バーラト**：Nippon.com の医療・宇宙技術という展示の重点は、字数の都合で省いた。
- **co21 コモンズB館**：出展国の数（来場者の記録などで 24 か国・29 か国と食い違う）と、B館がどのサブテーマにあたるかは、信頼できる出典で確認できなかったため入れなかった。コモンズの棟数（A〜F の 6 棟、Gizmodo Japan）も、公式の出典で確認できなかったため使わなかった。建物は博覧会協会が建てたという「タイプC 共同館」の定義は公式の公募ページ（https://www.expo2025.or.jp/news/news-20241028-02/）にあるが、そのページの対象はコモンズ-C・E・F で B を含まないため使わなかった。
- **co22 ネパール館**：Nippon.com の「最後に開館した（2025年7月19日）」は、建物や展示の説明ではないため省いた。
- **co07 夜の地球**：検索スニペットにあった「イランパビリオンの予定地の代替施設」「重さ215kg」は、取得した公式ページに記述がないため使わなかった。
- **co05 デジタルウォレットパーク**：Impress Watch（2024-12-05）にある「約230席」は開幕前の予告であり、公式の開業時の発表で確認できなかったため使わなかった。

## 採用元の申告と公開前の確認（2026-11-10更新）

2026-11-09時点で、チームから3DデータはPLATEAU、地図画像は国土地理院、ソフトウェアはFlutterと各種パッケージを使用する旨の申告があった。
その後に記録した英国パビリオンの会場図は、上表のとおりPLATEAU由来の当たり判定・建物外形から作成している。国土地理院の画像として一括して扱わない。国土地理院素材の採用箇所は実ファイルとの対応が確認できるまで未確定とする。
提供元の申告と、個々のファイルの利用条件・公開許諾の確認は分けて記録する。
現時点でこの申告だけを根拠に、上の仮seedを公開可能とは扱わない。

| 対象 | 提供元・参照先 | 確認できた条件 | 残る確認 |
| --- | --- | --- | --- |
| 3Dデータ | PLATEAU。[仕様書が参照する万博データ](https://www.geospatial.jp/ckan/dataset/plateau-27999-osaka-shi-2025) | [万博データ専用規約](https://gic-plateau.s3.ap-northeast-1.amazonaws.com/2025/expo-doc/3d-license/license.pdf)には、商業目的・販売促進・広告利用・商品化などの営利目的での使用禁止がある。一般のPLATEAUサイトの規約だけで判断しない | 実際のダウンロードファイル・取得日・版、テクスチャ等の個別条件、加工・同梱配布・デモ動画・コンテスト提出への適用。規約から判断できない用途は提供元へ確認し、回答を非公開で保存 |
| 国土地理院由来の地図画像（採用箇所は未確定） | 国土地理院。[利用規約](https://www.gsi.go.jp/kikakuchousei/kikakuchousei40182.html)・[地理院タイル一覧](https://maps.gsi.go.jp/development/ichiran.html) | 出典と、編集・加工した場合はその旨を明示する。利用する測量成果と加工方法によって手続が異なる | 実際の画像・タイル名・取得URL・取得日、第三者の権利表示、加工内容。[利用手続ナビ](https://service.gsi.go.jp/onestop/navi/nav1/)で保存画像の配信・同梱方法を確認。リアルタイム読込の申請不要条件を保存画像へそのまま適用しない |
| Flutter・各種パッケージ | `app/pubspec.yaml`、`app/pubspec.lock`、`app/vendor/` | パッケージごとのライセンス本文・著作権表示を配布物に含めるための一覧を用意する | 実際の提出ビルドに含まれるライセンスの抽出と閲覧導線を確認。自動抽出に含まれないvendor変更、フォント・アイコン、ネイティブ依存のNOTICE等も確認 |

### 公開用クレジットの作成

以下は表記の下書きであり、実ファイルと条件の照合後に確定する。出典表記だけで利用許諾を得たことにはしない。

- 3D：`2025年大阪・関西万博3D都市モデル（Project PLATEAU／国土交通省）を加工して使用`。実データの提供元指定の表記がある場合はそれを優先する。
- 英国パビリオンの会場図：PLATEAU由来の加工物として、3Dデータとの対応と加工内容を示す。
- 国土地理院素材を採用する場合：`国土地理院の［実際の地図・タイル名］を加工して作成`。未加工の場合は加工したと書かず、取得元へのリンクを添える。英国パビリオンの会場図へこの表記を転用しない。
- OSS：提出ビルドに対応する各パッケージのライセンス本文・著作権表示。提供元リンクだけで本文の代用にしない。

確定した素材の出典名・URLは出題版の`credits`に登録し、既存の設定画面へ渡す。
この文書の追加ではアプリ表示・seed・OSS一覧生成を変更していない。

### #3で残す記録

- [ ] 3Dと地図の実ファイル、取得元URL、取得日、版、加工内容を対応付ける。
- [ ] 3D専用規約と地図の利用手続について、今回の配布・提出方法での判断根拠を保存する。
- [ ] 出題写真の撮影者、掲載・配信・動画利用の了承、写り込みを確認する。上表に撮影者本人からの提供は記録済みだが、用途別の了承・写り込みの確認とは区別する。
- [ ] 必要なクレジットを出題版・アプリ・提出資料・著作物利用シートへ反映する。
- [ ] OSSライセンス一覧を提出ビルドで確認し、vendor等の漏れを点検する。

許諾メール・個人情報を含む原本は公開Gitへ追加しない。公開可能な結論と証跡の管理先だけを記録する。
