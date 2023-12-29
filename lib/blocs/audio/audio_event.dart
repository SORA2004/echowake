part of 'audio_bloc.dart';

sealed class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class FetchEvent extends AudioEvent {}