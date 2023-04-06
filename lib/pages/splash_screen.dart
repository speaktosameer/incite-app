import 'dart:convert';

import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/models/language.dart';
import 'package:blog_app/models/messages.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _userLog = false;
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    sharedValues();
  }

  void sharedValues() async {
    try {
      SharedPreferences prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
      if (prefs.containsKey('isUserLoggedIn')) {
        _userLog = true;
      } else {
        _userLog = false;
      }
      await userController.getAllAvialbleLanguages();
      print("prefs.containsKey() ${prefs.containsKey("defalut_language")}");
      if (prefs.containsKey("defalut_language")) {
        print("defalut_language ${prefs.containsKey("defalut_language")}");
        String lng = prefs.getString("defalut_language");
        String localData = prefs.getString("local_data");
        print("lng $lng");
        print("allMessages $localData");
        allMessages.value = Messages.fromJson(json.decode(localData));
        languageCode.value = Language.fromJson(json.decode(lng));
      } else {
        print("else ${currentUser.value.name}");
        if (currentUser.value.name != null) {
          allLanguages.forEach((element) {
            if (element.name == currentUser.value.langCode) {
              languageCode.value = Language(
                language: element.language,
                name: element.name,
              );
            }
          });
        }
        await userController.getLanguageFromServer();
      }

      print("is user login $_userLog ${currentUser.value.name}");
      if (_userLog) {
        print("user is login");
        Navigator.pushReplacementNamed(context, '/MainPage');
        Navigator.pushNamed(context, '/LoadSwipePage');
      } else {
        print(
            'prefs.containsKey("defalut_language") ${prefs.containsKey("defalut_language")}');
        if (!prefs.containsKey("defalut_language")) {
          Navigator.pushReplacementNamed(context, '/LanguageSelection',
              arguments: false);
        } else {
          Navigator.pushReplacementNamed(context, '/AuthPage');
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(
            'assets/img/user.png',
            height: 90,
            width: 90,
          ),
        ),
      ),
    );
  }
}
