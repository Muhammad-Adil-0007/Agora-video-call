import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../utils/helper.dart';
import '../../utils/settings.dart';
import '../dashboard/main_screen.dart';
import '../service/firebase_service.dart';

class CallController extends GetxController {
  RxInt myRemoteUid = 0.obs;
  RxBool localUserJoined = false.obs;
  RxBool muted = false.obs;
  RxBool videoPaused = false.obs;
  RxBool disableVideo = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  late RtcEngine engine;

  @override
  Future<void> onInit() async {
    super.onInit();
    var snapshot = fireStore
        .collection('userCollection')
        .doc(auth.currentUser!.uid)
        .snapshots();
    snapshot.listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['rejected'] == true) {
          FirebaseService.updateUserMeta('rejected', false);
          myRemoteUid.value = 0;
          onCallEnd();
        }
      }
    });
    initialize();
  }

  @override
  void onClose() {
    super.onClose();
    clear();
  }

  clear() {
    engine.leaveChannel();
    engine.release();
    reConnectingRemoteView.value = false;
    videoPaused.value = false;
    muted.value = false;
    mutedVideo.value = false;
    localUserJoined.value = false;
    disableVideo.value = false;
  }

  Future<void> initialize() async {
    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      VideoEncoderConfiguration configuration =
          const VideoEncoderConfiguration();
      await engine.setVideoEncoderConfiguration(configuration);
      await engine.leaveChannel();
      await engine.joinChannel(
        token: Get.arguments['token'],
        channelId: Get.arguments['channel_id'],
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      if (Get.arguments['isAudio'] == '1') {
        disableVideoStream();
        Future.delayed(const Duration(seconds: 1))
            .then((value) => engine.setEnableSpeakerphone(!disableVideo.value));
      }
    });
  }

  Future<void> _initAgoraRtcEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await engine.enableVideo();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  void _addAgoraEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType error, String s) {
          ScaffoldSnackbar.of(Get.context!).show(error.name);
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          localUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          localUserJoined.value = true;
          myRemoteUid.value = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          myRemoteUid.value = 0;
          onCallEnd();
        },
        onRemoteVideoStats:
            (RtcConnection connection, RemoteVideoStats remoteVideoStats) {
          if (remoteVideoStats.receivedBitrate == 0) {
            videoPaused.value = true;
          } else {
            videoPaused.value = false;
          }
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {},
        onLeaveChannel: (RtcConnection connection, stats) {
          onCallEnd();
        },
      ),
    );
  }

  onVideoOff() {
    mutedVideo.value = !mutedVideo.value;
    engine.muteLocalVideoStream(mutedVideo.value);
  }

  onCallEnd() async {
    clear();
    FirebaseService.updateUserMeta('isAvailable', true);
    Get.offAll(() => MainScreen());
  }

  onToggleMute() {
    muted.value = !muted.value;
    engine.muteLocalAudioStream(muted.value);
  }

  onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine.muteLocalVideoStream(mutedVideo.value);
  }

  onSwitchCamera() {
    engine.switchCamera().then((value) => {}).catchError((err) {});
  }

  disableVideoStream() {
    disableVideo.value = !disableVideo.value;
    engine.setEnableSpeakerphone(!disableVideo.value);
  }
}
