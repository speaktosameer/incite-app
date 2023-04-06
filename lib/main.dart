import 'package:blog_app/app_theme.dart';
import 'package:blog_app/models/app_model.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:blog_app/route_generator.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/shared_pref_utils.dart';
import 'models/blog_category.dart';
import 'models/language.dart';
import 'models/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  try {
    GetIt.instance.registerSingleton<SharedPreferencesUtils>(
        await SharedPreferencesUtils.getInstance());
    await GlobalConfiguration().loadFromAsset("app_settings");
    print(GlobalConfiguration().getValue("base_url"));
    getCurrentFontSize();
    getDataFromSharedPrefs();
    getCurrentUser().then((value) {
      if (currentUser.value.auth != null) {
        currentUser.value.isNewUser = false;
      }
    });
  } catch (e) {
    print('error happened $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Setting> settingList = [];
  List<Blog> blogList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AppProvider>(context, listen: false)
        ..getBlogData()
        ..getCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ValueListenableBuilder(
        valueListenable: languageCode,
        builder: (context, Language langue, child) {
          print("languageCode ${langue?.name ?? ""}");

          return ValueListenableBuilder(
            valueListenable: appThemeModel,
            builder: (context, AppModel value, child) {
              print("appThemeModel $appThemeModel");
              return MaterialApp(
                initialRoute:
                    '/SplashScreen', //_userLog ? '/LoadSwipePage' : '/AuthPage',
                onGenerateRoute: RouteGenerator.generateRoute,
                builder: BotToastInit(), //1. call BotToastInit
                navigatorObservers: [BotToastNavigatorObserver()],
                debugShowCheckedModeBanner: false,
                theme: value.isDarkModeEnabled.value
                    ? getDarkThemeData()
                    : getLightThemeData(),
              );
            },
          );
        });
  }
}
