import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_assessment/src/utils/handler.dart';
import 'package:video_assessment/src/utils/helper.dart';

import '../main.dart';
import 'modules/auth/user_auth.dart';
import 'modules/dashboard/main_screen.dart';
import 'modules/videoCall/call_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceivedMethod);
    super.initState();
  }

  @pragma('vm:entry-point')
  Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      return onActionReceivedImplementationMethod(receivedAction);
    } else {
      await fireStore.collection('userCollection').doc(receivedAction.payload!['userId']).update({
        'rejected': true
      });
    }
  }

  Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async => onJoin(receivedAction.payload);

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((event) => messageHandler(event));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainScreen();
          }
          return AuthGate();
        },
      ),
      getPages: [
        GetPage( name: '/callScreen', page: () => VideoCall()),
        GetPage( name: '/loginScreen', page: () => AuthGate()),
        GetPage( name: '/mainScreen', page: () => MainScreen())
      ],
    );
  }
}