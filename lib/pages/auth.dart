import 'dart:convert';
import 'dart:io';

import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/sign_in_bottom_sheet.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/setting.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

SharedPreferences prefs;
//* <--------- Authentication page [Login, SignUp , ForgotPassword] ------------>

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController userController;
  final FacebookLogin facebookSignIn = FacebookLogin();

  var height, width;
  bool _isLoading = false;
  Future<Setting> settingList;
  String appName;
  String appImage;
  String appSubtitle;
  bool _isFacebookLogin = false;
  Future<Setting> futureAlbum;
  bool _userLog = false;
  List<Blog> blogList = List();
  FirebaseMessaging _firebaseMessaging;
  //Users user = new Users();

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  Future _login() async {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              allMessages.value.information,
              style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 18),
              //style: TextStyle(color: Colors.black),
            ),
            content: Text(
              allMessages.value.facebookLoginNotAvailable,
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(allMessages.value.ok),
              ),
            ],
          ),
        ) ??
        false;
    /* final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    setState(() {
      _isFacebookLogin = true;
    });

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''${accessToken.token}''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          _isFacebookLogin = false;
        });
        showToast('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        setState(() {
          _isFacebookLogin = false;
        });
        showToast('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }*/
  }

  Future getLatestBlog() async {
    print('getLatestBlog is called');
    _isLoading = true;
    var url = "https://incite.technofox.co.in/api/blog-all-list";
    var result = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "lang-code": languageCode.value?.language ?? null
      },
    );
    Map data = json.decode(result.body);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    if (this.mounted) {
      setState(() {
        blogListHolder.clearList();
        blogListHolder.setList(list);
        blogList = list;
        _isLoading = false;
      });
    }
  }

  Future<Users> _showMessage(token) async {
    //var device_token;
    var graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,email,picture&access_token=${token}');
    var profile = json.decode(graphResponse.body);
    print("Facebook Response ${graphResponse.body}");
    final msg = jsonEncode({
      "name": profile['name'],
      "email": profile['email'],
      "picture": profile['picture'],
      "fb_token": token,
      "fb_id": profile['id'],
      //"device_token": device_token
    });
    //repository.fblogin();
    final String url = 'https://incite.technofox.co.in/api/socialMediaLogin';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    Map dataNew = json.decode(response.body);
    print("Facebook Response ${response.body}");
    setState(() {
      setCurrentUser(response.body);
      currentUser.value = Users.fromJSON(json.decode(response.body)['data']);

      if (currentUser.value != null && currentUser.value.fbToken != null) {
        _firebaseMessaging = FirebaseMessaging();
        _firebaseMessaging.getToken().then((String _deviceToken) {
          print("Device token $_deviceToken");
          userController.user.deviceToken = _deviceToken;
          userController.updateToken();
        }).catchError((e) {});
        print(currentUser.value.isNewUser);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SwipeablePage(0),
        ));
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(allMessages.value.wrongEmailAndPassword),
        ));
      }
    });
  }

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
  }

  @override
  void initState() {
    userController = UserController();
    currentUser.value.isPageHome = false;
    super.initState();
    intializeshared();
    //getLatestBlog(); ///Disabled this as it was setting the list while the getBlogData was also setting it.
    /* if (_userLog == true) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/LoadSwipePage', (route) => false);
    }*/
    futureAlbum = getCurrentUser();
  }

  void intializeshared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
    print("User Logged In ${prefs.containsKey('isUserLoggedIn')}");
    if (prefs.containsKey('isUserLoggedIn')) {
      _userLog = prefs.getBool("isUserLoggedIn");
    } else {
      _userLog = false;
    }
    if (prefs.containsKey('app_image')) {
      appImage = prefs.getString("app_image");
      print("appImage $appImage");
    }
  }

  void _skipLogin() async {
    currentUser.value.name = "Guest";
  }

  Future<Setting> getCurrentUser() async {
    prefs = await SharedPreferences.getInstance();

    // String url =
    //'${GlobalConfiguration().getValue('api_base_url')}setting-list';
    String url = 'https://incite.technofox.co.in/api/setting-list';
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "lang-code": languageCode.value?.language ?? null
    });
    print(response.body);
    if (response.statusCode == 200) {
      appImage = json.decode(response.body)['data']['app_image'];
      prefs.setString("app_image", appImage);
      appName = json.decode(response.body)['data']['app_name'];
      appSubtitle = json.decode(response.body)['data']['app_subtitle'];
      var setList = Setting.fromJSON(json.decode(response.body)['data']);
      return setList;
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      //key: userController.loginFormKey,
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Container(
        height: height,
        width: width,
        child: buildBody(),
      ),
    );
  }

  buildBody() {
    return FutureBuilder(
      future: getCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: appImage != null
                  ? CachedNetworkImage(
                      imageUrl: appImage,
                      fit: BoxFit.cover,
                      cacheKey: appImage,
                      useOldImageOnUrlChange: false,
                    )
                  : Container(),
            ),
            /*  Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 55.0),
              child: Text(
                appName ?? "",
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
              ),
            ),*/
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
              child: Opacity(
                opacity: 0.6,
                child: ButtonTheme(
                  minWidth: 0.02 * width,
                  height: 0.04 * height,
                  child: RaisedButton(
                    padding: EdgeInsets.only(
                      right: 9,
                      left: 9,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                      Navigator.of(context)
                          .pushReplacementNamed('/MainPage', arguments: false);
                    },
                    color: Colors.black,
                    child: Text(
                      allMessages.value?.skip?.toUpperCase() ?? "",
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0.065 * height,
              left: 0,
              right: 0,
              child: getBottomButtons(),
            )
          ],
        );
      },
    );
  }

  getBottomButtons() {
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          ButtonTheme(
            minWidth: 0.62 * width,
            height: 0.075 * height,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return SignInBottomSheet(scaffoldKey);
                  },
                );
              },
              color: Theme.of(context).cardColor,
              child: Text(
                allMessages.value?.signIn?.toUpperCase() ?? "",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontSize: 17),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          !_isFacebookLogin
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 0.62 * width,
                    height: 0.075 * height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: GestureDetector(
                      child: Image.asset(
                        "assets/img/btn-lets begin.png",
                        fit: BoxFit.fitWidth,
                      ),
                      onTap: () {
                        _login();
                      },
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.6,
                    child: ButtonTheme(
                      height: 0.075 * height,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0)),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                              '/HomeClonePage',
                              arguments: false);
                        },
                        color: Colors.black,
                        child: Text(
                          allMessages.value.updatingFeed,
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 20.0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 0.075 * height,
              width: 0.62 * width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                child: Image.asset(
                  "assets/img/google_login.png",
                  fit: BoxFit.fitWidth,
                ),
                onTap: () {
                  userController.googleLogin(scaffoldKey);
                },
              ),
            ),
          )
        ],
      );
    });
  }
}
