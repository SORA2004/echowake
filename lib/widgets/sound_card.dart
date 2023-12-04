import 'package:echowake/models/audio_file.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 패키지 추가

class SoundCard extends StatelessWidget {
  final Sound sound;
  final FirebaseAuth auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스 생성

  SoundCard({required this.sound});

  // _toggleLike 함수 정의
  void _toggleLike(Sound sound) {
    // 좋아요 기능 로직
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(sound.uploaderProfileImageUrl),
            ),
            title: Text(sound.uploaderName),
            subtitle: Text(sound.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    sound.likedBy.contains(auth.currentUser?.uid) // widget 제거
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  onPressed: () => _toggleLike(sound), // widget 제거
                ),
                Text('${sound.likes}'), // widget 제거
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(sound.title, style: Theme.of(context).textTheme.headline6),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  // 소리 재생 로직을 여기에 추가하세요.
                },
              ),
              IconButton(
                icon: Icon(sound.isLiked ? Icons.favorite : Icons.favorite_border),
                color: sound.isLiked ? Colors.red : null,
                onPressed: () {
                  // 좋아요 로직을 여기에 추가하세요.
                },
              ),
              Text('${sound.likes}'),
              IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  // 신고 로직을 여기에 추가하세요.
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}