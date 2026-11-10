# APIテスト専用seed

`sample-plaza/r1`・`r2` は自作の仮画像・座標・説明文を使うテストデータです。
本番用の `content/seeds/` から分離し、ローカル起動や本番配備には使用しません。
`pavilions.yaml` は仮施設3件を含むテスト専用マスターです。
実在施設の出典・利用条件は [content/provenance/README.md](../../../../content/provenance/README.md) を参照してください。

テストは `api/` を作業ディレクトリとして、このディレクトリを読み取ります。
