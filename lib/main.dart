import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:video_assessment/src/app.dart';
import 'package:video_assessment/src/utils/handler.dart';

import 'firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late final FirebaseFirestore fireStore;

Future<void> main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(channelKey: 'call_channel', channelName: 'Call Channel', channelDescription: 'Chanel of calling', importance: NotificationImportance.Max,
    channelShowBadge: true,
    locked: true,
    defaultRingtoneType: DefaultRingtoneType.Ringtone)
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  fireStore = FirebaseFirestore.instanceFor(app: app);
  runApp(const MyApp());
}