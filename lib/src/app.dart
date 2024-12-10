import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings/settings_controller.dart';
import 'login/login_view.dart';
import 'home_view.dart'; // Utilisation de HomeView comme point d'entrée après connexion
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
    return MultiProvider(
      providers: [
        Provider<LoginService>(create: (_) => LoginService()),
        ChangeNotifierProvider<LoginModel>(
          create: (context) => LoginModel(context.read<LoginService>()),
        ),
      ],
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'app',
            initialRoute: _getInitialRoute(context),
            onGenerateRoute: (RouteSettings routeSettings) {
              return _generateRoute(context, routeSettings);
            },
          );
        },
      ),
    );
  }

  // Détermine la route initiale en fonction de l'état de connexion
  String _getInitialRoute(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    return loginModel.isLoggedIn
        ? HomeView.routeName // Redirige vers HomeView pour gérer le menu fixe
        : LoginView.routeName;
  }

  // Gère les routes dynamiquement
  Route<dynamic> _generateRoute(
      BuildContext context, RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case LoginView.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const LoginView(),
        );
      case HomeView.routeName:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const HomeView(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
        );
    }
  }
}
