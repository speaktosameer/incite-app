import 'dart:async';
import 'dart:convert';

import 'package:blog_app/app_theme.dart';
import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/data/key_holder.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mdi/mdi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../repository/user_repository.dart';

SharedPreferences prefs;

class MyInAppBrowser extends InAppBrowser {
  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class DrawerBuilder extends StatefulWidget {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());
  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {
  //GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  var height, width;
  var _userLog;
  bool _isHomePage = true;
  Future<void> _launched;
  String toLaunch = 'https://www.google.com/';
  GlobalKey<ScaffoldState> scaffoldKey;
  UserController userController = UserController();
  @override
  void initState() {
    //scaffoldKey = homeKeyHolder.getGlobalKey();
    scaffoldKey = homeKeyHolder.getGlobalKey();
    intializeshared();
    Future.delayed(Duration(seconds: 2), () {
      sharedValues();
    });
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 1,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
          print(url);
          print(title);
        }));
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 2',
        action: (url, title) {
          print('Custom item menu 2 clicked!');
          print(url);
          print(title);
        }));
    super.initState();
  }

  void intializeshared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  }

  //! Notification value : is not saved on device
  var notificationValue = true;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (BuildContext maincontext, value, Widget child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
            children: <Widget>[
              _buildUserImage(height, maincontext, width),
              SizedBox(
                height: 40.0,
              ),
              currentUser.value.name == null
                  ? getFontManager(maincontext)
                  : Container(),
              currentUser.value.name == null ? Divider() : Container(),
              currentUser.value.name == null
                  ? _buildLanguageSelection(maincontext)
                  : Container(),
              currentUser.value.name != null
                  ? GestureDetector(
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 10.0),
                              child: Icon(
                                Mdi.viewDashboard,
                                size: 25.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                //color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Text(
                                allMessages.value.dashboard,
                                style: Theme.of(maincontext)
                                    .textTheme
                                    .bodyText1
                                    .merge(
                                      TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : HexColor("#000000"),
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                //style: Theme.of(context).textTheme.headline6,
                                //style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (Scaffold.of(maincontext).isDrawerOpen) {
                          Scaffold.of(maincontext).openEndDrawer();
                        }
                        print(
                            "currentUser.value.isPageHome ${currentUser.value.isPageHome}");
                        if ((currentUser.value?.isPageHome ?? null) != null) {
                          currentUser.value?.isPageHome = false;
                        }
                        if (!currentUser.value.isPageHome) {
                          print("if inside");
                          Navigator.pop(maincontext);
                          Navigator.of(maincontext)
                              .pushNamed('/MainPage', arguments: false);
                        } else {
                          if (Scaffold.of(maincontext).isDrawerOpen) {
                            Scaffold.of(maincontext).openEndDrawer();
                          }
                        }
                      },
                    )
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? GestureDetector(
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 10.0),
                              child: Icon(
                                Mdi.accountCircleOutline,
                                size: 25.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                //color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Text(
                                allMessages.value.myProfile,
                                style: Theme.of(maincontext)
                                    .textTheme
                                    .bodyText1
                                    .merge(
                                      TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : HexColor("#000000"),
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                //style: Theme.of(context).textTheme.headline6,
                                //style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          //currentUser.value.isPageHome = false;
                          //_isHomePage = false;
                          Navigator.of(maincontext)
                              .pushNamed('/UserProfile', arguments: false);
                        });
                      },
                    )
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? GestureDetector(
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 10.0),
                              child: Icon(
                                Mdi.bookmark,
                                size: 25.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                //color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Text(
                                allMessages.value.myStories,
                                style: Theme.of(maincontext)
                                    .textTheme
                                    .bodyText1
                                    .merge(
                                      TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : HexColor("#000000"),
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                //style: Theme.of(context).textTheme.headline6,
                                //style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          //currentUser.value.isPageHome = false;
                          //_isHomePage = false;
                          Navigator.of(maincontext)
                              .pushNamed('/SavedPage', arguments: false);
                        });
                      },
                    )
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? getFontManager(maincontext)
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? _buildLanguageSelection(maincontext)
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? SizedBox(
                      height: 30.0,
                    )
                  : Container(),
              currentUser.value.name == null ? Divider() : Container(),
              _buildDarkModeSwitch(maincontext),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? _buildNotificationSwitch(maincontext)
                  : Container(),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? SizedBox(
                      height: 30.0,
                    )
                  : Divider(),
              _buildAbout(maincontext),
              Divider(),
              _buildJoinUs(maincontext),
              Divider(),
              _buildAdvertise(maincontext),
              Divider(),
              _buildContactUs(maincontext),
              Divider(),
              _buildPolicy(maincontext),
              currentUser.value.name != null ? Divider() : Container(),
              currentUser.value.name != null
                  ? SizedBox(
                      height: 30.0,
                    )
                  : Container(),
              currentUser.value.name != null
                  ? _buildSignOut(maincontext)
                  : Container(),
              currentUser.value.name == null ? Divider() : Container(),
              currentUser.value.name == null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(maincontext)
                            .pushNamed('/AuthPage', arguments: false);
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 10.0, top: 0),
                              child: Icon(
                                Mdi.lock,
                                size: 25.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                //color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Text(
                                allMessages.value.login,
                                style: Theme.of(maincontext)
                                    .textTheme
                                    .bodyText1
                                    .merge(
                                      TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : HexColor("#000000"),
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                //style: Theme.of(context).textTheme.headline6,
                                //style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  _buildLanguageSelection(BuildContext maincontext) {
    print("allLanguages ${allLanguages.length}");
    return GestureDetector(
      onTap: () async {
        final data = await Navigator.of(maincontext)
            .pushNamed('/LanguageSelection', arguments: true);
        print("data $data");
      },
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.flag,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            SizedBox(
              width: 25.0,
            ),
            Text(
              "Select language",
              style: Theme.of(maincontext).textTheme.bodyText1.merge(
                    TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        fontFamily: 'Montserrat',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  onLanguageChange() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "defalut_language", json.encode(languageCode.value.toJson()));
    prefs.setString("local_data", json.encode(allMessages.value.toJson()));
    await userController.getLanguageFromServer();
    if (mounted) {
      setState(() {});
    }
    if (currentUser.value.name != null) {
      userController.updateLanguage();
    }
  }

  getFontManager(BuildContext maincontext) {
    return ValueListenableBuilder<int>(
        valueListenable: defaultFontSize,
        builder: (context, fontSize, child) {
          return GestureDetector(
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                    child: Icon(
                      Mdi.formatSize,
                      size: 25.0,
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : HexColor("#000000"),
                      //color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      allMessages.value.fontSize,
                      style: Theme.of(maincontext).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          ),
                      //style: Theme.of(context).textTheme.headline6,
                      //style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      defaultFontSize.value++;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(defaultFontSize.value.toString(),
                      style: Theme.of(maincontext).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          )),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      defaultFontSize.value--;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(maincontext)
                  .pushNamed('/AuthPage', arguments: false);
            },
          );
        });
  }

  _buildSignOut(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.exitToApp,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.signOut,
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                //style: Theme.of(context).textTheme.headline6,
                //style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _logout();
      },
    );
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  _buildAbout(maincontext) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.heart,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.aboutUs,
                style: Theme.of(maincontext).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.browser.open(
            url: Uri.parse(
              "https://www.google.com/",
            ),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: false),
                ios: IOSSafariOptions(barCollapsingEnabled: true)));
      },
    );
  }

  _buildJoinUs(maincontext) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.leafMaple,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.joinUs,
                style: Theme.of(maincontext).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.browser.open(
            url: Uri.parse(
              "https://www.google.com/",
            ),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: false),
                ios: IOSSafariOptions(barCollapsingEnabled: true)));
      },
    );
  }

  _buildAdvertise(maincontext) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.lightbulbOutline,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.advertise,
                style: Theme.of(maincontext).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.browser.open(
            url: Uri.parse(
              "https://www.google.com/",
            ),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: false),
                ios: IOSSafariOptions(barCollapsingEnabled: true)));
      },
    );
  }

  _buildContactUs(maincontext) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.message,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.contactUs,
                style: Theme.of(maincontext).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                //style: Theme.of(context).textTheme.headline6,
                //style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.browser.open(
            url: Uri.parse(
              "https://www.google.com/",
            ),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: false),
                ios: IOSSafariOptions(barCollapsingEnabled: true)));
      },
    );
  }

  _buildPolicy(maincontext) {
    return GestureDetector(
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.clipboardArrowLeftOutline,
                size: 25.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                allMessages.value.policyAndTerms,
                style: Theme.of(maincontext).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : HexColor("#000000"),
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.browser.open(
            url: Uri.parse(
              "https://www.google.com/",
            ),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: false),
                ios: IOSSafariOptions(barCollapsingEnabled: true)));
      },
    );
  }

  // s
  _buildUserImage(double height, BuildContext context, double width) {
    return Container(
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
      height: 0.3 * height,
      child: Stack(alignment: Alignment.center, children: <Widget>[
        Container(
          height: 0.08 * height,
          color: Color(0xffff914d),
        ),
        currentUser.value.photo != null && currentUser.value.photo != ''
            ? GestureDetector(
                child: Container(
                  height: 0.18 * height,
                  width: 0.18 * height,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: currentUser.value.photo != null
                        ? NetworkImage(currentUser.value.photo)
                        : AssetImage('assets/img/user.png'),
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/UserProfile', arguments: false);
                },
              )
            : Container(
                height: 0.18 * height,
                width: 0.18 * height,
                decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    borderRadius: BorderRadius.circular(90),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/img/user.png',
                      ),
                      fit: BoxFit.cover,
                    )),
              ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Container(
            padding: EdgeInsets.only(top: 60.0),
            child: Text(
              currentUser.value.name != null
                  ? currentUser.value.name
                  : allMessages.value.guest,
              style: Theme.of(context).textTheme.bodyText1.merge(
                    TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        fontFamily: 'Montserrat',
                        fontSize: 22.0,
                        fontWeight: FontWeight.normal),
                  ),
            ),
            alignment: Alignment.bottomCenter,
          ),
        ),
      ]),
    );
  }

  _buildDarkModeSwitch(maincontext) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Icon(
                        Mdi.moonWaningCrescent,
                        size: 25.0,
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        allMessages.value.darkMode,
                        style: Theme.of(maincontext).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : HexColor("#000000"),
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              height: 20,
              child: Switch(
                onChanged: (v) {},
                value: appThemeModel.value.isDarkModeEnabled.value,
              ),
            )
          ],
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
            },
          ),
        )),
      ],
    );
  }

  _buildNotificationSwitch(maincontext) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Icon(
                        Mdi.bell,
                        size: 25.0,
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        //color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        allMessages.value.notifications,
                        style: Theme.of(maincontext).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : HexColor("#000000"),
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              height: 20,
              child: Switch(
                onChanged: (v) {},
                value: notificationValue,
              ),
            )
          ],
        ),
        //? To add clickable to whole tab
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                notificationValue = !notificationValue;
              });
            },
          ),
        )),
      ],
    );
  }

  void _logout() {
    _exitApp(context);
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              allMessages.value.logout,
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
            content: Text(allMessages.value.areYouSureYouWantToLogout),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(allMessages.value.no),
              ),
              FlatButton(
                onPressed: () {
                  logout();
                },
                child: Text(allMessages.value.yes),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> logout() async {
    print("Logout");
    if (currentUser.value.fbToken != '') {
      await facebookSignIn.logOut();
    }
    SharedPreferences prefs = GetIt.instance<SharedPreferencesUtils>().prefs;

    await prefs.remove('current_user');
    await prefs.remove("isUserLoggedIn");
    await Future.delayed(Duration(seconds: 2));
    currentUser.value = new Users();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/AuthPage', (route) => false);
  }

  void sharedValues() async {
    if (prefs.containsKey('current_user')) {
      _userLog = Users.fromJSON(json.decode(prefs.get('current_user')));
    } else {
      _userLog = List();
    }
    print(_userLog);
  }
}
