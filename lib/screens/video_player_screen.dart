import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // 비디오 파일의 URL을 전달받습니다.

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // 비디오 컨트롤러 초기화가 완료되면 화면을 갱신합니다.
        setState(() {});
        _videoController.play(); // 비디오를 재생합니다.
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // 비디오 컨트롤러를 해제합니다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비디오 재생'),
      ),
      body: Center(
        child: _videoController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        )
            : CircularProgressIndicator(), // 비디오 로딩 중에는 로딩 인디케이터를 표시합니다.
      ),
    );
  }
}