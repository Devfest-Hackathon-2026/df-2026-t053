# AGENTS.md（TerraDart パッケージ）

リポジトリの [`AGENTS.md`](../../../AGENTS.md) と [`infrastructure/terradart/README.md`](../README.md) に従う。
TerraDart の API と引数の書き方は Agent Skill `terradart`（`.agents/skills/terradart`、CLI と同じ 0.36.0）を読む。

- `terradart` は `dart run terradart_cli:terradart` で呼ぶ。`terraform`・`tofu` を直接呼ばない。
- 実行のたびに変わる値（image の digest など）は Terraform 変数にせず、`bin/infra.dart` で環境変数から読む。
- `tf-out/` と `.terradart/` は生成物。`tf-out/prod/.terraform.lock.hcl` 以外はコミットしない。
- `apply`・`destroy`・`state` の操作は、人が plan を確認して指示したときだけ行う。`--auto-approve` を自分の判断で付けない。
- 部品のファイルは resource を返す関数だけを持ち、`add(...)` は `lib/stack.dart` だけが呼ぶ。
