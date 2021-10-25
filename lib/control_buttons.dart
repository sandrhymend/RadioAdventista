// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class ControlButtons extends StatefulWidget {
  AudioPlayer player;

  // ignore: use_key_in_widget_constructors
  ControlButtons(this.player);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            // showSliderDialog(
            //   context: context,
            //   title: "Adjust volume",
            //   divisions: 10,
            //   min: 0.0,
            //   max: 1.0,
            //   stream: widget.player.volumeStream,
            //   onChanged: widget.player.setVolume,
            // );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: widget.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              //print('=== IS NOT PLAYING ===');
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: widget.player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              //print('=== IS PLAYING ===');
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: widget.player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => widget.player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: widget.player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              // showSliderDialog(
              //   context: context,
              //   title: "Adjust speed",
              //   divisions: 10,
              //   min: 0.5,
              //   max: 1.5,
              //   stream: widget.player.speedStream,
              //   onChanged: widget.player.setSpeed,
              // );
            },
          ),
        ),
      ],
    );
  }
}

