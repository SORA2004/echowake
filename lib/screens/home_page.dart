import 'package:echowake/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:echowake/screens/video_player_screen.dart';

class HomePage extends StatefulWidget {
  final String videoTitle;
  final String thumbnailPath;

  HomePage({required this.videoTitle, required this.thumbnailPath});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 여기에서 VideoPlayerController 선언 및 초기화 필요 (만약 비디오를 재생할 경우)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/AppIcon-1024x+(7).png'), // 앱 아이콘 추가
        ),
        title: Text(
          'Blissom', // 앱 이름 추가
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true, // 제목을 중앙에 배치
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
      body: Padding(
        padding: EdgeInsets.all(12),  // 여백 추가
        child: ListView(
          children: <Widget>[
            // 업로드된 썸네일과 제목이 있는 카드
            GestureDetector(
              onTap: () {
                // 썸네일 클릭 시 동작, 예: 비디오 재생 페이지로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoUrl: '업로드된 비디오의 URL'),
                ));
              },
              child: Card(
                clipBehavior: Clip.antiAlias,  // 카드 모서리 둥글게 처리
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.network(
                      widget.thumbnailPath,
                      fit: BoxFit.cover,
                      height: 200,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Text('이미지를 불러올 수 없습니다.');
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),  // 썸네일 아래 텍스트 패딩
                      child: Text(
                        widget.videoTitle,  // 비디오 제목
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 추가적인 콘텐츠 (필요하다면 여기에 추가)
          ],
        ),
      ),
    );
  }
}
