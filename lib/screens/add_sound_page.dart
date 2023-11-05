import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'recording_page.dart';
import 'sound_share_page.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class AddSoundPage extends StatefulWidget {
  @override
  _AddSoundPageState createState() => _AddSoundPageState();
}

class _AddSoundPageState extends State<AddSoundPage> {
  String? _recordedAudioPath;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController(); // 태그 컨트롤러 추가
  String? _audioUrl;
  bool _isLoading = false;
  bool _isPlaying = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  String category = ''; // 카테고리 상태 변수
  List<String> tags = []; // 태그 상태 변수

  void _saveSoundToFirestore(String audioUrl) {
    FirebaseFirestore.instance.collection('audio_files').add({
      'category': category,
      'tags': tags,
      'audioUrl': audioUrl, // 오디오 파일의 URL을 저장합니다.
    });
  }

  Future<void> _uploadAudioFile(String filePath) async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    File file = File(filePath);
    String fileName = basename(filePath);
    Reference ref = FirebaseStorage.instance.ref().child('audio_files/$fileName');

    int recordTime = await _calculateRecordTime(filePath); // 녹음 시간 계산

    SettableMetadata metadata = SettableMetadata(
      customMetadata: {
        'uploadTime': DateTime.now().toIso8601String(),
        'recordTime': recordTime.toString(),
      },
    );

    UploadTask uploadTask = ref.putFile(file, metadata);
    await uploadTask.whenComplete(() async {
      String downloadUrl = await ref.getDownloadURL();
      _saveSoundToFirestore(downloadUrl);
      setState(() {
        _audioUrl = downloadUrl;
        _isLoading = false; // 로딩 종료
      });
    });
  }


  Future<int> _calculateRecordTime(String filePath) async {
    int recordTime = 0;
    // TODO: 오디오 파일의 길이를 계산하여 recordTime에 할당
    // audioplayers 패키지를 사용하거나 다른 방법을 사용할 수 있습니다.
    return recordTime;
  }

  void _uploadAndAddSound(BuildContext context) async {
    if (_recordedAudioPath != null) {
      await _uploadAudioFile(_recordedAudioPath!);
      // 파일을 업로드하고 기다림
      // 새로운 Sound 객체를 생성
      Sound newSound = Sound(
        id: '적절한 id', // 적절한 id를 설정해주세요.
        title: _titleController.text,
        profileName: '현재 사용자', // 현재 사용자의 프로필 이름을 적절히 설정
        likes: 0,
        likedBy: [], // likedBy를 적절히 설정해주세요.
        audioUrl: _audioUrl!,
        profileImageUrl: '',
        category: '',
        tags: [], downloadUrl: '', // 빈 문자열 또는 기본 이미지 URL을 전달
      );

      // TODO: newSound를 sounds 리스트에 추가
      // 이 부분은 SoundSharePage의 상태를 업데이트하는 방법에 따라 다를 수 있습니다.

      Navigator.of(context).pop(); // 현재 페이지를 닫고 이전 페이지로 돌아감
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _audioPlayer.dispose(); // 오디오 플레이어 리소스 해제
    super.dispose();
  }

  Future<void> _playPauseAudio(String audioUrl) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSource(UrlSource(audioUrl));
      await _audioPlayer.resume(); // URL을 설정한 후에 재생을 시작합니다.
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사운드 추가'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: '카테고리'),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                ),
                TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(labelText: 'Tags (comma separated)'),
                  onChanged: (value) {
                    setState(() {
                      tags = value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _uploadAndAddSound(context);
                  },
                  child: Text('추가'),
                ),
                if (_audioUrl != null)
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      _playPauseAudio(_audioUrl!);
                    },
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final recordedAudioPath = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (BuildContext context) => RecordingPage(),
            ),
          );
          if (recordedAudioPath != null && recordedAudioPath.isNotEmpty) {
            setState(() {
              _recordedAudioPath = recordedAudioPath;
            });
          }
        },
        child: Icon(Icons.mic),
      ),
    );
  }
}