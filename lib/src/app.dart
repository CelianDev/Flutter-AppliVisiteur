import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings/settings_controller.dart';
import 'login/login_view.dart';
import 'dashboard/dashboard_view.dart';
import 'login/login_model.dart';
import 'login/login_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
                        return LoginView();
                    case DashboardView.routeName:
                        return const DashboardView();

    return MultiProvider(
      providers: [
        Provider<LoginService>(create: (_) => LoginService()),
        ChangeNotifierProvider<LoginModel>(
          create: (context) => LoginModel(context.read<LoginService>()),
        ),
      ],
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'app',
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case LoginView.routeName:
                      return LoginView();
                    default:
                      return LoginView();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
