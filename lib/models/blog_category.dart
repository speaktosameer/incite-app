import 'dart:convert';

BlogCategory blogCategoryFromMap(String str) =>
    BlogCategory.fromMap(json.decode(str));

String blogCategoryToMap(BlogCategory data) => json.encode(data.toMap());

class BlogCategory {
  BlogCategory({
    this.status,
    this.message,
    this.data,
  });

  bool status;
  String message;
  List<Datum> data;

  factory BlogCategory.fromMap(Map<String, dynamic> json) => BlogCategory(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.status,
    this.image,
    this.index,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.blog,
  });

  int id;
  String name;
  int status;
  dynamic image;
  int index;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  List<Blog> blog;

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        image: json["image"],
        index: json["index"],
        createdAt: json["created_at"],
        //createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        blog: List<Blog>.from(json["blog"].map((x) => Blog.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": status,
        "image": image,
        "index": index,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "blog": List<dynamic>.from(blog.map((x) => x.toMap())),
      };
}

class Blog {
  Blog(
      {this.id,
      this.title,
      this.shortDescription,
      this.description,
      this.trimedDescription,
      this.thumbImage,
      this.bannerImage,
      this.authorImage,
      this.isFeatured,
      this.isVote,
      this.isBookmarked,
      this.isVotingEnabled,
      this.yesPercent,
      this.noPercent,
      this.viewCount,
      this.url,
      this.status,
      this.blogAccentCode,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.authorName,
      this.time,
      this.categoryName,
      this.categoryColor,
      this.createDate,
      this.contentType,
      this.videoUrl});

  int id;
  String videoUrl;
  String contentType;
  String title;
  String shortDescription;
  String description;
  String trimedDescription;
  dynamic thumbImage;
  dynamic bannerImage;
  String blogAccentCode;
  //Map<String, dynamic> bannerImage;
  //List<String> bannerImage;
  dynamic authorImage;
  int isFeatured;
  int isVote;
  int isBookmarked;
  int isVotingEnabled;
  dynamic yesPercent;
  dynamic noPercent;
  int viewCount;
  String url;
  int status;
  DateTime createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  String authorName;
  String time;
  String categoryName;
  String categoryColor;
  dynamic createDate;

  factory Blog.fromMap(Map<String, dynamic> json) => Blog(
        id: json["id"],
        title: json["title"],
        shortDescription: json["short_description"],
        description: json["description"],
        trimedDescription: json["trimed_description"],
        thumbImage: json["thumb_image"],
        bannerImage: json["banner_image"],
        authorImage: json["image"],
        isFeatured: json["is_featured"],
        isVote: json["is_vote"],
        isBookmarked: json["is_bookmark"],
        isVotingEnabled: json["is_voting_enable"],
        yesPercent: json["yes_percent"],
        noPercent: json["no_percent"],
        viewCount: json["view_count"],
        url: json["url"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        authorName: json["author_name"],
        time: json["time"],
        categoryName: json["category_name"],
        categoryColor: json["color"],
        createDate: json["create_date"],
        videoUrl: json['video_url'],
        contentType: json['content_type'],
        blogAccentCode: json['blog_accent_code'],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "short_description": shortDescription,
        "description": description,
        "trimed_description": trimedDescription,
        "thumb_image": thumbImage,
        "banner_image": bannerImage,
        //List<dynamic>.from(bannerImage.map((x) => x)),
        "image": authorImage,
        "is_featured": isFeatured,
        "is_vote": isVote,
        "is_bookmark": isBookmarked,
        "is_voting_enable": isVotingEnabled,
        "yes_percent": yesPercent,
        "no_percent": noPercent,
        "view_count": viewCount,
        "url": url,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "author_name": authorName,
        "time": time,
        "category_name": categoryName,
        "color": categoryColor,
        "create_date": createDate,
        "blog_accent_code": blogAccentCode
      };
}
