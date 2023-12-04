import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';
import 'main_screen.dart';

class UploadPage extends StatefulWidget {
  final Function updateHome;

  const UploadPage({Key? key, required this.updateHome}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  VideoPlayerController? _videoController;
  Image? _thumbnailImage;
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _thumbnailPath;
  String? _videoPath;
  String? _audioPath;
  String? _audioExtension;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
        _playAudio();
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() {
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
        });
      });
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _pickThumbnailImage() async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile != null) {
      setState(() {
        _thumbnailPath = imageFile.path;
        _thumbnailImage = Image.file(File(_thumbnailPath!)); // 이미지 위젯 업데이트
      });
    }
  }

  Future<Map<String, dynamic>> _write(
      String videoUrl, String videoThumbnailUrl) async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      String? uid = firebaseAuth.currentUser?.uid;

      // 로그인 없이 업로드 테스트 하실 때에는 if문 부분을 주석처리 해주시고
      // uid 에 임의로 넣으신 후 테스트 하시면 됩니다.
      if (uid != null) {
        await FirebaseFirestore.instance.collection('posts').doc().set({
          'uid': 'tests',
          'title': _titleController.value.text,
          'videoUrl': videoUrl,
          'videoThumbnailUrl': videoThumbnailUrl,
          'likeCount': 0,
          'viewCount': 0,
          'downloadCount': 0,
        });

        return {'success': true};
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false};
    }
  }

  Future<void> _uploadAndNavigate() async {
    final uploadResult = await uploadAudioAndThumbnail();
    if (uploadResult['success']) {
      final writeResult =
      await _write(uploadResult['audioUrl'], uploadResult['thumbnailUrl']);
      if (writeResult['success']) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('쓰기에 실패했습니다.'),
        ));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('업로드에 실패했습니다.'),
      ));
    }
  }

  Future<Map<String, dynamic>> uploadAudioAndThumbnail() async {
    final FirebaseStorage storage =
    FirebaseStorage.instanceFor(bucket: 'gs://echowake-b5331.appspot.com');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null && _audioPath != null && _thumbnailPath != null) {
      final File audioFile = File(_audioPath!);
      final File thumbnailFile = File(_thumbnailPath!);
      final String userId = user.uid;

      try {
        // Firebase Storage에 동영상 파일 업로드
        // 파일 확장자는 getExtensionFromFileName 로 파일 네임을 넣어서 추출해서 가져오거나
        // 선택 확장자에서 aac 만 고정적으로 가져올 수 있게 해도 됩니다.
        final audioRef = storage.ref(
            'audios/$userId/${DateTime.now().millisecondsSinceEpoch}.${_audioExtension ?? 'aac'}');
        await audioRef.putFile(audioFile);
        final String audioUrl = await audioRef.getDownloadURL();

        // Firebase Storage에 썸네일 이미지 파일 업로드
        final thumbnailRef = storage.ref(
            'thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await thumbnailRef.putFile(thumbnailFile);
        final String thumbnailUrl = await thumbnailRef.getDownloadURL();

        // 업로드된 파일의 URL을 반환
        return {
          'success': true,
          'audioUrl': audioUrl,
          'thumbnailUrl': thumbnailUrl
        };
      } catch (error) {
        if (kDebugMode) {
          print('업로드 에러: $error');
        }
        return {'success': false};
      }
    } else {
      // 필요한 정보가 없거나 사용자가 로그인하지 않은 경우
      return {'success': false};
    }
  }

  // 확장자 추출
  String getExtensionFromFileName(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 150,
      quality: 75,
    );

    setState(() {
      if (thumbnailPath != null) {
        _thumbnailImage = Image.file(File(thumbnailPath));
        _thumbnailPath = thumbnailPath;
      }
    });
    return thumbnailPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('업로드'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오디오 제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '오디오 제목을 입력해주세요',
                      labelText: '오디오 제목',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '오디오 업로드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickAudio,
                  child: Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: _audioPath != null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.music_note,
                          size: 50,
                          color: Colors.blue,
                        ),
                        Text(
                          _audioPath!.split('/').last,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                              onPressed: () {
                                if (_isPlaying) {
                                  _pauseAudio();
                                } else {
                                  _playAudio();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                        : const Icon(
                      Icons.cloud_upload,
                      size: 80,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),// 이 부분이 수정된 부분입니다.
              const Text(
                '썸네일 업로드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickThumbnailImage,
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: _thumbnailImage != null
                        ? Image.file(File(_thumbnailPath!))
                        : Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "터치하여 썸네일 이미지를 바꿔보세요",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _uploadAndNavigate,
                  child: const Text('업로드하기'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}