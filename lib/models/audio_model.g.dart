// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioModel _$AudioModelFromJson(Map<String, dynamic> json) => AudioModel(
  id: json['id'] as int?,
  uid: json['uid'] as String,
  title: json['title'] as String,
  videoUrl: json['videoUrl'] as String,
  profileURl: json['profileUrl'] as String,
  videoThumbnailUrl: json['videoThumbnailUrl'] as String,
  likeCount: json['likeCount'] as int?,
  viewCount: json['viewCount'] as int?,
  downloadCount: json['downloadCount'] as int?,
);

Map<String, dynamic> _$AudioModelToJson(AudioModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'title': instance.title,
      'videoUrl': instance.videoUrl,
      'videoThumbnailUrl': instance.videoThumbnailUrl,
      'likeCount': instance.likeCount,
      'viewCount': instance.viewCount,
      'downloadCount': instance.downloadCount,
    };