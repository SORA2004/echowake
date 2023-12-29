import 'package:firebase_auth/firebase_auth.dart';

class Sound {
  String id;
  String title;
  String profileName;
  int likes;
  List<String> likedBy;
  String audioUrl;
  String profileImageUrl;
  String category; // 새로운 필드
  List<String> tags; // 새로운 필드
  String uploaderProfileImageUrl; // 필드 추가
  String uploaderName;

  Sound({
    required this.id,
    required this.title,
    required this.profileName,
    required this.likes,
    required this.likedBy,
    required this.audioUrl,
    required this.profileImageUrl,
    required this.category, // 초기화
    required this.tags, // 초기화
    required this.uploaderProfileImageUrl, // 필드 추가
    required this.uploaderName,
  });

  bool get isLiked => likedBy.contains(FirebaseAuth.instance.currentUser?.uid);
}

class AudioFile {
  final String title;
  final String profileName;
  final int likes;
  final bool isLiked;
  final String audioUrl;
  final String profileImageUrl;
  final String uploadTime;
  final String recordTime;

  AudioFile({
    required this.title,
    required this.profileName,
    required this.likes,
    required this.isLiked,
    required this.audioUrl,
    required this.profileImageUrl,
    required this.uploadTime,
    required this.recordTime,
  });
}