part of 'video_bloc.dart';

sealed class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object> get props => [];
}

final class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<VideoModel> posts;

  const VideoLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

class VideoError extends VideoState {
  final String message;

  const VideoError({required this.message});

  @override
  List<Object> get props => [message];
}