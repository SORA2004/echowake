import 'package:flutter/foundation.dart';
import 'package:echowake/models/audio_file.dart';
import 'package:flutter/material.dart';

class AudioFilesProvider with ChangeNotifier {
  List<AudioFile> _audioFiles = [];

  List<AudioFile> get audioFiles => _audioFiles;

  void addAudioFile(AudioFile audioFile) {
    _audioFiles.add(audioFile);
    notifyListeners();
  }
}
