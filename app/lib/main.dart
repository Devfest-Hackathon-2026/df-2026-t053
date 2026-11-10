import 'package:app/app.dart';
import 'package:app/utils/orientation.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockLandscapeOrientation();
  runApp(const GdgHackApp());
}
