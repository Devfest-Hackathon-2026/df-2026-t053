/// bootstrap を適用する環境。クラウドは prod だけ（docs/infrastructure.md 4）。
///
/// プロジェクト ID は INF-01 の値。課金アカウントは公開用サンプル。
enum Env({
  /// GCP のプロジェクト ID。
  required final String projectId,

  /// GCP のプロジェクト番号。
  required final String projectNumber,

  /// state を置く GCS バケット。null ならローカルの state ファイル。
  required final String? stateBucket,

  /// 予算通知の課金アカウント ID。null なら予算を作らない。
  required final String? billingAccount,

  /// 予算の月額（円）。
  required final int monthlyBudgetJpy,
}) {
  prod(
    projectId: 'gdg-hack-514011',
    // 予算の対象（projects/<番号>）。data source で引くと、bootstrap が有効にする
    // Cloud Resource Manager API を先に要求してしまうため、値で持つ。
    projectNumber: '88648067616',
    // 初回はローカルの state で適用し、作った tfstate バケットへ `terradart state migrate` で移した。
    stateBucket: 'gdg-hack-514011-tfstate',
    // 公開用のサンプル。配備前に自分の課金アカウントへ置き換える。null なら予算を作らない。
    billingAccount: '000000-000000-000000',
    // 予算の月額（円）。INF-06 で確定する。
    monthlyBudgetJpy: 5000,
  );

  /// リソースを置くリージョン。
  String get region => 'asia-northeast1';

  /// このパッケージが作る tfstate バケットの名前。
  String get tfstateBucketName => '$projectId-tfstate';
}

/// WIF で信頼する GitHub リポジトリ（`owner/name`）。workflow_ref の照合に使う。
const String githubRepositoryFullName = 'penguins-osaka/gdg_hack';

/// リポジトリの数値 ID。名前の付け替えに影響されないので、条件の主キーにする。
const String githubRepositoryId = '1448133740';

/// 本番の配備を許すワークフロー。
const String githubDeployWorkflow = '.github/workflows/deploy.yml';
