import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_assessment/main.dart';
import 'package:video_assessment/src/modules/dashboard/main_screen_controller.dart';
import 'package:video_assessment/src/modules/service/firebase_service.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final controller = Get.put(MainScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Calling'),
        actions: [
          ElevatedButton(onPressed: () async {
            FirebaseService.updateUserMeta('token', '');
            await auth.signOut();
            Get.offAllNamed('/loginScreen');
          }, child: const Icon(Icons.logout))
        ],
      ),
      body:

      StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersStream(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      // If there's no data, display a message or return an empty widget.
      if (snapshot.data!.docs.isEmpty) {
        return const Text('No users found.');
      }

      return AnimatedList(
        initialItemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index, animation) {
          final user = snapshot.data!.docs[index].data() as Map<String, dynamic>;
          final userId = auth.currentUser == null ? '' : auth.currentUser!.uid;
    if (user['userId'] != userId) {
      return SizeTransition(
        sizeFactor: animation,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(6),
            title: Text(user['userName']),
            subtitle: Text('ID: ${user['userId']}'),
            trailing: Wrap(
              children: [
                IconButton(
                  icon:  Icon(Icons.video_call, color: user['isAvailable'] == true ? Colors.green : Colors.grey,),
                  onPressed: user['isAvailable'] == true ? () {
                    controller.sendNotification(user, index);
                  } : null,
                ),
                IconButton(
                  onPressed: user['isAvailable'] == true ? () {
                    controller.sendNotification(user, index, isAudio: '1');
                  } : null,
                  icon: Icon(Icons.call, color: user['isAvailable'] == true ? Colors.green : Colors.grey,),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
        },
      );
    }
      ));
  }
}