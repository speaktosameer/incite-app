import 'dart:convert';
import 'dart:io';

import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../appColors.dart';
import '../app_theme.dart';

SharedPreferences prefs;
Dio dio = new Dio();

//* <--------- User Profile [Personal details of current user] ------------>

class UserProfile extends StatefulWidget {
  final bool useHeroWidget;
  UserProfile(this.useHeroWidget);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File _image;
  FormData formdata = new FormData();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController userController;
  var height, width;

  final picker = ImagePicker();

  bool _isLoading = false;
  bool _isFound = true;
  @override
  void initState() {
    currentUser.value.isPageHome = false;
    intializeshared();
    userController = UserController();
    getCurrentUser();
    super.initState();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isLoading = true;
      } else {}
    });
    var stream = new http.ByteStream(_image.openRead());
    stream.cast();
    var length = await _image.length();
    var uri =
        Uri.parse("https://incite.technofox.co.in/api/updateProfilePicture");
    var request = http.MultipartRequest("POST", uri);
    request.fields["id"] = currentUser.value.id;
    var multipartFile = new http.MultipartFile('photo', stream, length,
        filename: basename(_image.path));
    request.files.add(multipartFile);
    await request.send().then((response) async {
      print(response);
      response.stream.transform(utf8.decoder).listen((value) {
        getCurrentUser();
        setState(() {
          currentUser.value = Users.fromJSON(json.decode(value)['data']);
          currentUser.value.isPageHome = false;
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: json.decode(value)['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return LoadingOverlay(
      isLoading: _isLoading,
      color: Colors.grey,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        drawer: DrawerBuilder(),
        onDrawerChanged: (value) {
          if (!value) {
            setState(() {});
          }
        },
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          title: LayoutBuilder(builder: (contextname, constraints) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(contextname).openDrawer();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/img/incite.png",
                    width: 0.25 * width,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Image.asset(
                      "assets/img/menu.png",
                      fit: BoxFit.none,
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Spacer(),
                  currentUser.value.name != null
                      ? GestureDetector(
                          child: Image.asset(
                            "assets/img/search.png",
                            width: 0.06 * width,
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/SearchPage');
                          },
                        )
                      : Container(),
                  SizedBox(
                    width: 0.044 * constraints.maxWidth,
                  ),
                  Container(
                    width: 0.08 * constraints.maxWidth,
                    height: 0.08 * constraints.maxWidth,
                    child: Hero(
                      tag: DateTime.now(),
                      child: CircleAvatar(
                        backgroundImage: currentUser.value.photo != null &&
                                currentUser.value.photo != ''
                            ? NetworkImage(currentUser.value.photo)
                            : AssetImage('assets/img/user.png'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 20.0),
                  child: Text(
                    currentUser.value.name,
                    style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 22.0,
                              fontWeight: FontWeight.normal),
                        ),
                  ),
                ),
              ),
              Stack(alignment: Alignment.center, children: <Widget>[
                Container(
                  height: 0.09 * height,
                  color: Color(0xffff914d),
                ),
                Container(
                  height: 0.18 * height,
                  width: 0.18 * height,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: FullScreenWidget(
                    child: Hero(
                      tag: widget.useHeroWidget ? 'photo' : "",
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: currentUser.value.photo != null &&
                                currentUser.value.photo != ''
                            ? NetworkImage(currentUser.value.photo)
                            : AssetImage('assets/img/user.png'),
                      ),
                    ),
                  ),
                ),
              ]),
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      allMessages.value.eDIT,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 0.05 * height,
              ),
              _buildTextFields(),
              SizedBox(
                height: 0.02 * height,
              ),
              _buildEndButton(),
              SizedBox(
                height: 0.12 * height,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _exitApp(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 70),
                    child: Text(
                      allMessages.value.deleteAccount,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color: Colors.red[300],
                                decoration: TextDecoration.underline,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController.updateFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: appMainColor, primaryColorDark: appMainColor),
              child: TextFormField(
                initialValue: currentUser.value.name != null
                    ? currentUser.value.name
                    : '',
                onSaved: (input) {
                  setState(() {
                    userController.user.name = input;
                  });
                },
                decoration: InputDecoration(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Text(
                      allMessages.value.name,
                      style: Theme.of(this.context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.name,
                  contentPadding: EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: Colors.green, primaryColorDark: appMainColor),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                initialValue: currentUser.value.email != null
                    ? currentUser.value.email
                    : '',
                onSaved: (input) {
                  print(input);
                  if (input != null) {
                    userController.user.email = input;
                  } else {
                    userController.user.email = currentUser.value.email;
                  }
                },
                decoration: InputDecoration(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Text(
                      allMessages.value.email,
                      style: Theme.of(this.context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.email,
                  contentPadding: EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: appMainColor, primaryColorDark: appMainColor),
              child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: currentUser.value.phone != null
                    ? currentUser.value.phone
                    : '',
                onSaved: (input) {
                  if (input != null) {
                    userController.user.phone = input;
                  } else {
                    userController.user.phone = currentUser.value.phone;
                  }
                },
                decoration: InputDecoration(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Text(
                      allMessages.value.mobile,
                      style: Theme.of(this.context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.mobile,
                  contentPadding: EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: appMainColor, primaryColorDark: appMainColor),
              child: TextFormField(
                obscureText: true,
                onSaved: (input) {
                  setState(() {
                    userController.user.password = input;
                  });
                },
                decoration: InputDecoration(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Text(
                      allMessages.value.password,
                      style: Theme.of(this.context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.password,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        userController.hidePassword =
                            !userController.hidePassword;
                      });
                    },
                    color: Theme.of(this.context).focusColor,
                    icon: Icon(userController.hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                  contentPadding: EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              allMessages.value.deleteAccount,
              style: TextStyle(color: Colors.black),
            ),
            content: Text(allMessages.value.confirmDeleteAccount),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  print("you choose no");
                  Navigator.of(context).pop(false);
                },
                child: Text(allMessages.value.no),
              ),
              FlatButton(
                onPressed: () {
                  deleteAccount();
                },
                child: Text(allMessages.value.yes),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    final msg = jsonEncode({"id": currentUser.value.id});
    final String url = 'https://incite.technofox.co.in/api/deleteAccount';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    Map data = json.decode(response.body);
    _isLoading = false;
    if (data['status'] == true) {
      _isFound = true;
      SharedPreferences prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
      await prefs.remove('current_user');
      await prefs.setBool("isUserLoggedIn", false);
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(this.context)
          .pushNamedAndRemoveUntil('/AuthPage', (route) => false);
    } else {
      _isFound = false;
    }
  }

  void intializeshared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  }

  _buildEndButton() {
    return ButtonTheme(
      minWidth: 0.5 * width,
      height: 0.057 * height,
      child: RaisedButton(
        color: Colors.green[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        onPressed: () {
          setState(() {
            userController.profile();
          });
        },
        child: Text(
          allMessages.value.updateProfile,
          style: Theme.of(this.context).textTheme.bodyText1.merge(
                TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
      ),
    );
  }
}
