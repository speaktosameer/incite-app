import 'package:blog_app/elements/reset_password_sheet.dart';
import 'package:blog_app/elements/sign_in_bottom_sheet.dart';
import 'package:blog_app/helpers/notification_helper.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;
import 'package:get/get.dart';

SharedPreferences prefs;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class UserController extends ControllerMVC {
  Users user = new Users();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<FormState> updateFormKey;
  GlobalKey<FormState> signupFormKey;
  GlobalKey<FormState> forgetFormKey;
  GlobalKey<FormState> resetFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;

  bool _isLoading = false;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    updateFormKey = new GlobalKey<FormState>();
    signupFormKey = new GlobalKey<FormState>();
    forgetFormKey = new GlobalKey<FormState>();
    resetFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    notificationInit();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      print("_deviceToken ${_deviceToken}");
      user.deviceToken = _deviceToken;
      updateToken();
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void googleLogin(GlobalKey<ScaffoldState> scKey) async {
    BotToast.showLoading();
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      print("googleSignInAccount $googleSignInAccount");
      repository.googleLogin(googleSignInAccount).then((value) async {
        print("value $value");
        if (value != null && value.apiToken != null) {
          await getLanguageFromServer();
          Navigator.of(scKey.currentContext).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
          Navigator.of(scKey.currentContext).push(MaterialPageRoute(
            builder: (context) => SwipeablePage(0),
          ));
        } else {
          scKey?.currentState?.showSnackBar(SnackBar(
            content: Text(repository.allMessages.value.wrongEmailAndPassword),
          ));
        }
      }).catchError((e) {
        scKey?.currentState?.showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist),
        ));
      }).whenComplete(() {
        BotToast.closeAllLoading();
      });
    } catch (e) {
      BotToast.showCustomText(toastBuilder: e);
    }
  }

  void login(GlobalKey<ScaffoldState> scKey) async {
    print(user);
    if (user.password != "") {
      if (loginFormKey.currentState.validate()) {
        loginFormKey.currentState.save();
        BotToast.showLoading();
        repository.login(user).then((value) async {
          print("value $value ${value.apiToken}");
          if (value != null && value.apiToken != null) {
            // await getLanguageFromServer();
            print("in if");
            // Get.offAll(HomePage());
            Navigator.of(scKey.currentContext)
                .pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
            Navigator.of(scKey.currentContext).push(MaterialPageRoute(
              builder: (context) => SwipeablePage(0),
            ));
          } else {
            print("else error");
            scKey?.currentState?.showSnackBar(SnackBar(
              content: Text(repository.allMessages.value.wrongEmailAndPassword),
            ));
          }
        }).catchError((e) {
          print("catch error");
          scKey?.currentState?.showSnackBar(SnackBar(
            content: Text(repository.allMessages.value.emailNotExist),
          ));
        }).whenComplete(() {
          BotToast.closeAllLoading();
        });
      } else {
        print("login validate fail");
      }
    } else {
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scKey.currentContext).push(MaterialPageRoute(
            builder: (context) => SwipeablePage(0),
          ));
          // Navigator.of(scKey.currentContext)
          //     .pushReplacementNamed('/MainPage', arguments: false);
        } else {
          scKey?.currentState?.showSnackBar(SnackBar(
            content: Text(repository.allMessages.value.wrongEmailAndPassword),
          ));
        }
      }).catchError((e) {
        scKey?.currentState?.showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist),
        ));
      }).whenComplete(() {
        BotToast.closeAllLoading();
      });
    }
  }

  void register(GlobalKey<ScaffoldState> scKey) async {
    if (signupFormKey.currentState.validate()) {
      print("dfsa");
      signupFormKey.currentState.save();
      BotToast.showLoading();
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scKey.currentContext).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
          Navigator.of(scKey.currentContext).push(MaterialPageRoute(
            builder: (context) => SwipeablePage(0),
          ));
        } else {
          scKey?.currentState?.showSnackBar(SnackBar(
            content: Text(repository.allMessages.value.wrongEmailAndPassword),
          ));
        }
      }).catchError((e) {
        scKey?.currentState?.showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist),
        ));
      }).whenComplete(() {
        BotToast.closeAllLoading();
      });
    }
  }

  void forgetPassword(
      GlobalKey<ScaffoldState> scKey, BuildContext context) async {
    if (forgetFormKey.currentState.validate()) {
      forgetFormKey.currentState.save();
      BotToast.showLoading();
      repository.forgetPassword(user).then((value) async {
        BotToast.closeAllLoading();
        print("value $value");

        if (value != null) {
          Fluttertoast.showToast(
              msg: "OTP sent to your email address",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIos: 5,
              backgroundColor: Colors.green,
              textColor: Colors.white);
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: scKey.currentContext,
              builder: (context) {
                return ResetPasswordSheet(scKey, user.email);
              });
        } else {
          print("else ");
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Error",
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
              content: Text("Something Went Wrong Try Again Later."),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(allMessages.value.ok),
                ),
              ],
            ),
          );
        }
      }).whenComplete(() {});
    }
  }

  void resetPassword(GlobalKey<ScaffoldState> scKeys, String email) async {
    if (resetFormKey.currentState.validate()) {
      resetFormKey.currentState.save();
      repository.resetPassword(user, email).then((value) async {
        if (value != null && value == true) {
          showCustomDialog(
              context: scKeys.currentContext,
              text: "Your password reset successfully",
              title: "Success",
              onTap: () {
                Navigator.pop(scKeys.currentContext);
                Navigator.pop(scKeys.currentContext);
                Navigator.pop(scKeys.currentContext);
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: scKeys.currentContext,
                  builder: (context) {
                    return SignInBottomSheet(scKeys);
                  },
                );
              });
        } else {
          showCustomDialog(
              context: scKeys.currentContext,
              text: "Something went wrong",
              title: "Error",
              onTap: () {
                Navigator.pop(scKeys.currentContext);
              });
        }
      }).whenComplete(() {});
    }
  }

  showCustomDialog(
      {BuildContext context, String title, String text, Function onTap}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1.merge(
                TextStyle(
                    color: appThemeModel.value.isDarkModeEnabled.value
                        ? Colors.white
                        : Colors.black,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            onPressed: onTap,
            child: Text(allMessages.value.ok),
          ),
        ],
      ),
    );
  }

  void profile() async {
    if (updateFormKey.currentState.validate()) {
      updateFormKey.currentState.save();
      repository.update(user).then((value) {
        if (value != null && value.apiToken != null) {
          setState(() {
            _isLoading = false;
          });
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(repository.allMessages.value.profileUpdated),
          ));
        }
      }).catchError((e) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist),
        ));
      }).whenComplete(() {});
    }
  }

  void updateLanguage() async {
    repository.updateLanguage().then((value) {
      if (value != null && value.apiToken != null) {
        setState(() {
          _isLoading = false;
        });
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.profileUpdated),
        ));
      }
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(repository.allMessages.value.emailNotExist),
      ));
    }).whenComplete(() {});
  }

  getLanguageFromServer() async {
    await repository.getLocalText().then((value) {
      if (value != null) {
        repository.allMessages.value = value;
        print("repository ${repository.allMessages.value.skip}");
      }
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(repository.allMessages.value.noLanguageFound),
      ));
    }).whenComplete(() {});
  }

  getAllAvialbleLanguages() async {
    await repository.getAllLanguages().then((value) {
      if (value != null) {
        repository.allLanguages = value;
      }
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(repository.allMessages.value.noLanguageFound),
      ));
    }).whenComplete(() {});
  }

  void updateToken() async {
    repository
        .updateToken(user)
        .then((value) {})
        .catchError((e) {})
        .whenComplete(() {});
  }

  Future<void> notificationInit() async {
    //
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _firebaseMessaging.configure(
      onBackgroundMessage: null,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotificationWithDefaultSound(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        showNotificationWithDefaultSound(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    await _firebaseMessaging.requestNotificationPermissions();
  }

  Future<dynamic> onSelectNotification(String payload) async {}
}
