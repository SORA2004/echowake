import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final int? id;
  final String uid;
  final String title;
  final String videoUrl;
  final String videoThumbnailUrl;
  final int? likeCount;
  final int? viewCount;
  final int? downloadCount;

  VideoModel({
    this.id,
    required this.uid,
    required this.title,
    required this.videoUrl,
    required this.videoThumbnailUrl,
    this.likeCount,
    this.viewCount,
    this.downloadCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  factory VideoModel.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return VideoModel(
      id: data['id'] as int?,
      uid: data['uid'] as String,
      title: data['title'] as String,
      videoUrl: data['videoUrl'] as String,
      videoThumbnailUrl: data['videoThumbnailUrl'] as String,
      likeCount: data['likeCount'] as int?,
      viewCount: data['viewCount'] as int?,
      downloadCount: data['downloadCount'] as int?,
    );
  }
}