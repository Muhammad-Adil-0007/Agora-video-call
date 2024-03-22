import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> messageHandler(RemoteMessage msg)async {
  String? title = msg.notification!.title;
  String? body = msg.notification!.body;
  Map<String, String?>? data = msg.data.cast<String, String?>();
  AwesomeNotifications().createNotification(content: NotificationContent(
    id: 1,
    channelKey: 'call_channel',
    color: Colors.white,
    title: title,
    body: body,
    category: NotificationCategory.Call,
    wakeUpScreen: true,
    fullScreenIntent: true,
    autoDismissible: false,
    backgroundColor: Colors.orange,
    payload: data,
  ),
      actionButtons: [
        NotificationActionButton(key: 'ACCEPT', label: 'Accept call', color: Colors.green),
        NotificationActionButton(key: 'REJECT', label: 'Reject call', color: Colors.red),
      ]
  );
}