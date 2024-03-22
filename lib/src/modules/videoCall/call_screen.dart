import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_assessment/src/modules/dashboard/main_screen_controller.dart';
import 'call_controller.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';


class VideoCall extends StatelessWidget {
  final controller = Get.put(CallController());
  final mainController = Get.find<MainScreenController>();

  VideoCall({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          final isLocalUserJoined = controller.localUserJoined.value;
          final isVideoPaused = controller.videoPaused.value;
          final hasRemoteUid = controller.myRemoteUid.value != 0;

          return TikTokStyleFullPageScroller(
              contentSize: 3,
              builder: (context, index){
                mainController.tikIndex.value = index;

            return Padding(
              padding: const EdgeInsets.all(10),
              // child: Container(
              //   height: Get.height,
              //   width: Get.width,
              //   color: Colors.white,
              //   child: Center(child: Text(index.toString(), style: TextStyle(color: Colors.redAccent, fontSize: 50),)),
              // ),
              child: Stack(
                children: [
                  Center(
                    child: isLocalUserJoined && isVideoPaused
                        ? Container(
                      color: Theme.of(context).primaryColor,
                      child: Center(
                        child: Text(
                          "Remote Video Paused",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                    )
                        : hasRemoteUid
                        ? controller.disableVideo.value
                        ? Image.network(
                      'https://media.wired.com/photos/5c81afc312440d0f262d3b60/16:9/w_3840,h_2160,c_limit/Genderless-Voice_02.jpg',
                      height: Get.height,
                      fit: BoxFit.fill,
                    )
                        : AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: controller.engine,
                        canvas: VideoCanvas(
                            uid: controller.myRemoteUid.value),
                        connection: const RtcConnection(
                            channelId: 'test channel'),
                      ),
                    )
                        : const Center(
                      child: Text(
                        'No Remote',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 100,
                      height: 150,
                      child: Center(
                        child: isLocalUserJoined
                            ? Visibility(
                          visible: !controller.disableVideo.value,
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: controller.engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        CircleIconButton(
                          onTap: () => controller.onToggleMute(),
                          icon:
                          controller.muted.value ? Icons.mic_off : Icons.mic,
                          color: Colors.grey,
                        ),
                        CircleIconButton(
                          onTap: () => controller.onCallEnd(),
                          icon: Icons.call_end,
                          color: Colors.red,
                        ),
                        Visibility(
                          visible: !controller.disableVideo.value,
                          child: CircleIconButton(
                            onTap: () => controller.onSwitchCamera(),
                            icon: Icons.switch_camera,
                            color: Colors.blue,
                          ),
                        ),
                        CircleIconButton(
                          onTap: () => controller.disableVideoStream(),
                          icon: Icons.camera,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        }),
      ),
    );
  }
  void callNext(index){

  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Function() onTap;

  const CircleIconButton({
    required this.icon,
    required this.color,
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            icon,
            size: 35,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
