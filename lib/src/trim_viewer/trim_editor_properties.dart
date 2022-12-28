import 'package:flutter/material.dart';

class TrimEditorProperties {
  /// For specifying a size to the holder at the
  /// two ends of the audio trimmer area, while it is `idle`.
  ///
  /// By default it is set to `5.0`.
  final double circleSize;

  /// For specifying a size to the holder at
  /// the two ends of the audio trimmer area, while it is being
  /// `dragged`.
  ///
  /// By default it is set to `8.0`.
  final double circleSizeOnDrag;

  /// For specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  final double borderWidth;

  /// For specifying the width of the audio scrubber
  final double scrubberWidth;

  /// For specifying a circular border radius
  /// to the corners of the trim area.
  ///
  /// By default it is set to `4.0`.
  final double borderRadius;

  /// For specifying a color to the circle.
  ///
  /// By default it is set to `Colors.white`.
  final Color circlePaintColor;

  /// For specifying a color to the border of
  /// the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the audio
  /// scrubber inside the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color scrubberPaintColor;

  /// Determines the touch size of the side handles, left and right. The rest, in
  /// the center, will move the whole frame if [maxAudioLength] is inferior to the
  /// total duration of the audio.
  final int sideTapSize;

  /// Helps defining the Trim Editor properties.
  ///
  /// A better look at the structure of the **Trim Viewer**:
  ///
  ///
  /// All the parameters are optional:
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the audio trimmer area, while it is `idle`.
  /// By default it is set to `5.0`.
  ///
  ///
  /// * [circleSizeOnDrag] for specifying a size to the holder at
  /// the two ends of the audio trimmer area, while it is being
  /// `dragged`. By default it is set to `8.0`.
  ///
  ///
  /// * [borderWidth] for specifying the width of the border around
  /// the trim area. By default it is set to `3.0`.
  ///
  /// * [scrubberWidth] for specifying the width of the audio scrubber.
  /// By default it is set to `1.0`.
  ///
  ///
  /// * [borderRadius] for applying a circular border radius
  /// to the corners of the trim area. By default it is set to `4.0`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the audio
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  ///
  /// * [sideTapSize] determines the touch size of the side handles, left and right.
  /// The rest, in the center, will move the whole frame if [maxAudioLength] is
  /// inferior to the total duration of the audio.
  ///
  const TrimEditorProperties({
    this.circleSize = 5.0,
    this.circleSizeOnDrag = 8.0,
    this.borderWidth = 3.0,
    this.scrubberWidth = 1.0,
    this.borderRadius = 4.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.sideTapSize = 24,
  });
}
