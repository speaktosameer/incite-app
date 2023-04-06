import 'dart:async';
import 'dart:convert';

import 'package:blog_app/app_theme.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_controller.dart';
import 'e_news.dart';
import 'live_news.dart';

const String testDevice = 'YOUR_DEVICE_ID';
//* <--------- Main Screen of the app ------------->
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends StateMVC<HomePage> with TickerProviderStateMixin {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {},
    );
  }

  GlobalKey<ScaffoldState> scaffoldKey;

  HomeController homeController;

  ScrollController scrollController;
  TabController tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;
  String localLanguage;

  @override
  void initState() {
    super.initState();
    print("Home Page");
    getCurrentUser();
    localLanguage = languageCode.value.language;
    currentUser.value.isPageHome = true;
    homeController = HomeController();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController.addListener(scrollControllerListener);
  }

  scrollControllerListener() {
    if (scrollController.offset >= height * 0.58) {
      setState(() {
        showTopTabBar = true;
      });
    } else {
      setState(() {
        showTopTabBar = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("In Build home_page.dart");

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return LoadingOverlay(
        isLoading: snapshot.load,
        color: Colors.grey,
        child: Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            key: scaffoldKey,
            drawer: DrawerBuilder(),
            onDrawerChanged: (value) {
              print(
                  "drawer $value ${localLanguage != languageCode.value.language}");
              if (localLanguage != languageCode.value.language) {
                Provider.of<AppProvider>(context, listen: false)
                  ..getBlogData()
                  ..getCategory();
                setState(() {
                  localLanguage = languageCode.value.language;
                });
              }
            },
            appBar: buildAppBar(context),
            body: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                controller: scrollController,
                children: <Widget>[
                  _buildTopText(),
                  _buildRecommendationCards(),
                  _buildTabText(),
                  Consumer<AppProvider>(builder: (context, snapshot, _) {
                    return snapshot.blog == null
                        ? Container()
                        : _buildTabView();
                  }),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            allMessages?.value?.stayBlessedAndConnected ?? "",
                            style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      fontFamily: 'Montserrat',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }

  buildAppBar(BuildContext context) {
    if (scaffoldKey?.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState.openEndDrawer();
    }
    return AppBar(
      bottom: showTopTabBar
          ? _buildTabBar()
          : PreferredSize(
              preferredSize: Size(0, 0),
              child: Container(),
            ),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
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
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : Colors.black,
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
                    print("hello world ${currentUser.value.photo}");
                    if (currentUser.value.photo != null) {
                      Navigator.of(context)
                          .pushNamed('/UserProfile', arguments: true);
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed('/AuthPage', arguments: true);
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: currentUser.value.photo != ''
                        ? currentUser.value.photo != null
                            ? NetworkImage(currentUser.value.photo)
                            : AssetImage(
                                'assets/img/user.png',
                              )
                        : AssetImage(
                            'assets/img/user.png',
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  _buildTopText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Container(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        currentUser.value.name != null
                            ? "${allMessages?.value?.welcome ?? ""} ${currentUser?.value?.name ?? ""},"
                            : "${allMessages?.value?.welcomeGuest ?? ""}",
                        style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400),
                            ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        allMessages?.value?.featuredStories ?? "",
                        style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold),
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Consumer<AppProvider>(builder: (context, snapshot, _) {
                  return ButtonTheme(
                    minWidth: 0.1 * constraints.maxWidth,
                    height: 0.04 * height,
                    child: RaisedButton(
                        padding: EdgeInsets.only(
                          right: 12,
                          left: 12,
                          bottom: 0.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                          side: BorderSide(
                            color: HexColor("#000000"),
                            width: 1.2,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text(
                            allMessages?.value?.myFeed ?? "",
                            style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(
                                      color: HexColor("#000000"),
                                      fontFamily: 'Montserrat',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                        ),
                        onPressed: () async {
                          snapshot.setLoading(load: true);
                          var url =
                              "https://incite.technofox.co.in/api/blog-all-list";
                          var result = await http.get(
                            url,
                            headers: {
                              "Content-Type": "application/json",
                              'userData': currentUser.value.id,
                              "lang-code": languageCode.value?.language ?? null
                            },
                          );
                          Map data = json.decode(result.body);
                          print(
                              "result ${data['data'].length} ${currentUser.value.id} ${languageCode.value?.language ?? "null"}");

                          final list = (data['data'] as List)
                              .map((i) => new Blog.fromMap(i))
                              .toList();

                          for (Blog item in list)
                            print(" HOMEPAGE FEED :" + item.title);

                          if (list.length > 0) {
                            snapshot.setLoading(load: false);
                            setState(() {
                              blogListHolder.clearList();
                              blogListHolder.setList(list);
                              blogListHolder.setIndex(0);
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SwipeablePage(0),
                            ));
                          }
                        }),
                  );
                })
              ],
            );
          },
        ),
      ),
    );
  }

  //! Top cards . .
  _buildRecommendationCards() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      height: 0.5 * MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          return snapshot.blogList.length == 0
              ? ListView.builder(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 20.0, left: 20.0, right: 10.0),
                        height: 0.4 * MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                  itemCount: 10,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return CardItem(
                        snapshot.blogList[index], index, snapshot.blogList);
                  },
                  itemCount: snapshot.blogList.length,
                );
        }),
      ),
    );
  }

  _buildTabBar() {
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return TabBar(
          indicatorColor: Colors.transparent,
          controller: tabController,
          onTap: setTabIndex,
          isScrollable: true,
          tabs: snapshot.blog.data
              .map((e) => Tab(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.name,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color: e.index == currentTabIndex
                                    ? appThemeModel
                                            .value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black
                                    : Colors.grey,
                                fontFamily: GoogleFonts.notoSans().fontFamily,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                  )))
              .toList());
    });
  }

  setTabIndex(int value) {
    setState(() {
      this.currentTabIndex = value;
    });
  }

  _buildTabText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            allMessages?.value?.filterByTopics ?? "",
            style: Theme.of(context).textTheme.bodyText1.merge(
                  TextStyle(
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
    );
  }

  _buildTabView() {
    return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          return GridView.count(
              crossAxisCount: 3,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 1.7),
              controller: new TrackingScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: snapshot.blog == null
                  ? List.generate(9, (index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[100],
                        highlightColor: Colors.grey[200],
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.red,
                          ),
                        ),
                      );
                    })
                  : List.generate(snapshot.blog.data.length + 2, (index) {
                      if (index == snapshot.blog.data.length) {
                        return newCategories(
                            title: allMessages?.value?.eNews ?? "",
                            image: "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Enews()));
                            });
                      } else if (index == snapshot.blog.data.length + 1) {
                        return newCategories(
                            title: allMessages?.value?.liveNews ?? "",
                            image: "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LiveNews()));
                            });
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38.withOpacity(0.1),
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 0.0),
                                  spreadRadius: 1.0)
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              snapshot.setLoading(load: true);

                              final msg = jsonEncode({
                                "category_id": snapshot.blog.data[index].id
                                //"user_id": currentUser.value.id
                              });
                              print(
                                  "blogCategory.data[index].id ${snapshot.blog.data[index].id}");
                              final String url =
                                  'https://incite.technofox.co.in/api/AllBookmarkPost';
                              final client = new http.Client();
                              final response = await client.post(
                                url,
                                headers: {
                                  "Content-Type": "application/json",
                                  'userData': currentUser.value.id,
                                  "lang-code":
                                      languageCode.value?.language ?? null
                                },
                                body: msg,
                              );
                              print(
                                  "API in home page response ${response.body}");
                              Map data = json.decode(response.body);
                              final list = (data['data'] as List)
                                  .map((i) => new Blog.fromMap(i))
                                  .toList();

                              print("List Size for index $index : " +
                                  list.length.toString());
                              snapshot.setLoading(load: false);

                              for (Blog item in list) {
                                print("item.title ${item.title}");
                              }

                              if (list.length > 0) {
                                blogListHolder.clearList();
                                blogListHolder.setList(list);
                                blogListHolder.setIndex(0);
                                Blog item = blogListHolder.getList()[0];
                                print("for FB ${item.title}");
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return SwipeablePage(0);
                                  }),
                                ).then((value) {
                                  blogListHolder.clearList();
                                  blogListHolder.setList(snapshot.blogList);
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: allMessages?.value?.noNewsAvilable ??
                                        "");
                              }
                            },
                            child: Container(
                              child: CachedNetworkImage(
                                imageUrl: snapshot.blog.data[index].image,
                                fit: BoxFit.fitWidth,
                                cacheKey: snapshot.blog.data[index].image,
                              ),
                            ),
                          ),
                        ),
                      );
                    }));
        }));
  }

  newCategories({String title, String image, Function ontap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black38.withOpacity(0.1),
                blurRadius: 5.0,
                offset: Offset(0.0, 0.0),
                spreadRadius: 1.0)
          ],
        ),
        child: GestureDetector(
          onTap: ontap,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  child: Image.asset(
                    image,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
