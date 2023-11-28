import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'home_page.dart';
import 'main_screen.dart';

class UploadPage extends StatefulWidget {
  final Function updateHome;

  UploadPage({required this.updateHome});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  VideoPlayerController? _videoController;
  Image? _thumbnailImage;
  TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _thumbnailPath;
  String? _videoPath;

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
        _videoPath = videoFile.path;
        _videoController = VideoPlayerController.file(File(_videoPath!))
          ..initialize().then((_) {
            setState(() {});
            _generateThumbnail(_videoPath!);
          });
      });
    }
  }

  Future<void> _pickThumbnailImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _thumbnailPath = imageFile.path;
        _thumbnailImage = Image.file(File(_thumbnailPath!));
      });
    }
  }

  Future<void> _uploadAndNavigate() async {
    final uploadResult = await uploadVideoAndThumbnail();
    if (uploadResult['success']) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MainScreen(
          videoTitle: _titleController.text,
          thumbnailPath: uploadResult['thumbnailUrl'] ?? "",
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('업로드에 실패했습니다.'),
      ));
    }
  }

  Future<Map<String, dynamic>> uploadVideoAndThumbnail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null && _videoPath != null && _thumbnailPath != null) {
      final File videoFile = File(_videoPath!);
      final File thumbnailFile = File(_thumbnailPath!);
      final String userId = user.uid;

      try {
        // Firebase Storage에 동영상 파일 업로드
        final videoRef = firebase_storage.FirebaseStorage.instance
            .ref('videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4');
        await videoRef.putFile(videoFile);
        final String videoUrl = await videoRef.getDownloadURL();

        // Firebase Storage에 썸네일 이미지 파일 업로드
        final thumbnailRef = firebase_storage.FirebaseStorage.instance
            .ref('thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await thumbnailRef.putFile(thumbnailFile);
        final String thumbnailUrl = await thumbnailRef.getDownloadURL();

        // 업로드된 파일의 URL을 반환
        return {'success': true, 'videoUrl': videoUrl, 'thumbnailUrl': thumbnailUrl};
      } catch (error) {
        print('업로드 에러: $error');
        return {'success': false};
      }
    } else {
      // 필요한 정보가 없거나 사용자가 로그인하지 않은 경우
      return {'success': false};
    }
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
                  onPressed: _uploadAndNavigate,
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