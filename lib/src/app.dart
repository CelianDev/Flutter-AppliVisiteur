import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'settings/settings_controller.dart';
import 'login/login_view.dart';
import 'home_view.dart';
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
        // Ton UserProvider
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Ton LoginService / LoginModel
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
            theme: _buildCustomTheme(),
            locale: AppConstants.defaultLocale,
            supportedLocales: AppConstants.supportedLocales,
            localizationsDelegates: AppConstants.localizationsDelegates,
            initialRoute: _getInitialRoute(context),
            onGenerateRoute: (RouteSettings routeSettings) =>
                _generateRoute(context, routeSettings),
          );
        },
      ),
    );
  }

  ThemeData _buildCustomTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
        secondary: AppColors.secondaryColor,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      canvasColor: AppColors.canvasColor,
      textTheme: const TextTheme(
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        labelLarge: AppTextStyles.labelLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.elevatedButtonBackground,
          foregroundColor: AppColors.elevatedButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: AppPadding.elevatedButtonPadding,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.inputFocusedBorderColor),
        ),
        contentPadding: AppPadding.inputContentPadding,
        labelStyle: const TextStyle(color: AppColors.inputLabelColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        elevation: 4,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.textCursorColor,
        selectionColor: AppColors.textSelectionColor,
      ),
      iconTheme: const IconThemeData(color: AppColors.iconColor),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppColors.textButtonColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.outlinedButtonBorderColor),
          foregroundColor: AppColors.outlinedButtonForegroundColor,
        ),
      ),
    );
  }

  String _getInitialRoute(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    if (loginModel.isLoggedIn == null) {
      return AppRoutes.loadingRoute;
    }
    return loginModel.isLoggedIn ? HomeView.routeName : LoginView.routeName;
  }

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
      case AppRoutes.loadingRoute:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page non trouvée')),
          ),
        );
    }
  }
}

// Constants for app-wide values
class AppConstants {
  static const Locale defaultLocale = Locale('fr', 'FR');
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ];
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// Constants for colors
class AppColors {
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color canvasColor = Colors.white;
  static const Color elevatedButtonBackground = Colors.blue;
  static const Color elevatedButtonForeground = Colors.white;
  static const Color inputFillColor = Colors.white;
  static const Color inputBorderColor = Colors.blue;
  static const Color inputFocusedBorderColor = Colors.blue;
  static const Color inputLabelColor = Colors.blue;
  static const Color appBarBackground = Colors.blue;
  static const Color textCursorColor = Colors.blue;
  static const Color textSelectionColor = Colors.blue;
  static const Color iconColor = Colors.blue;
  static const Color textButtonColor = Colors.blue;
  static const Color outlinedButtonBorderColor = Colors.blue;
  static const Color outlinedButtonForegroundColor = Colors.blue;
}

// Constants for padding
class AppPadding {
  static const EdgeInsets elevatedButtonPadding =
      EdgeInsets.symmetric(vertical: 12, horizontal: 24);
  static const EdgeInsets inputContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

// Constants for text styles
class AppTextStyles {
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Roboto_Condensed',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Roboto_Condensed',
    fontSize: 16,
    color: Colors.black,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Roboto_Condensed',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Roboto_Condensed',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// Constants for routes
class AppRoutes {
  static const String loadingRoute = '/loading';
}
