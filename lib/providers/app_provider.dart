import 'dart:convert';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppProvider with ChangeNotifier {
  bool _load = false;
  BlogCategory _blog;
  var _blogList;

  AppProvider() {
    //_getCurrentUser();
    getCategory();
    getBlogData();
  }

  BlogCategory get blog => _blog;

  get blogList => _blogList ?? [];

  bool get load => _load;

  _getCurrentUser() {
    getCurrentUser();
  }

  setLoading({bool load}) {
    this._load = load;
    notifyListeners();
  }

  Future getCategory() async {
    print('getCategory is called');
    try {
      setLoading(load: true);
      var url = "https://incite.technofox.co.in/api/blog-category-list";
      var result = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id,
          "lang-code": languageCode.value?.language ?? null
        },
      );
      Map data = json.decode(result.body);
      _blog = BlogCategory.fromMap(data);
      setLoading(load: false);
    } catch (e) {
      setLoading(load: false);
    }
  }

  Future getBlogData() async {
    // try {
    print('getBlogData is called');
    var url = "https://incite.technofox.co.in/api/blog-list";
    setLoading(load: true);
    var headers = {
      "Content-Type": "application/json",
      'userData': currentUser.value.id,
    };
    if (languageCode.value != null) {
      headers.addAll({"lang-code": languageCode.value?.language ?? null});
    }
    var result = await http.get(url, headers: headers);
    print('headers are ${result.headers}');
    setLoading(load: false);
    Map data = json.decode(result.body);
    print('data is $data');
    final list =
        (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    _blogList = list;
    blogListHolder.clearList();
    blogListHolder.setList(list);
    notifyListeners();
    print('blog list is ${_blogList.length}');
    // } catch (e) {
    //   setLoading(load: false);
    // }
  }
}
