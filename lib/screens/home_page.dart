import 'package:echowake/screens/search_page.dart';
import 'package:echowake/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final String videoTitle;
  final String thumbnailPath;

  HomePage({required this.videoTitle, required this.thumbnailPath});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network('YOUR_VIDEO_URL_HERE')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          width: 120.0,
          height: 120.0,
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 60.0,
            backgroundImage: NetworkImage(widget.thumbnailPath),
          ),
        ),
        title: Text('환영합니다, ${widget.videoTitle}님!', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(), // 검색 페이지로 이동
              ));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // 썸네일 클릭 시 영상 재생
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoUrl: '업로드된 비디오의 URL'),
                ));
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.thumbnailPath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.videoTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


