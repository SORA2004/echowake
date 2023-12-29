import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audio_model.g.dart';

@JsonSerializable()
class AudioModel {
  final int? id;
  final String uid;
  final String title;
  final String videoUrl;
  final String videoThumbnailUrl;
  final String? profileURl;  // 타입을 String?로 변경
  final int? likeCount;
  final int? viewCount;
  final int? downloadCount;

  AudioModel({
    this.id,
    required this.uid,
    required this.title,
    required this.videoUrl,
    required this.videoThumbnailUrl,
    this.profileURl, // 필수가 아닌 선택적인 필드로 변경
    this.likeCount,
    this.viewCount,
    this.downloadCount,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) =>
      _$AudioModelFromJson(json);
  Map<String, dynamic> toJson() => _$AudioModelToJson(this);

  factory AudioModel.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return AudioModel(
      id: data['id'] as int?,
      uid: data['uid'] as String,
      title: data['title'] as String,
      videoUrl: data['videoUrl'] as String,
      videoThumbnailUrl: data['videoThumbnailUrl'] as String,
      profileURl: data['profileUrl'] as String?, // 선택적 필드로 처리
      likeCount: data['likeCount'] as int?,
      viewCount: data['viewCount'] as int?,
      downloadCount: data['downloadCount'] as int?,
    );
  }
}