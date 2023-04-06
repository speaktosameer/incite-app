import 'package:blog_app/controllers/e_live_new_controller.dart';
import 'package:blog_app/pages/show_news_paper.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../app_theme.dart';

class Enews extends StatefulWidget {
  @override
  _EnewsState createState() => _EnewsState();
}

class _EnewsState extends StateMVC {
  ELiveNewsController eLiveNewsController;

  _EnewsState() : super(ELiveNewsController()) {
    eLiveNewsController = ELiveNewsController();
  }

  @override
  void initState() {
    super.initState();
    eLiveNewsController.getENews().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).canvasColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        title: Text(allMessages.value.eNews,
            style: TextStyle(
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
            )),
      ),
      body: eLiveNewsController.eNews == null
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: eLiveNewsController.eNews.length,
              separatorBuilder: (context, _) {
                return Divider(
                  indent: 2,
                  thickness: 2,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowNewsPaper(
                          enews: eLiveNewsController.eNews[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.network(
                          'https://incite.technofox.co.in/upload/e-paper/original/' +
                              eLiveNewsController.eNews[index].image,
                          height: 75,
                          width: 75,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              eLiveNewsController.eNews[index].paperName,
                              style: TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
