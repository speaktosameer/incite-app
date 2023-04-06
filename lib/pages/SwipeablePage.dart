import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/pages/read_blog.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:preload_page_view/preload_page_view.dart';

class SwipeablePage extends StatefulWidget {
  final int index;
  SwipeablePage(this.index);

  @override
  _SwipeablePageState createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage> {
//  PageController pageController;
  PreloadPageController pageController;
  double height, width;
  int currentPage = 0;
  @override
  void initState() {
    super.initState();
    // pageController = PageController(initialPage: widget.index);
    pageController = PreloadPageController(initialPage: widget.index);
    currentPage = widget.index;
    pageController.addListener(listener);
    if (blogListHolder.getList().length == 1) {
      Fluttertoast.showToast(msg: "Last News");
    }
  }

  listener() {
    if (pageController.position.atEdge) {
      if (pageController.position.pixels == 0) {
        // Fluttertoast.showToast(msg: "T");

      } else {
        Fluttertoast.showToast(msg: "Last News");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      color: HexColor("#323232"),
      child: PreloadPageView.builder(
        itemBuilder: (ctx, index) {
          return ReadBlog(blogListHolder.getList()[index]);
        },
        itemCount: blogListHolder.getList().length,
        scrollDirection: Axis.vertical,
        preloadPagesCount: 0,
        // reverse: true,
        //allowImplicitScrolling: false,
        physics: CustomPageViewScrollPhysics(),
        controller: pageController,
        pageSnapping: true,
        onPageChanged: (value) {
          print("page change");
          currentUser.value.isNewUser = false;
          blogListHolder.setIndex(value);
          // currentUser.value =
          //     Users.fromJSON(json.decode(prefs.get('current_user')));
          currentPage = value;
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.removeListener(listener);
    pageController.dispose();
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
