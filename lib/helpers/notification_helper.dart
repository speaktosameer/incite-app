import 'dart:convert';

import 'package:blog_app/models/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  showNotificationWithDefaultSound(message);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print("data $data");
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print("data $notification");
  }
}

Future showNotificationWithDefaultSound(Map<dynamic, dynamic> message) async {
  NotificationResponse notificationResponse =
      NotificationResponse.fromJsonMap(jsonDecode(jsonEncode(message)));
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    color:
        notificationResponse.notificationDataModel?.color ?? Color(0xff203E78),
    importance: Importance.max,
    icon: "logo",
    priority: Priority.high,
    playSound: true,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  if (flutterLocalNotificationsPlugin != null)
    await flutterLocalNotificationsPlugin.show(
      0,
      notificationResponse.notification != null
          ? notificationResponse.notificationDataModel.title
          : "New Notification",
      notificationResponse.notification != null
          ? notificationResponse.notificationDataModel.body
          : "",
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
}

Future notificationOnMessage(Map<String, dynamic> message) async {
  print("notificationOnMessage $message");
}
