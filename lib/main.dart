import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/controllers/c_customer.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/s_home.dart';
import 'package:techsupport/utils/themes.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => AktivitasProvider()),
          ChangeNotifierProvider(create: (_) => CustomerProvider()),
          // ChangeNotifierProvider(create: (_) => RutinaProvider()),
        ],
        child: ThemeModeHandler(
            manager: MyManager(),
            builder: (ThemeMode themeMode) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                title: 'TechSupoort',
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
                home: HomeScreen(),
              );
            }));
  }
}
