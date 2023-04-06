import 'dart:convert';
import 'dart:io';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/category_post.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:blog_app/app_theme.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'e_news.dart';
import 'live_news.dart';
//import 'package:http/http.dart' as http;

//* <--------- Main Screen of the app ------------->

class HomeClonePage extends StatefulWidget {
  @override
  _HomeClonePageState createState() => _HomeClonePageState();
}

class _HomeClonePageState extends StateMVC<HomeClonePage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeController homeController;
  List category = [];
  List list = [];
  bool _isLoading = false;
  String localLanguage;

  ScrollController scrollController;
  TabController tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;

  BlogCategory blogCategory;
  List<Blog> blogList = [];

  @override
  void initState() {
    localLanguage = languageCode.value.language;

    homeController = HomeController();
    getCurrentUser();
    getBlogData();
    getCategory();
    super.initState();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController.addListener(scrollControllerListener);
  }

  Future getCategory() async {
    _isLoading = true;
    print(
        "languageCode.value ${languageCode.value} ${languageCode.value?.language ?? "null"}");
    var url = "https://incite.technofox.co.in/api/blog-category-list";
    print("fetching $url");
    var result = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
    );
    Map data = json.decode(result.body);
    BlogCategory category = BlogCategory.fromMap(data);
    setState(() {
      blogCategory = category;
      // tabController =
      //     TabController(length: blogCategory.data.length, vsync: this);
      _isLoading = false;
    });
  }

  Future getBlogData() async {
    _isLoading = true;
    var url = "https://incite.technofox.co.in/api/blog-list";
    //var result = await http
    //.get("${GlobalConfiguration().getValue('api_base_url')}blog-list");
    var result = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
    );
    Map data = json.decode(result.body);
    print(data);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    setState(() {
      blogList = list;
      _isLoading = false;
    });
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
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
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
        body: ListView(
          shrinkWrap: true,
          controller: scrollController,
          children: <Widget>[
            _buildTopText(),
            _buildRecommendationCards(),
            _buildTabText(),
            _buildTabView(),
            SizedBox(
              height: 15,
            ),
            Container(
              width: double.infinity,
              //color: Colors.amberAccent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      allMessages.value.stayBlessedAndConnected,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
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
        ));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      bottom: showTopTabBar
          ? _buildTabBar()
          : PreferredSize(
              preferredSize: Size(0, 0),
              child: Container(),
            ),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,

      //backgroundColor: Theme.of(context).canvasColor,
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
                  //width: 0.01 * width,
                  fit: BoxFit.none,
                  color: appThemeModel.value.isDarkModeEnabled.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Spacer(),
              Container(
                width: 0.08 * constraints.maxWidth,
                height: 0.08 * constraints.maxWidth,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/AuthPage', arguments: true);
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
            print(context);
            print(constraints.maxWidth);
            return Row(
              children: [
                Container(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        currentUser.value.name != null
                            ? "${allMessages.value.welcome} ${currentUser.value.name},"
                            : "${allMessages.value.welcomeGuest}",
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
                        allMessages.value.featuredStories,
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
        child: blogList.length == 0
            ? ListView.builder(
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
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
                  return CardItem(blogList[index], index, blogList);
                },
                itemCount: blogList.length,
              ),
      ),
    );
  }

  _buildTabBar() {
    return TabBar(
        indicatorColor: Colors.transparent,
        controller: tabController,
        onTap: setTabIndex,
        isScrollable: true,
        tabs: blogCategory.data
            .map((e) => Tab(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    e.name,
                    style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: e.index == currentTabIndex
                                  ? appThemeModel.value.isDarkModeEnabled.value
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
            allMessages.value.filterByTopics,
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

  enewsPaper() {
    return Container(
      height: 500,
      child: GestureDetector(
        onTap: () async {},
        child: Container(
          height: 500,
          child: Card(
            semanticContainer: true,
            child: Stack(
              children: [
                Positioned(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ClipRRect(
                          child: Container(
                              child: Image.asset(
                            'assets/img/app_icon.png',
                            fit: BoxFit.cover,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTabView() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 1.6),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: blogCategory == null
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
              : List.generate(blogCategory.data.length + 2, (index) {
                  if (index == blogCategory.data.length) {
                    return newCategories(
                        title: allMessages.value.eNews,
                        image: "assets/img/app_icon.png",
                        ontap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Enews()));
                        });
                  } else if (index == blogCategory.data.length + 1) {
                    return newCategories(
                        title: allMessages.value.liveNews,
                        image: "assets/img/app_icon.png",
                        ontap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LiveNews()));
                        });
                  }
                  return Container(
                    height: 500,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/CategoryPostPage',
                            arguments: blogCategory.data[index].id);
                      },
                      child: Container(
                        height: 500,
                        child: Card(
                          semanticContainer: true,
                          child: Stack(
                            children: [
                              Positioned(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: ClipRRect(
                                        child: Container(
                                            child: Image.network(
                                          blogCategory.data[index].image,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
        ),
      ),
    );
  }

  newCategories({String title, String image, Function ontap}) {
    return Container(
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          child: Card(
            semanticContainer: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 75,
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
