import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:blog_app/models/e_news.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';

class ShowNewsPaper extends StatefulWidget {
  final ENews enews;
  ShowNewsPaper({this.enews});
  @override
  _ShowNewsPaperState createState() => _ShowNewsPaperState();
}

class _ShowNewsPaperState extends State<ShowNewsPaper> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
        "https://incite.technofox.co.in/upload/e-paper/pdf/" +
            widget.enews.pdf);

    setState(() => _isLoading = false);
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
        title: Text(widget.enews.paperName,
            style: TextStyle(
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
            )),
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document,
                zoomSteps: 1,
                scrollDirection: Axis.vertical,
                showPicker: false,
                //uncomment below line to preload all pages
                // lazyLoad: false,
                // uncomment below line to scroll vertically
                // scrollDirection: Axis.vertical,

                //uncomment below code to replace bottom navigation with your own
                /* navigationBuilder:
                      (context, page, totalPages, jumpToPage, animateToPage) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed: () {
                            jumpToPage()(page: 0);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            animateToPage(page: page - 2);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            animateToPage(page: page);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.last_page),
                          onPressed: () {
                            jumpToPage(page: totalPages - 1);
                          },
                        ),
                      ],
                    );
                  }, */
              ),
      ),
    );
  }
}
