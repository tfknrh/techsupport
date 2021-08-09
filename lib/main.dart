import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/screens.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';
import 'package:timezone/data/latest.dart' as tz;

//import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  // _getTimeZone();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyManager implements IThemeModeManager {
  @override
  Future<String> loadThemeMode() async {
    return '';
  }

  @override
  Future<bool> saveThemeMode(String value) async {
    return true;
  }
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator"); //

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome In SplashScreen Package'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          'Succeeded!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //   RunBackground.runService();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => ImagesProvider()),
          ChangeNotifierProvider(create: (_) => CustomerProvider()),
          ChangeNotifierProvider(create: (_) => SettingProvider()),
          ChangeNotifierProvider(create: (_) => FormulirProvider()),
          ChangeNotifierProvider(create: (_) => AktivitasProvider()),
          //    ChangeNotifierProvider(create: (_) => ListData()),
        ],
        child: ThemeModeHandler(
            manager: MyManager(),
            builder: (ThemeMode themeMode) {
              return MaterialApp(
                  navigatorKey: navigatorKey,
                  title: 'TechSupport',
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [
                    // const Locale('es'),
                    const Locale('id', 'ID'),
                    //const Locale('es'),
                  ],
                  locale: Locale('id', 'ID'),
                  darkTheme: Themes.dark,
                  theme: Themes.light,
                  home: SplashScreen.timer(
                    seconds: 1,
                    navigateAfterSeconds: HomeScreen(),
                    title: Text(
                      'TechSupport',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    image: Image.asset(
                      'assets/splash.png',
                    ),
                    backgroundColor: Colors.white,
                    loaderColor: Colors.blue,
                  ));
            }));
  }
}
