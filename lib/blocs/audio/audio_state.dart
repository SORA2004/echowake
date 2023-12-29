part of 'audio_bloc.dart';

sealed class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object> get props => [];
}

final class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final List<AudioModel> posts;

  const AudioLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

class AudioError extends AudioState {
  final String message;

  const AudioError({required this.message});

  @override
  List<Object> get props => [message];
}