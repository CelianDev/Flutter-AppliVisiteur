import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    // Configurer la barre d'état pour qu'elle soit transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        tertiary: AppColors.accentColor,
        background: AppColors.scaffoldBackgroundColor,
        surface: AppColors.surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      canvasColor: AppColors.canvasColor,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textColor,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.disabledColor;
              }
              return AppColors.primaryColor;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevation: MaterialStateProperty.all(2),
          shadowColor: MaterialStateProperty.all(AppColors.shadowColor),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textColor.withOpacity(0.7),
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textColor.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primaryColor;
          }
          return AppColors.textColor.withOpacity(0.7);
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.primaryColor;
          }
          return AppColors.textColor.withOpacity(0.7);
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: AppColors.shadowColor,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryColor.withOpacity(0.3),
        selectionHandleColor: AppColors.primaryColor,
      ),
      iconTheme: IconThemeData(color: AppColors.iconColor),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
          foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        contentTextStyle: GoogleFonts.poppins(
          color: AppColors.textColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textColor,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        disabledColor: AppColors.disabledColor,
        selectedColor: AppColors.primaryColor,
        secondarySelectedColor: AppColors.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textColor,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.disabledColor;
            }
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryColor;
            }
            return Colors.transparent;
          },
        ),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.borderColor, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.disabledColor;
            }
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryColor;
            }
            return AppColors.borderColor;
          },
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.disabledColor;
            }
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryColor;
            }
            return Colors.white;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.disabledColor.withOpacity(0.5);
            }
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryColor.withOpacity(0.5);
            }
            return AppColors.borderColor.withOpacity(0.5);
          },
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
        circularTrackColor: AppColors.primaryColor.withOpacity(0.2),
        linearTrackColor: AppColors.primaryColor.withOpacity(0.2),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        elevation: 8,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textColor.withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textColor.withOpacity(0.6),
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.tooltipBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // Pas besoin d'extensions pour les animations
    );
  }

  String _getInitialRoute(BuildContext context) {
    return LoginView.routeName;
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

// Constants for colors - palette moderne et élégante
class AppColors {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF1A73E8);      // Bleu Google moderne
  static const Color secondaryColor = Color(0xFF4285F4);    // Bleu Google léger
  static const Color accentColor = Color(0xFF0D47A1);       // Bleu foncé pour accent
  
  // Couleurs de fond
  static const Color scaffoldBackgroundColor = Color(0xFFF8F9FA); // Gris très clair
  static const Color canvasColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Couleurs de texte
  static const Color textColor = Color(0xFF202124);         // Presque noir
  static const Color textSecondaryColor = Color(0xFF5F6368); // Gris foncé
  static const Color textTertiaryColor = Color(0xFF9AA0A6);  // Gris moyen
  
  // Couleurs d'action
  static const Color successColor = Color(0xFF34A853);      // Vert Google
  static const Color warningColor = Color(0xFFFBBC05);      // Jaune Google
  static const Color errorColor = Color(0xFFEA4335);        // Rouge Google
  static const Color infoColor = Color(0xFF4285F4);         // Bleu Google
  
  // Couleurs d'éléments d'interface
  static const Color dividerColor = Color(0xFFE8EAED);      // Gris très clair
  static const Color borderColor = Color(0xFFDADCE0);       // Gris clair
  static const Color disabledColor = Color(0xFFBDC1C6);     // Gris moyen
  static const Color shadowColor = Color(0x1A000000);       // Noir avec 10% d'opacité
  static const Color iconColor = Color(0xFF1A73E8);         // Bleu Google
  static const Color appBarBackground = Color(0xFF1A73E8);   // Bleu Google
  static const Color inputFillColor = Colors.white;
  static const Color tooltipBackground = Color(0xFF202124);  // Presque noir
  static const Color chipBackground = Color(0xFFE8F0FE);    // Bleu très clair
}

// Constants for padding and spacing
class AppSpacing {
  // Padding standard
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Padding prédéfinis
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 24);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
  
  // Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  
  // Elevation
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
}

// Constantes pour les animations
class AppAnimations {
  // Durées
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);
  
  // Courbes
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve emphasizedCurve = Curves.easeOutQuart;
  static const Curve entranceCurve = Curves.easeOutCirc;
  static const Curve exitCurve = Curves.easeInCirc;
  
  // Configurations pour les animations
  
  // Animations prédéfinies
  static List<Effect<dynamic>> get fadeIn => [
    FadeEffect(duration: fast, curve: entranceCurve),
  ];
  
  static List<Effect<dynamic>> get slideIn => [
    SlideEffect(duration: medium, curve: entranceCurve, begin: const Offset(0, 0.1), end: Offset.zero),
  ];
  
  static List<Effect<dynamic>> get scaleIn => [
    ScaleEffect(duration: fast, curve: entranceCurve, begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
  ];
  
  static List<Effect<dynamic>> get listItemEntrance => [
    FadeEffect(duration: fast, curve: entranceCurve),
    SlideEffect(duration: medium, curve: entranceCurve, begin: const Offset(0.2, 0), end: Offset.zero),
  ];
}

// Constants for routes
class AppRoutes {
  static const String loadingRoute = '/loading';
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String compteRenduCreateRoute = '/compte-rendu/create';
  static const String compteRendusRoute = '/mes-comptes-rendus';
}
