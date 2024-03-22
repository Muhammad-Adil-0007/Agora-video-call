import 'package:get/get.dart';

import '../../../main.dart';
import '../../utils/helper.dart';

class FirebaseService {
  static registerUser({String email = ''}) async {
    var user = auth.currentUser!;
    String? token = await getToken();
    await fireStore.collection('userCollection').doc(user.uid).set({
      'isAvailable': true,
      'token': token,
      'email': email,
      'userName': 'Test user',
      'userId': user.uid,
      'rejected': false,
      'accepted': false,
    });
    Get.offAllNamed("/mainScreen");
  }

  static updateUserMeta(key, value) async {
    await fireStore
        .collection('userCollection')
        .doc(auth.currentUser!.uid)
        .update({
      key: value,
    });
  }
}
