import 'package:editora_izyncor_app/interior_usuario/chat/model_chat/sound_player.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/model_chat/sound_recorder.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/model_chat/timer.dart';
import 'package:flutter/material.dart';

class gravar extends StatefulWidget {
  const gravar({super.key});

  @override
  State<gravar> createState() => _gravarState();
}

class _gravarState extends State<gravar> {
  final timercontroller = TimerController();
  final recorder = SoundRecorder();
  final player = SoundPlayer();

  Widget buildStart() {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? 'Stop' : 'Start';
    final primary = isRecording ? Colors.red : Colors.white;
    final onPrimary = isRecording ? Colors.white : Colors.black;

    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: primary,
          onPrimary: onPrimary,
        ),
        onPressed: () async {
          await recorder.toogleRecording();
          final isRecording = recorder.isRecording;
          setState(() {});

          if (isRecording) {
            timercontroller.startTimer();
          } else {
            timercontroller.startTimer();
          }
        },
        icon: Icon(icon),
        label: Text(text));
  }

  Widget buildPlay() {
    final isPlaying = player.isPlaying;
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    final text = isPlaying ? 'Stop Playing' : 'Play recording';
    final primary = isPlaying ? Colors.red : Colors.white;
    final onPrimary = isPlaying ? Colors.white : Colors.black;

    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: primary,
          onPrimary: onPrimary,
        ),
        onPressed: () async {
          await player.togglePlaying(whenfinished: () => setState(() {})); setState(() {
            
          });
        },
        icon: Icon(icon),
        label: Text(text));
  }

  Widget buildPlayer() {
    final text = recorder.isRecording ? 'Now recording' : 'Press for recording';
    // final animate = recorder.isRecording;

    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.blue,
      child: Stack(
        children: [
          const Icon(
            Icons.mic,
            size: 32,
          ),
          TimerWidget(controller: timercontroller),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recorder.init();
    player.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildPlayer(),
            SizedBox(height: 15),
            buildStart(),
            SizedBox(height: 15),
            buildPlay()
          ],
        ),
      ),
    );
  }
}
