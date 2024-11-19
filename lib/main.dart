import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Configure Flutter to run code before starting the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load the settings controller and environment variables
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await dotenv.load(fileName: ".env");

  // Run the application
  runApp(MyApp(settingsController: settingsController));
}
