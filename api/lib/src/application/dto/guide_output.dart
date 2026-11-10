import 'dart:typed_data';

import 'guide_text_result.dart';

sealed class GuideOutput();
class GuideTextOutput(final GuideTextResult result, final List<String> names)
    extends GuideOutput;
class GuideAudioOutput(final int sequence, final ByteData data, final bool last)
    extends GuideOutput;

enum GuideAudioFailure() {
  textFallback,
  ttsFailed,
  timeout,
  disabled,
}

class GuideUnavailableOutput(final GuideAudioFailure reason)
    extends GuideOutput;
