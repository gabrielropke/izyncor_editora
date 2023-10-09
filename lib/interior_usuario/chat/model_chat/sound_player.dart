import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'sound_recorder.dart';

class SoundPlayer {
  FlutterSoundPlayer? _audioPlayer;

  bool get isPlaying => _audioPlayer!.isPlaying;  

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();

    await _audioPlayer!.openAudioSession();
  }

  void dispose() {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play(VoidCallback whenfinished) async {
    await _audioPlayer!.startPlayer(
      fromURI: pathToSaveAudio,
      codec: Codec.mp3,
      whenFinished: whenfinished,
    );
  }

  Future _stop() async {
    await _audioPlayer!.stopPlayer(
    );
  }

  Future togglePlaying({required VoidCallback whenfinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenfinished);
    } else {
      await _stop();
    }
  }
}
