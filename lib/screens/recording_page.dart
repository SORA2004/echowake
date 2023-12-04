import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  String _recordedFilePath = '';
  bool _isPlaying = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  String _statusMessage = '준비 중...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    setState(() {});
  }

  Future<void> _startRecording() async {
    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      return;
      setState(() {
        _isRecording = true;
        _isLoading = true; // 로딩 시작
      });
    }

    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
      _statusMessage = '녹음 중...';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 시작!')),
    );
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isLoading = false;
      _statusMessage = '녹음 완료!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 완료!')),
    );
  }

  Future<void> _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_recordedFilePath.isNotEmpty) {
        await _audioPlayer.setSource(DeviceFileSource(_recordedFilePath));
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath));
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('녹음'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_statusMessage),
                Text('녹음 페이지'),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                ),
                if (_recordedFilePath.isNotEmpty) ...[
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _playPauseAudio,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_recordedFilePath);
                    },
                    child: Text('추가'),
                  ),
                ],
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}