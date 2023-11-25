import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'home_page.dart';

class UploadPage extends StatefulWidget {
  final Function updateHome; // 홈 화면으로 이동하는 콜백 함수

  UploadPage({required this.updateHome}); // 생성자에 매개변수 추가

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  VideoPlayerController? _videoController;
  Image? _thumbnailImage;
  TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _thumbnailPath; // 선택한 이미지의 파일 경로

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final XFile? videoFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (videoFile != null) {
      setState(() {
        _videoController = VideoPlayerController.file(File(videoFile.path))
          ..initialize().then((_) {
            setState(() {});
            _generateThumbnail(videoFile.path); // 썸네일 생성
          });
      });
    }
  }

  Future<void> uploadVideoAndThumbnail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      final String userId = user.uid;

      if (_videoController != null && _thumbnailPath != null) {
        final String videoPath = _videoController!.dataSource!;
        final File thumbnailFile = File(_thumbnailPath!);

        try {
          // Firebase Storage에 동영상 파일 업로드
          final videoRef = firebase_storage.FirebaseStorage.instance
              .ref('videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4');
          await videoRef.putFile(File(videoPath));

          // Firebase Storage에 썸네일 이미지 파일 업로드
          final thumbnailRef = firebase_storage.FirebaseStorage.instance
              .ref('thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await thumbnailRef.putFile(thumbnailFile);
          // 업로드 성공 시 처리
          Future.delayed(Duration.zero, () {
            widget.updateHome();
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        } catch (error) {
          // 업로드 실패 시 처리
          print('업로드 에러: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드에 실패했습니다.')),
          );
        }
      } else {
        // 파일이 선택되지 않았을 때의 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 또는 썸네일이 선택되지 않았습니다.')),
        );
      }
    }
  }

  Future<void> _generateThumbnail(String videoPath) async {
    await _videoController!.initialize();
    Duration? videoPosition = await _videoController!.position;
    final int thumbnailTime = videoPosition?.inMilliseconds ?? 0;

    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 150,
      quality: 75,
      timeMs: thumbnailTime,
    );

    setState(() {
      if (thumbnailPath != null) {
        _thumbnailImage = Image.file(File(thumbnailPath));
        _thumbnailPath = thumbnailPath;
      }
    });
  }

  Future<void> _pickThumbnailImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _thumbnailPath = imageFile.path;
        _thumbnailImage = Image.file(File(imageFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('업로드'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '영상 제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '영상 제목을 입력해주세요',
                      labelText: '영상 제목',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '동영상 업로드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: _videoController != null &&
                        _videoController!.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                        : Icon(
                      Icons.cloud_upload,
                      size: 80,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '썸네일 업로드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // 썸네일 이미지 선택 로직 추가
                    _pickThumbnailImage();
                  },
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
                        ? _thumbnailImage
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
              SizedBox(height: 10),
              Center(
                child: Text(
                  "터치하여 썸네일 이미지를 바꿔보세요",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // 업로드 로직 추가
                    await uploadVideoAndThumbnail(); // 업로드 함수 호출
                    Navigator.of(context).pop(); // 업로드 페이지 닫기

                    // 데이터를 홈 페이지로 전달하면서 홈 페이지로 이동
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(
                        videoTitle: _titleController.text,
                        thumbnailPath: _thumbnailPath ?? "",
                      ),
                    ));
                  },
                  child: Text('업로드하기'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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