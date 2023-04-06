import 'dart:convert';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:blog_app/elements/bottom_card_item_saved.dart';

import '../app_theme.dart';

//* <----------- Search Blog Page -------------->

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  TextEditingController searchController;
  List<Blog> blogList = List();
  bool _isLoading = false;
  var width;
  @override
  initState() {
    currentUser.value.isPageHome = false;
    getLatestBlog();
    super.initState();
    searchController = TextEditingController();
  }

  Future getLatestBlog() async {
    _isLoading = true;
    final msg = jsonEncode({"user_id": currentUser.value.id});
    final String url = 'https://incite.technofox.co.in/api/AllBookmarkPost';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    Map data = json.decode(response.body);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    setState(() {
      blogList = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            elevation: 0,
            backgroundColor: Theme.of(context).canvasColor,
            automaticallyImplyLeading: false,
            title: LayoutBuilder(builder: (contextname, constraints) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(contextname).openDrawer();
                },
                child: Row(
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/UserProfile', arguments: true);
                        },
                        child: Hero(
                          tag: 'photo',
                          child: CircleAvatar(
                            backgroundImage: currentUser.value.photo != null &&
                                    currentUser.value.photo != ''
                                ? NetworkImage(currentUser.value.photo)
                                : AssetImage('assets/img/user.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 20.0),
                          child: Text(
                            allMessages.value.mySavedStories,
                            style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Montserrat',
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w800),
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: blogList.length > 0
                            ? Column(
                                children: blogList
                                    .map((e) => BottomCardSaved(
                                          e,
                                          isTrending: false,
                                        ))
                                    .toList(),
                              )
                            : Column(
                                children: [
                                  Text(
                                    allMessages.value.noSavedPostFound,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
