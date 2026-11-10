import '../../domain/exceptions.dart';

/// 提出版のガイドが受け付ける locale。検査はこの関数だけが行う。
void rejectUnsupportedGuideLocale(String locale) {
  if (locale != 'ja-JP') {
    throw const GuidePreconditionException(.unsupportedLocale);
  }
}

/// ガイドを止めてある。endpoint の同期検査と、生成開始時の検査が同じ例外を使う。
Never rejectDisabledGuide() {
  throw const GuidePreconditionException(.disabled);
}
