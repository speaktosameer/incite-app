import 'dart:convert';
import 'dart:io';

import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/models/language.dart';
import 'package:blog_app/models/messages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

ValueNotifier<Messages> allMessages = new ValueNotifier(Messages());
ValueNotifier<Users> currentUser = new ValueNotifier(Users());
ValueNotifier<int> defaultFontSize = new ValueNotifier(16);
List<Language> allLanguages = [];
ValueNotifier<Language> languageCode = ValueNotifier(null);
String emailData;
var userData;

void getCurrentFontSize() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey('fontSize')) {
    defaultFontSize.value = prefs.getInt("fontSize");
  } else {
    defaultFontSize.value = 16;
  }
}

void setCurrentFontSize(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("fontSize", value);
  defaultFontSize.value = value;
}

void showToast(text) {
  print(text);
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIos: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white);
}

void showSuccessToast(text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIos: 5,
      backgroundColor: Colors.green,
      textColor: Colors.white);
}

Future<Users> login(Users user) async {
  if (RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email)) {
    final msg = jsonEncode({"email": user.email, "password": user.password});
    final String url = 'https://incite.technofox.co.in/api/login';
    final client = new http.Client();
    final response = await client
        .post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    )
        .catchError((e) {
      print("login error $e");
    });
    print(json.decode(response.body));
    if (json.decode(response.body)['status'] == true) {
      // appThemeModel.value = AppModel.fromMap(
      //     {'currentUser': Users.fromJSON(json.decode(response.body)['data'])});
      setCurrentUser(response.body);
      currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
      currentUser.value.isPageHome = true;
      currentUser.value.id =
          json.decode(response.body)['data']['id'].toString();
      if (currentUser.value.langCode != null) {
        allLanguages.forEach((element) {
          if (element.language == currentUser.value.langCode) {
            languageCode.value = element;
          }
        });
      }

      print("Response Data ${json.decode(response.body)['data']}");
      print("Current user Data ${currentUser.value.id}");
      return currentUser.value;
    } else {
      showToast(json.decode(response.body)['message']);
    }
  } else {
    showToast(allMessages.value.emailNotExist);
  }
}

Future<Users> googleLogin(GoogleSignInAccount user) async {
  final authentication = await user.authentication;
  final _firebaseMessaging = FirebaseMessaging();
  String token = await _firebaseMessaging.getToken();
  final msg = jsonEncode({
    "email": user.email,
    "name": user.displayName,
    "image": user.photoUrl,
    "google_token": authentication.accessToken,
    "device_token": token,
    "login_from": "google"
  });
  print("msg $msg");
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
  print("google reposne ${json.decode(response.body)}");
  if (json.decode(response.body)['status'] == true) {
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
    currentUser.value.isPageHome = true;
    print("Response Data ${json.decode(response.body)['data']}");
    print("Current user Data ${currentUser.value.id}");
    if (currentUser.value.langCode != null) {
      allLanguages.forEach((element) {
        if (element.language == currentUser.value.langCode) {
          languageCode.value = element;
        }
      });
    }
    return currentUser.value;
  } else {
    showToast(json.decode(response.body)['message']);
  }
}

Future<Users> fblogin(Users user) async {
  if (RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email)) {
    final msg = jsonEncode({"email": user.email, "password": user.password});
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
    print(json.decode(response.body));
    if (json.decode(response.body)['status'] == true) {
      setCurrentUser(response.body);
      currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
      currentUser.value.isPageHome = true;
      print("Response Data ${json.decode(response.body)['data']}");
      print("sCurrent user Data ${currentUser.value.id}");
      return currentUser.value;
    } else {
      showToast(json.decode(response.body)['message']);
    }
  } else {
    showToast("Please enter valid email.");
  }
}

Future<Users> register(Users user) async {
  if (RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email)) {
    final msg = jsonEncode({
      "email": user.email,
      "name": user.name,
      "id": currentUser.value.id,
      "phone": user.phone,
      "password": user.password
    });
    print("msg $msg");
    final String url = 'https://incite.technofox.co.in/api/register';
    final client = new http.Client();
    final response = await client
        .post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    )
        .catchError((e) {
      print("register error $e");
    });
    print("json.decode(response.body) ${response.statusCode} ${response.body}");

    print("json.decode(response.body) ${json.decode(response.body)}");
    if (json.decode(response.body)['status'] == true) {
      setCurrentUser(response.body);
      currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
      currentUser.value.isPageHome = true;
      return currentUser.value;
    } else {
      showToast(json.decode(response.body)['message']);
    }
  } else {
    //showToast("Please enter valid email.");
  }
}

Future<Users> forgetPassword(Users user) async {
  final msg = jsonEncode({"email": user.email});
  //final String url =
  //'${GlobalConfiguration().getValue('api_base_url')}forgot-password';
  final String url = 'https://incite.technofox.co.in/api/forgot-password';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
    body: msg,
  );
  print("forgot password ${response.statusCode} ${response.body}");
  if (json.decode(response.body)['status'] == true) {
    var data = Users.fromJSON(json.decode(response.body)['data']);
    emailData = response.body;
    print("emailData $emailData");
    return data;
  } else {
    //  showToast(json.decode(response.body)['message']);
  }
}

