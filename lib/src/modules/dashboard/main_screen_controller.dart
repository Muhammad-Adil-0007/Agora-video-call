import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:video_assessment/main.dart';

import '../../utils/helper.dart';
import '../../utils/settings.dart';
import 'package:http/http.dart' as http;

class MainScreenController extends GetxController {
  RxList<dynamic> users = [].obs;
  RxInt index = 0.obs;
  RxInt tikIndex = 0.obs;


  Stream<QuerySnapshot> getUsersStream() {
    return fireStore.collection('userCollection').snapshots();
  }

  void sendNotification(user, userIndex, {String isAudio = '0'}) async {

    index.value = userIndex;

    String deviceFCMToken = user['token'];

    Map<String, String> data = {
      'channel_id': 'test channel',
      'token': token,
      'app_id': appId,
      'isAudio': isAudio,
      'userId': auth.currentUser!.uid
    };

    Map<String, dynamic> requestBody = {
      "to": deviceFCMToken,
      "collapse_key": "New Message",
      "priority": "high",
      "notification": {
        "title": "Incoming call",
        "body": "You can accept or reject the incoming call",
      },
      'data': data
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "key=$serverKey",
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        onJoin(data);
      } else {}
    } catch (e) {
      print("Error: $e");
    }
  }
}
