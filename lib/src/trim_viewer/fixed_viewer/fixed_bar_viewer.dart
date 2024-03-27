import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class FixedBarViewer extends StatelessWidget {
  final File audioFile;
  final int audioDuration;
  final double barHeight;
  final double barWeight;
  final BoxFit fit;

  final Color? barColor;
  final Color? backgroundColor;

  /// For showing the bars generated from the audio,
  /// like a frame by frame preview
  const FixedBarViewer(
      {super.key,
      required this.audioFile,
      required this.audioDuration,
      required this.barHeight,
      required this.barWeight,
      required this.fit,
      this.backgroundColor,
      this.barColor});

  Stream<List<int?>> generateBars() async* {
    List<int> bars = [];
    Random r = Random();
    for (int i = 1; i <= barWeight / 5.0; i++) {
      int number = 1 + r.nextInt(barHeight.toInt() - 1);
      bars.add(r.nextInt(number));
      yield bars;
    }
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return StreamBuilder<List<int?>>(
      stream: generateBars(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<int?> bars = snapshot.data!;
          return Container(
            color: backgroundColor ?? Colors.white,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: bars.map((int? height) {
                // Color color = i >= barStartPosition / barWidth &&
                //         i <= barEndPosition / barWidth
                //     ? widget.wavActiveColor
                //     : widget.wavDeactiveColor;
                i++;
                return Container(
                  color: barColor ?? Colors.black,
                  height: height?.toDouble(),
                  width: 5.0,
                );
              }).toList(),
            ),
          );
        } else {
          return Container(
            color: Colors.grey[900],
            height: barHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}
