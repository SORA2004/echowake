import 'package:flutter/material.dart';

import '../../models/video_model.dart';
import '../../screens/video_player_screen.dart';

class HomeTile extends StatefulWidget {
  final VideoModel model;
  const HomeTile({Key? key, required this.model}) : super(key: key);

  @override
  State createState() => _HomeTileState();
}

class _HomeTileState extends State<HomeTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 썸네일 클릭 시 동작, 예: 비디오 재생 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                VideoPlayerScreen(videoUrl: widget.model.videoUrl),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias, // 카드 모서리 둥글게 처리
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
              widget.model.videoThumbnailUrl,
              fit: BoxFit.cover,
              height: 200,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Text('이미지를 불러올 수 없습니다.');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8), // 썸네일 아래 텍스트 패딩
              child: Text(
                widget.model.title, // 비디오 제목
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}