Future<bool> resetPassword(Users user, String email) async {
  var userData = Users.fromJSON(json.decode(emailData)['data']);
  if (user.otp != userData.otp) {
    showToast(allMessages.value.invalidOtpEntered);
  } else if (user.password != user.cpassword) {
    showToast(allMessages.value.passwordAndConfirmPasswordShouldBeSame);
  } else {
    print("userData.id ${userData.id}");
    final msg = jsonEncode({
      "id": userData.id,
      "otp": user.otp,
      "email": email,
      "cpassword": user.cpassword,
      "password": user.password
    });
    //final String url =
    //'${GlobalConfiguration().getValue('api_base_url')}reset-password';
    final String url = 'https://incite.technofox.co.in/api/reset-password';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    if (json.decode(response.body)['status'] == true) {
      return true;
    } else {
      showToast(json.decode(response.body)['message']);
    }
  }
}

Future<void> logout() async {
  currentUser.value = new Users();

  SharedPreferences prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  await prefs.remove('current_user');
  prefs.setBool("isUserLoggedIn", false);
}

void setCurrentUser(jsonString) async {
  SharedPreferences prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  if (json.decode(jsonString)['data'] != null) {
    prefs.setBool("isUserLoggedIn", true);
    await prefs.setString(
        'current_user', json.encode(json.decode(jsonString)['data']));
    currentUser.value =
        Users.fromJSON(json.decode(await prefs.get('current_user')));
    print("Sended data ${json.decode(jsonString)['data']}");
    print(
        "Current set user ${json.decode(await prefs.get('current_user'))['id']}");
    print("Current User id ${currentUser.value.id}");
  }
}

Future<Users> getCurrentUser() async {
  SharedPreferencesUtils sharedPreferencesUtils =
      GetIt.instance<SharedPreferencesUtils>();
  //appThemeModel.value.
  if (currentUser.value.id == null &&
      sharedPreferencesUtils.prefs.containsKey('current_user')) {
    currentUser.value = Users.fromJSON(
        json.decode(sharedPreferencesUtils.prefs.get('current_user')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<Users> update(Users user) async {
  final msg = jsonEncode({
    "email": user.email,
    "name": user.name,
    "id": currentUser.value.id,
    "phone": user.phone,
    "password": user.password
  });
  //final String url =
  //'${GlobalConfiguration().getValue('api_base_url')}updateProfile';
  final String url = 'https://incite.technofox.co.in/api/updateProfile';
  final client = new http.Client();
  print("msg $msg");
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
    body: msg,
  );
  if (json.decode(response.body)['status'] == true) {
    Fluttertoast.showToast(
        msg: allMessages.value.profileUpdatedSuccessfully,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white);
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
    return currentUser.value;
  } else {
    showToast(json.decode(response.body)['message']);
  }
}

Future<Users> updateLanguage() async {
  final msg = jsonEncode({
    "lang-code": languageCode.value.language,
    "email": currentUser.value.email,
    "name": currentUser.value.name,
    "id": currentUser.value.id,
    "phone": currentUser.value.phone,
  });
  print("lang-code $msg");
  final String url = 'https://incite.technofox.co.in/api/updateProfile';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
    body: msg,
  );
  if (json.decode(response.body)['status'] == true) {
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
    return currentUser.value;
  } else {
    showToast(json.decode(response.body)['message']);
  }
}

Future<Users> updateToken(Users user) async {
  final msg = jsonEncode(
      {"id": currentUser.value.id, "device_token": user.deviceToken});
  //final String url =
  //'${GlobalConfiguration().getValue('api_base_url')}updateToken';
  final String url = 'https://incite.technofox.co.in/api/updateToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
    body: msg,
  );
}

Future<Messages> getLocalText() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url;
  print("languageCode.value ${languageCode.value}");
  if (languageCode.value != null) {
    url =
        "https://incite.technofox.co.in/api/keys/lists?language_code=${languageCode.value.language}";
  } else {
    url = 'https://incite.technofox.co.in/api/keys/lists';
  }
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
  ).catchError((e) {
    print("server error $e");
  });
  print("response ${json.decode(response.body)}");
  if (json.decode(response.body)['status'] == true) {
    prefs.setString(
        "local_data", json.encode(json.decode(response.body)['data']));
    return Messages.fromJson(json.decode(response.body)['data']);
  } else {
    showToast(json.decode(response.body)['message']);
  }
}

Future<List<Language>> getAllLanguages() async {
  final String url = 'https://incite.technofox.co.in/api/language/lists';
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
  ).catchError((e) {
    print("server error $e");
  });
  print("response ${json.decode(response.body)}");
  if (json.decode(response.body)['status'] == true) {
    List<Language> all = [];
    json.decode(response.body)['data'].forEach((language) {
      all.add(Language.fromJson(language));
    });
    return all;
  } else {
    showToast(json.decode(response.body)['message']);
  }
  return [];
}

Future<Users> getProfile() async {
  final msg = jsonEncode({"id": currentUser.value.id});
  final String url = 'https://incite.technofox.co.in/api/getProfile';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "lang-code": languageCode.value?.language ?? null
    },
    body: msg,
  );
  print(json.decode(response.body));
  if (json.decode(response.body)['status'] == true) {
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(json.decode(response.body)['data']);
    return currentUser.value;
  } else {
    showToast(json.decode(response.body)['message']);
  }
}
