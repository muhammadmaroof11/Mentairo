import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final String userRole; // "mentor" or "student"

  const CallPage({
    super.key,
    required this.channelName,
    required this.userRole,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  static const String appId = 'fe6aa6cbd1d4486a8c7d32f4d95317e4';
  int? _remoteUid;
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _muted = false;
  bool _cameraOff = false;
  bool _isRemoteCameraOff = false;

  Offset _localVideoPosition = const Offset(16, 100);

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));
    await _engine!.enableVideo();
    await _engine!.startPreview();

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Local user joined: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
            _isRemoteCameraOff = false;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
        onRemoteVideoStateChanged: (
            RtcConnection connection,
            int remoteUid,
            RemoteVideoState state,
            RemoteVideoStateReason reason,
            int elapsed,
            ) {
          if (remoteUid == _remoteUid) {
            setState(() {
              _isRemoteCameraOff = (state == RemoteVideoState.remoteVideoStateStopped ||
                  state == RemoteVideoState.remoteVideoStateFrozen);
            });
          }
        },
      ),
    );

    await _engine!.joinChannel(
      token: '007eJxTYPDMnn5lTcjLiyY/tq5+W/nshlpGKeO2R21zko4mrkqw3v1agSEt1Swx0Sw5KcUwxcTEwizRItk8xdgozSTF0tTY0DzV5PypwoyGQEaGr2dmsDAyQCCIz8KQl5meyMAAAJHUJD4=',
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    setState(() {
      _isInitialized = true;
    });
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _engine?.muteLocalAudioStream(_muted);
  }

  void _toggleCamera() {
    setState(() => _cameraOff = !_cameraOff);
    _engine?.muteLocalVideoStream(_cameraOff);
  }

  void _switchCamera() {
    _engine?.switchCamera();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Widget _buildLocalPreview() {
    return _cameraOff
        ? const Center(child: Icon(Icons.person, size: 60, color: Colors.white38))
        : AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (_remoteUid == null) {
      return const Center(child: Text('Waiting for user to join...', style: TextStyle(color: Colors.white)));
    }
    if (_isRemoteCameraOff) {
      return const Center(child: Icon(Icons.person, size: 100, color: Colors.white54));
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {Color? bgColor, Color? iconColor}) {
    return Material(
      color: bgColor ?? Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.black),
        onPressed: onPressed,
        iconSize: 28,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoSize = const Size(120, 160);

    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(child: _buildRemoteVideo()),

          // Local Video Preview - draggable
          Positioned(
            left: _localVideoPosition.dx,
            top: _localVideoPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newX = _localVideoPosition.dx + details.delta.dx;
                  double newY = _localVideoPosition.dy + details.delta.dy;

                  newX = newX.clamp(0.0, screenSize.width - videoSize.width);
                  newY = newY.clamp(0.0, screenSize.height - videoSize.height - 100);

                  _localVideoPosition = Offset(newX, newY);
                });
              },
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: videoSize.width,
                  height: videoSize.height,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildLocalPreview(),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls Bar
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      _muted ? Icons.mic_off : Icons.mic,
                      _toggleMute,
                      iconColor: _muted ? Colors.red : Colors.black,
                    ),
                    const SizedBox(width: 20),
                    _buildControlButton(
                      _cameraOff ? Icons.videocam_off : Icons.videocam,
                      _toggleCamera,
                      iconColor: _cameraOff ? Colors.red : Colors.black,
                    ),
                    const SizedBox(width: 20),
                    _buildControlButton(Icons.switch_camera, _switchCamera, iconColor: Colors.black),
                    const SizedBox(width: 20),
                    _buildControlButton(
                      Icons.call_end,
                          () => Navigator.pop(context),
                      bgColor: Colors.red,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
