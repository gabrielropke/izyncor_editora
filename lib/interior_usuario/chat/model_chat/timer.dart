import 'dart:async';

import 'package:flutter/material.dart';

class TimerController extends ValueNotifier<bool> {
  TimerController({bool isPlaying = false}) : super(isPlaying);

  void startTimer() => value = true;

  void stopTimer() => value = false;

}

class TimerWidget extends StatefulWidget {
  final TimerController controller;
  const TimerWidget({super.key, required this.controller});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {

  Duration duration = Duration();

  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.addListener(() { 
      if (widget.controller.value) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  void reset() => setState(() => duration = Duration());

  void addTime(){
    final addSecond = 1;

    setState(() {
      final seconds = duration.inSeconds + addSecond;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) {
      reset();
    }

    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) {
      reset();
    }

    setState(() => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) => Center(child: Container());
  }