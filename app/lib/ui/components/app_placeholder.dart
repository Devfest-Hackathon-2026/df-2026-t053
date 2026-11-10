import 'package:app/utils/color.dart';import 'package:material_ui/material_ui.dart';

class AppPlaceholder extends StatelessWidget {
  const AppPlaceholder({
    super.key,
    required this.color,
    this.label = '',
    this.minHeight = 220,
    this.radius = 16,
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: .w700,
      letterSpacing: .06,
      color: AppColor.white,
    ),
  });

  final Color color;
  final String label;
  final double minHeight;
  final double radius;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: .center,
      child: Text(label, textAlign: .center, style: textStyle),
    );
  }
}
