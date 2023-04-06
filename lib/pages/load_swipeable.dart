import 'dart:convert';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:blog_app/models/setting.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/controllers/user_controller.dart';

SharedPreferences prefs;
//* <--------- Authentication page [Login, SignUp , ForgotPassword] ------------>

class LoadSwipePage extends StatefulWidget {
  @override
  _LoadSwipePageState createState() => _LoadSwipePageState();
}

class _LoadSwipePageState extends State<LoadSwipePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController userController;
  final FacebookLogin facebookSignIn = FacebookLogin();
  var height, width;
  bool _isLoading = false;
  Future<Setting> settingList;
  String appName;
  String appImage;
  String appSubtitle;
  Future<Setting> futureAlbum;
  List<Blog> blogList = List();
  Users user = new Users();

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  Future getLatestBlog() async {
    _isLoading = true;
    print(_isLoading);
    var url = "https://incite.technofox.co.in/api/blog-all-list";
    var result = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
    );
    Map data = json.decode(result.body);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    print(list);
    if (this.mounted) {
      setState(() {
        blogListHolder.clearList();
        blogListHolder.setList(list);
        blogList = list;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return SwipeablePage(0);
          }),
        ).then((value) {
          blogListHolder.clearList();
          blogListHolder.setList(blogList);
        });
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    userController = UserController();
    currentUser.value.isPageHome = false;
    super.initState();
    getLatestBlog();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            child: Center(
              child: Image.asset(
                'assets/img/user.png',
                height: 90,
                width: 90,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 50),
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
