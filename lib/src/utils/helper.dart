import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_assessment/src/modules/videoCall/call_screen.dart';

import '../modules/service/firebase_service.dart';

Future<void> onJoin(Map<String, String?>? payload) async {
  await _handleCameraAndMic(Permission.camera);
  await _handleCameraAndMic(Permission.microphone);
  FirebaseService.updateUserMeta('isAvailable', false);
  Get.to(VideoCall(), arguments: payload, transition: Transition.rightToLeft);
}

Future<void> _handleCameraAndMic(Permission permission) async {
  await permission.request();
}

Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return token;
}

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
