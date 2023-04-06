import 'dart:convert';

import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:http/http.dart' as http;

class ExampleHomePage extends StatefulWidget {
  final Blog item;
  ExampleHomePage(this.item);
  @override
  _ExampleHomePageState createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with TickerProviderStateMixin {
  List<Blog> blogList = List();
  List<String> welcomeImages = [
    "assets/img/budget.png",
    "assets/img/cost.png",
    "assets/img/money.png",
    "assets/img/no.png",
  ];
  @override
  void initState() {
    getLatestBlog();
    super.initState();
  }

  Future getLatestBlog() async {
    final msg = jsonEncode({"blog_id": widget.item.id});
    final String url = 'https://incite.technofox.co.in/api/blogSwipe';
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
    print(data);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    setState(() {
      print(list);
      blogList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    CardController controller; //Use this to trigger swap.

    return new Scaffold(
      body: new Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: new TinderSwapCard(
            allowVerticalMovement: false,
            swipeUp: false,
            swipeDown: false,
            orientation: AmassOrientation.BOTTOM,
            totalNum: blogList.length,
            stackNum: 3,
            swipeEdge: 4.0,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.width * 2,
            minWidth: MediaQuery.of(context).size.width * 0.8,
            minHeight: MediaQuery.of(context).size.width * 0.8,
            cardBuilder: (context, index) => Card(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: blogList.length != 0
                        ? Image.network(
                            blogList[index].bannerImage[0],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          )
                        : Container(),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.6),
                    alignment: Alignment.center,
                    child: Text(
                      blogList[index].title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ReadBlog',
                            arguments: blogList[index]);
                      },
                      child: Text(allMessages.value.view),
                    ),
                  ),
                  Positioned(
                    top: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              //child: Image.asset('${welcomeImages[index]}'),
            ),
            cardController: controller = CardController(),
            swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
              /// Get swiping card's alignment
              if (align.x < 0) {
                //Card is LEFT swiping
              } else if (align.x > 0) {
                //Card is RIGHT swiping
              }
            },
            swipeCompleteCallback:
                (CardSwipeOrientation orientation, int index) {
              /// Get orientation & index of swiped card!
            },
          ),
        ),
      ),
    );
  }
}
