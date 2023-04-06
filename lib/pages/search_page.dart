import 'dart:convert';
import 'dart:io';

import 'package:blog_app/elements/bottom_card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:hexcolor/hexcolor.dart';

import '../app_theme.dart';

//* <----------- Search Blog Page -------------->

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController;
  FocusNode focusNod = FocusNode();
  List<Blog> blogList = List();
  bool _isLoading = false;
  bool _isFound = true;
  var width;
  @override
  initState() {
    currentUser.value.isPageHome = false;
    super.initState();
    searchController = TextEditingController();
  }

  void getSearchedBlog() async {
    _isLoading = true;
    if (searchController != null) {
      final msg = jsonEncode(
          {"title": searchController.text, "user_id": currentUser.value.id});
      final String url = 'https://incite.technofox.co.in/api/searchBlog';
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
      final list =
          (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
      setState(() {
        blogList = list;
        _isLoading = false;
      });
      if (data['status'] == true) {
        _isFound = true;
      } else {
        _isFound = false;
      }
    } else {
      Fluttertoast.showToast(
          msg: allMessages.value.noResultFound,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
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
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).canvasColor,
            title: LayoutBuilder(builder: (contextname, constraints) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(contextname).openDrawer();
                },
                child: Row(
                  children: [
                    Image.asset(
                      "assets/img/loveoman.png",
                      width: 0.3 * width,
                      fit: BoxFit.contain,
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
                    /*    currentUser.value.name != null
                        ? GestureDetector(
                            child: Image.asset(
                              "assets/img/search.png",
                              width: 0.06 * width,
                            ),
                            onTap: () {
                              //    Navigator.pushNamed(context, '/SearchPage');
                            },
                          )
                        : Container(),*/
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
              child: Center(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 30.0),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Text(
                              allMessages.value.searchStories,
                              style:
                                  Theme.of(context).textTheme.bodyText1.merge(
                                        TextStyle(
                                            color: appThemeModel.value
                                                    .isDarkModeEnabled.value
                                                ? Colors.white
                                                : Colors.black,
                                            fontFamily: 'Montserrat',
                                            fontSize: 26.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            width: 0.9 * width,
                            child: TextFormField(
                              focusNode: focusNod,
                              style: TextStyle(
                                fontSize: 20.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                              ),
                              controller: searchController,
                              textInputAction: TextInputAction.search,
                              onSaved: (value) {},
                              onFieldSubmitted: (value) {
                                getSearchedBlog();
                              },
                              onChanged: (text) {
                                if (text.length >= 3) {
                                  setState(() {
                                    getSearchedBlog();
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.red),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      width: 1.0),
                                ),
                                suffixIcon: GestureDetector(
                                  child: Image.asset(
                                    "assets/img/search_small.png",
                                    width: 0.015 * width,
                                    color: appThemeModel
                                            .value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              autofocus: false,
                            ),
                          ),
                        ),
                        _isFound
                            ? Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: blogList
                                      .map(
                                        (e) => BottomCard(
                                          e,
                                          blogList.indexOf(e),
                                          blogList,
                                          isTrending: false,
                                          ontap: () {
                                            focusNod.unfocus();
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: [
                                    Text(
                                      allMessages.value
                                          .noResultsFoundMatchingWithYourKeyword,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .merge(
                                            TextStyle(
                                                color: appThemeModel.value
                                                        .isDarkModeEnabled.value
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.normal),
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
            ),
          )),
    );
  }
}
