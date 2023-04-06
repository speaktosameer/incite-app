import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:blog_app/elements/video_player.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../app_theme.dart';
import 'read_blog_screenshot.dart';
import 'web_view.dart';
import 'package:get/get.dart';

class ReadBlog extends StatefulWidget {
  final Blog item;

  ReadBlog(this.item);

  @override
  _ReadBlogState createState() => _ReadBlogState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadBlogState extends State<ReadBlog> {
  bool _isLoading = false;
  var height, width;
  int _current = 0;
  bool isVolume = false;
  bool isWebOpened = false;
  bool isVolumeOn = false;
  bool isOpeningWebPage = false;
  bool isBookmark = false;
  bool isNew = false;
  VoiceController _voiceController;
  bool linkOpen = false;
  List<Blog> blogList = [];
  // text to speech
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  GlobalKey<CustomVideoPlayerState> videoPlayeState =
      GlobalKey<CustomVideoPlayerState>();
  Future<void> init(String text) async {
    bool isLanguageFound = false;
    flutterTts.getLanguages.then((value) {
      Iterable it = value;

      it.forEach((element) {
        if (element.toString().contains(getCurrentItem().blogAccentCode)) {
          flutterTts.setLanguage(element);
          initTTS(text);
          isLanguageFound = true;
        }
      });
    });

    if (!isLanguageFound) initTTS(text);
  }

  Future<void> initTTS(String text) async {
    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      stop();
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

    await Future.delayed(Duration(milliseconds: 300));
    speak(text);
  }

  Future speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Blog getCurrentItem() {
    return widget.item;
  }

  var scr = new GlobalKey();
  double fontSize = 16;

  @override
  void initState() {
    super.initState();
    //initializeLoggedInUser();

    print("Current Data ${currentUser.value.isNewUser}");
    if (currentUser != null) {
      if (currentUser?.value?.isNewUser == null) {
        currentUser.value.isNewUser = false;
        isNew = false;
      } else {
        isNew = currentUser.value.isNewUser;
      }
    }

    //getProfile();
    _voiceController = FlutterTextToSpeech.instance.voiceController();
    if (getCurrentItem().isBookmarked == 1) {
      isBookmark = true;
    } else {
      isBookmark = false;
    }
    _viewPost();
  }

  bool isReadBlogAvailable = true;

  @override
  void dispose() {
    super.dispose();
    flutterTts?.stop();
    if (_voiceController != null) {
      _voiceController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    print(
        "top MediaQuery.of(context).size. ${MediaQuery.of(context).padding.top} $kToolbarHeight}");
    width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: currentUser,
        builder: (BuildContext context, value, Widget child) {
          return LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.grey,
            child: Scaffold(
              backgroundColor: Theme.of(context).cardColor,
              body: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails dragDetail) {
                  isReadBlogAvailable = true;
                },
                onHorizontalDragUpdate: (DragUpdateDetails details) async {
                  print("details.delta.xd ${details.delta.dx}");
                  if (details.delta.dx < 0) {
                    print("left isReadBlogAvailable $isReadBlogAvailable");

                    if (widget.item.url != null && isReadBlogAvailable) {
                      isReadBlogAvailable = false;
                      // await Helper.launchURL(widget.item.url);
                      print("getCurrentItem().url, ${getCurrentItem().url}");
                      /* try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(true);
                      } catch (e) {
                        print("error while pause $e");
                      }*/
                      setState(() {
                        linkOpen = true;
                      });
                      /*    await Get.to(CustomWebView(
                        url: getCurrentItem().url,
                      ));*/
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomWebView(
                            url: getCurrentItem().url,
                          ),
                        ),
                      );

                      setState(() {
                        linkOpen = false;
                      });
                      print(
                          " MediaQuery.of(context).padding.top ${MediaQuery.of(context).padding.top}");
                      /*  try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(true);
                      } catch (e) {}
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext ctn) {
                          return SafeArea(
                            child: Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(30.0),
                                        topRight: const Radius.circular(30.0),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15, top: 5),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: WebView(
                                      initialUrl: widget.item.url,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(false);
                      } catch (e) {}
*/
                      // await launch(widget.item.url).then((value) {});

                    }
                  } else if (details.delta.dx > 0) {
                    print("right");
                    Navigator.pop(context);
                  }
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: height,
                      child: _buildPage(),
                    ),
                    !(currentUser.value.isNewUser ?? false)
                        ? Container()
                        : Positioned.fill(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  // intializeshared();
                                  isNew = false;
                                  // currentUser.value = Users.fromJSON(
                                  //     json.decode(prefs.get('current_user')));
                                  currentUser.value.isNewUser = false;
                                  //intializeshared();
                                  print(
                                      "Current Data ontap ${currentUser.value.isNewUser}");
                                  print("isNew ontap $isNew");
                                });
                              },
                              child: Image.asset(
                                'assets/img/screen.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _buildPage() {
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          key: scr,
          child: ReadBlogScreenshot(
            getCurrentItem(),
          ),
        ),
        Positioned.fill(
          child: _buildBlog(
            context,
          ),
        ),
        _buildTopBackButton(context),
      ],
    );
  }

  _buildBlog(BuildContext context) {
    var widthTop = 0.035 * width - 5;
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 0.45 * height,
                width: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: _buildOverlayImage(),
                    ),
                    _buildBlogNameAndDetails(context),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      ClipRRect(
                        child: Container(
                          width: double.infinity,
                          height: 0.06 * height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            color: HexColor("#F9F9F9"),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 13.0, top: 15.0, bottom: 10.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 0.035 * width,
                                  height: 0.035 * width,
                                  decoration: new BoxDecoration(
                                    color: HexColor(
                                        widget.item.categoryColor.toString()),
                                    //color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  getCurrentItem().categoryName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .merge(
                                        TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Montserrat',
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                ),
                                isVolumeOn
                                    ? SizedBox(
                                        width: widthTop,
                                      )
                                    : Container(),
                                isVolumeOn
                                    ? Container(
                                        width: widthTop * 0.04 * width,
                                        alignment: Alignment.center,
                                        child: Text(
                                          allMessages
                                              .value.toStopPlayingTapAgain,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .merge(
                                                TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 10.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 30.0, right: 30.0),
                              child: Text(
                                getCurrentItem().createDate.toString(),
                                style:
                                    Theme.of(context).textTheme.bodyText1.merge(
                                          TextStyle(
                                              color: appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: 'Montserrat',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              /* height: getCurrentItem().isVotingEnabled ==
                                          1 &&
                                      currentUser.value.id != null
                                  ? 0.34 * height
                                  : height *
                                      (0.425 +
                                          (getCurrentItem().url == null
                                              ? 0.06
                                              : 0)),
                                              */
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  right: 30.0,
                                  top: 30.0,
                                  bottom: 20.0,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    String text =
                                        parse(getCurrentItem().description)
                                            .body
                                            .text;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                            text,
                                            maxLines: getCurrentItem()
                                                            .isVotingEnabled ==
                                                        1 &&
                                                    currentUser.value.id != null
                                                ? (height / 60).toInt()
                                                : (height / 50).toInt(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: 'Montserrat',
                                              fontSize:
                                                  defaultFontSize.value != null
                                                      ? defaultFontSize.value
                                                          .toDouble()
                                                      : 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              getCurrentItem().url != null
                  ? Container(
                      color: Theme.of(context).cardColor,
                      child: Container(
                        color: Colors.grey.withOpacity(0.2),
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            getCurrentItem().url != null
                                ? Text(
                                    "${allMessages.value.swipeTo} ",
                                    style: TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 15,
                                    ),
                                  )
                                : Container(),
                            getCurrentItem().url != null
                                ? Icon(Mdi.arrowRightBoldBoxOutline)
                                : Container(),
                            getCurrentItem().url != null
                                ? Text(
                                    " ${allMessages.value.readFull}",
                                    style: TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 15,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              currentUser.value.id != null &&
                      getCurrentItem().isVotingEnabled == 1
                  ? _buildVotingCard()
                  : Container(),
            ],
          ),
          Positioned(
            right: 0.05 * width,
            top: 0.420 * height,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      shareImage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.black,
                        ),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/img/white/share.png',
                        height: 20,
                        width: 20,
                        color: Color(0xff48D1CC),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  currentUser.value.id != null
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isBookmark == false) {
                                _savePost();
                                isBookmark = true;
                              } else {}
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Colors.black,
                              ),
                              color: Colors.white,
                            ),
                            child: isBookmark
                                ? Icon(
                                    Icons.bookmark,
                                    color: Color(0xff48D1CC),
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.bookmark_border,
                                    color: Color(0xff48D1CC),
                                    size: 30,
                                  ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    width: currentUser.value.id != null ? 15 : 0,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black,
                          ),
                          color: Colors.white,
                        ),
                        child: VisibilityDetector(
                          key: Key(getCurrentItem().title),
                          onVisibilityChanged: (visibilityInfo) async {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100.0;
                            if (visiblePercentage != 100.0) {
                              if (isVolume) {
                                stop();
                              }
                              isVolume = false;
                            }
                          },
                          child: GestureDetector(
                            child: Image.asset(
                              isVolume
                                  ? 'assets/img/white/pause.png'
                                  : 'assets/img/white/play.png', //play.png
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                              color: Color(0xff48D1CC),
                            ),
                            onTap: () {
                              setState(() {
                                if (isVolume == false) {
                                  init(getCurrentItem().trimedDescription);
                                  isVolume = true;
                                  isVolumeOn = true;
                                  Future.delayed(
                                      const Duration(milliseconds: 700), () {
                                    isVolumeOn = false;
                                  });
                                } else {
                                  stop();
                                  isVolume = false;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Narrate",
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                      */
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildVotingCard() {
    return Container(
      width: double.infinity,
      height: 0.09 * height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: getCurrentItem().isVote == 0
          ? _buildVotingMech()
          : _buildIsParticipated(),
    );
  }

  _buildVotingMech() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "${allMessages.value.doYouAgree}",
                    style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900),
                        ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ButtonTheme(
                      minWidth: 0.25 * width,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _saveVoting(1);
                          });
                        },
                        color: HexColor("#016300"),
                        child: Text(
                          allMessages.value.yes,
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    ButtonTheme(
                      minWidth: 0.25 * width,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _saveVoting(0);
                          });
                        },
                        color: HexColor("#C62226"),
                        child: Text(
                          allMessages.value.no,
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildIsParticipated() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Column(
            children: [
              Spacer(),
              Container(
                child: Center(
                  child: Text(
                    allMessages.value.thankYouForParticipating,
                    style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500),
                        ),
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                height: 0.5 * constraints.maxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getCurrentItem().yesPercent > 0
                        ? ButtonTheme(
                            minWidth: widget.item.yesPercent /
                                    100 *
                                    constraints.maxWidth -
                                2,
                            height: constraints.maxHeight * 0.5,
                            child: RaisedButton(
                              onPressed: () {},
                              color: HexColor("#016300"),
                              child: Text(
                                getCurrentItem().yesPercent.toString() +
                                    "% ${allMessages.value.yes}",
                                style:
                                    Theme.of(context).textTheme.bodyText1.merge(
                                          TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                              ),
                            ),
                          )
                        : Container(),
                    getCurrentItem().noPercent > 0 &&
                            getCurrentItem().yesPercent > 0
                        ? Container(
                            color: HexColor("#000000"),
                            height: 55,
                            width: 3,
                          )
                        : Container(),
                    getCurrentItem().noPercent > 0
                        ? Center(
                            child: ButtonTheme(
                              minWidth: widget.item.noPercent /
                                      100 *
                                      constraints.maxWidth -
                                  1,
                              height: constraints.maxHeight * 0.5,
                              child: RaisedButton(
                                onPressed: () {},
                                color: HexColor("#C62226"),
                                child: Text(
                                  getCurrentItem().noPercent.toString() +
                                      "% ${allMessages.value.no}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .merge(
                                        TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Montserrat',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildBookmark() {
    return currentUser.value.id != null
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
            child: GestureDetector(
              child: !isBookmark
                  ? Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                      size: 25,
                    )
                  : Icon(
                      Icons.bookmark,
                      color: Colors.black,
                      size: 25,
                    ),
              onTap: () {
                setState(() {
                  if (isBookmark == false) {
                    _savePost();
                    isBookmark = true;
                  } else {}
                });
              },
            ),
          )
        : IconButton(
            icon: Icon(Icons.aspect_ratio, color: Colors.transparent),
            onPressed: () {},
          );
  }

  Path _buildBoatPath() {
    return Path()
      ..moveTo(15, 120)
      ..lineTo(0, 85)
      ..lineTo(50, 85)
      ..lineTo(60, 80)
      ..lineTo(60, 85)
      ..lineTo(120, 85)
      ..lineTo(105, 120) //and back to the origin, could not be necessary #1
      ..close();
  }

  _buildOverlayImage() {
    return Stack(
      children: <Widget>[
        widget.item.contentType == "video"
            ? linkOpen
                ? SizedBox.shrink()
                : CustomVideoPlayer(
                    blog: getCurrentItem(),
                    key: videoPlayeState,
                  )
            : getCurrentItem().bannerImage.length > 1
                ? Positioned(
                    child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.6,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                            items: getCurrentItem()
                                .bannerImage
                                .map<Widget>((item) => Container(
                                      child: Center(
                                          child: CachedNetworkImage(
                                        imageUrl: item,
                                        fit: BoxFit.cover,
                                        cacheKey: item,
                                      )),
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                getCurrentItem().bannerImage.map<Widget>((url) {
                              int index =
                                  getCurrentItem().bannerImage.indexOf(url);
                              return Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _current == index
                                        ? Color.fromRGBO(0, 0, 0, 0.9)
                                        : Color.fromRGBO(0, 0, 0, 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ))
                : Positioned.fill(
                    child: Image.network(
                    getCurrentItem().bannerImage[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  )),
      ],
    );
  }

  _buildBlogNameAndDetails(BuildContext context) {
    _viewPost();
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        width: 0.85 * width,
        padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                getCurrentItem().title,
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 25.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildVoting(BuildContext context) {
    return Positioned(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: const DecorationImage(
            image: NetworkImage(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.black,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  _buildTopBackButton(BuildContext context) {
    return Positioned(
      top: 40.0,
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
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _viewPost() async {
    print("getCurrentItem().id ${getCurrentItem().id}");
    print("currentUser.value.id ${currentUser.value.id}");
    final msg = jsonEncode(
        {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id});
    final String url =
        'https://incite.technofox.co.in/api/increaseBlogViewCount';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    print("response.body ${response.body}");
    Map dataNew = json.decode(response.body);
  }

  void _savePost() async {
    final msg = jsonEncode(
        {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id});
    final String url = 'https://incite.technofox.co.in/api/bookmarkPost';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null,
      },
      body: msg,
    );
    print("response ${response.statusCode}");

    Map data = json.decode(response.body);
    print("response $data");

    isBookmark = true;
    getCurrentItem().isBookmarked = data['data']['is_bookmark'];
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white);
    getBlogVotes();
  }

  void _swipetoBlogs(type, context) async {
    final msg = jsonEncode({"blog_id": getCurrentItem().id, "type": type});
    final String url = 'https://incite.technofox.co.in/api/nextPreviousBlog';
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
    print("swipe blog data ${response.body}");
    Map data = json.decode(response.body);
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    setState(() {
      blogList = list;
      Navigator.of(context).pushNamed("/ReadBlog", arguments: blogList[0]);
    });
  }

  void _openLink() async {
    try {
      Fluttertoast.showToast(msg: "Opening News in Web");
      Helper.launchURL(getCurrentItem().url);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid Link");
    }

    setState(() {
      isOpeningWebPage = false;
    });
  }

  void _saveVoting(vote) async {
    _isLoading = true;
    final msg = jsonEncode({
      "vote": vote,
      "user_id": currentUser.value.id,
      'blog_id': getCurrentItem().id
    });
    print("msg $msg");
    final String url = 'https://incite.technofox.co.in/api/addBlogVote';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: msg,
    );
    print("_saveVoting response $response");
    Map data = json.decode(response.body);
    getBlogVotes();
  }

  void getBlogVotes() async {
    print(
        "getBlogVotes currentUser.value.id ${currentUser.value.id} ${languageCode.value?.language}");
    final msg = jsonEncode({"blog_id": getCurrentItem().id});
    final String url = 'https://incite.technofox.co.in/api/getBlogVote';
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
    setState(() {
      getCurrentItem().isVote = data['data']['is_vote'];
      getCurrentItem().yesPercent = data['data']['yes_percent'];
      getCurrentItem().noPercent = data['data']['no_percent'];
      getCurrentItem().isBookmarked = data['data']['is_bookmark'];
      _isLoading = false;
    });
  }

  Future<void> _shareText() async {
    try {
      var request =
          await HttpClient().getUrl(Uri.parse(getCurrentItem().bannerImage[0]));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg',
          text: getCurrentItem().title);
    } catch (e) {}
  }

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary;
    try {
      boundary = scr.currentContext.findRenderObject();
    } catch (e) {}
    if (boundary == null) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }
    try {
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData.buffer.asUint8List();
    } catch (e) {}

    return null;
  }

  shareImage() async {
    BotToast.showLoading();
    var pngBytes = await _capturePng();
    print("pngBytes $pngBytes");
    try {
      await Share.file(
        'esys image',
        'esys.png',
        pngBytes,
        'image/png',
        text: allMessages.value.shareMessage,
      );
    } catch (e) {
      BotToast.showText(text: "shareImage $e");
    }
    BotToast.cleanAll();
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 0.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(radius, 0.0);
    path.arcToPoint(Offset(0.0, radius),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(0.0, size.height - radius);
    path.lineTo(size.width - 0.58 * size.width, size.height);
    path.lineTo(size.width - 0.45 * size.width, radius);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path1 = Path();
    path1.moveTo(0, size.height);
    path1.quadraticBezierTo(
        size.width / 2.5, size.height, size.width / 3, size.height);
    path1.lineTo(size.width / 2, 0);
    path1.lineTo(0, 0);
    Path path2 = Path();
    path2.moveTo(size.width / 3, size.height);
    path2.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width / 2, 0);

    Paint paint1 = Paint()..color = HexColor("#FFAF7E");
    Paint paint2 = Paint()..color = HexColor("#AA83F8");

    canvas.drawPath(path1, paint1);

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BlogNameAndDetails extends StatelessWidget {
  final Blog blog;

  BlogNameAndDetails({this.blog});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.85 * MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              blog.title,
              style: Theme.of(context).textTheme.bodyText1.merge(
                    TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 25.0,
                        fontWeight: FontWeight.normal),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayImage extends StatelessWidget {
  final Blog item;
  final Function onCaresoulChange;
  final int currentIndex;

  OverlayImage({this.item, this.onCaresoulChange, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        item.contentType == "video"
            ? CustomVideoPlayer(
                blog: item,
              )
            : item.bannerImage.length > 1
                ? Positioned(
                    child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.6,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                onCaresoulChange(index);
                              },
                            ),
                            items: item.bannerImage
                                .map<Widget>((item) => Container(
                                      child: Center(
                                          child: Image.network(
                                        item,
                                        fit: BoxFit.cover,
                                        height: height,
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
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: item.bannerImage.map<Widget>((url) {
                              int index = item.bannerImage.indexOf(url);
                              return Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentIndex == index
                                        ? Color.fromRGBO(0, 0, 0, 0.9)
                                        : Color.fromRGBO(0, 0, 0, 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ))
                : Positioned.fill(
                    child: Image.network(
                    item.bannerImage[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  )),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(top: 33.0, right: 16.0),
          child: Opacity(
            opacity: 0.6,
            child: ButtonTheme(
              minWidth: 0.07 * width,
              height: 0.04 * height,
              child: RaisedButton(
                padding: EdgeInsets.only(
                  right: 9,
                  left: 9,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed('/HomeClonePage', arguments: false);
                },
                color: Colors.black,
                child: Wrap(
                  children: [
                    Icon(
                      Mdi.eye,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        " " + item.viewCount.toString(),
                        style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
