import 'package:easy_audio_trimmer/src/trim_viewer/fixed_viewer/fixed_trim_viewer.dart';
import 'package:easy_audio_trimmer/src/trim_viewer/trim_area_properties.dart';
import 'package:easy_audio_trimmer/src/trimmer.dart';
import 'package:easy_audio_trimmer/src/utils/duration_style.dart';
import 'package:flutter/material.dart';

import 'trim_editor_properties.dart';

class TrimViewer extends StatefulWidget {
  /// The Trimmer instance controlling the data.
  final Trimmer trimmer;

  /// For defining the total trimmer area width
  final double viewerWidth;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For specifying the type of the trim viewer.
  /// You can choose among: `auto`, `fixed`, and `scrollable`.
  ///
  /// **NOTE:** While using `scrollable` if the total audio
  /// duration is less than maxAudioLength + padding, it
  /// will throw an error.
  ///

  /// For defining the maximum length of the output audio.
  ///
  /// **NOTE:** When explicitly setting the `type` to `scrollable`,
  /// specifying this property is mandatory.
  final Duration maxAudioLength;

  /// For showing the start and the end point of the
  /// audio on top of the trimmer area.
  ///
  /// By default it is set to `true`.
  final bool showDuration;

  /// For providing a `TextStyle` to the
  /// duration text.
  ///
  /// By default it is set to `TextStyle(color: Colors.white)`
  final TextStyle durationTextStyle;

  /// For specifying a style of the duration
  ///
  /// By default it is set to `DurationStyle.FORMAT_HH_MM_SS`.
  final DurationStyle durationStyle;

  /// Callback to the audio start position
  ///
  /// Returns the selected audio start position in `milliseconds`.
  final Function(double startValue)? onChangeStart;

  /// Callback to the audio end position.
  ///
  /// Returns the selected audio end position in `milliseconds`.
  final Function(double endValue)? onChangeEnd;

  /// Callback to the audio playback
  /// state to know whether it is currently playing or paused.
  ///
  /// Returns a `boolean` value. If `true`, audio is currently
  /// playing, otherwise paused.
  final Function(bool isPlaying)? onChangePlaybackState;

  /// This is the fraction of padding present beside the trimmer editor,
  /// calculated on the `maxAudioLength` value.
  final double paddingFraction;

  /// Properties for customizing the trim editor.
  final TrimEditorProperties editorProperties;

  /// Properties for customizing the trim area.
  final TrimAreaProperties areaProperties;

  /// Widget for displaying the audio trimmer.
  ///
  /// This has frame wise preview of the audio with a
  /// slider for selecting the part of the audio to be
  /// trimmed. It automatically selected whether to use
  /// `FixedTrimViewer` or `ScrollableTrimViewer`.
  ///
  /// If you want to use a specific kind of trim viewer, use
  /// the `type` property.
  ///
  /// The required parameters are [viewerWidth] & [viewerHeight]
  ///
  /// * [viewerWidth] to define the total trimmer area width.
  ///
  ///
  /// * [viewerHeight] to define the total trimmer area height.
  ///
  ///
  /// The optional parameters are:
  ///
  ///
  /// * [maxAudioLength] for specifying the maximum length of the
  /// output audio.
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
  /// * [showDuration] for showing the start and the end point of the
  /// audio on top of the trimmer area. By default it is set to `true`.
  ///
  ///
  /// * [durationTextStyle] is for providing a `TextStyle` to the
  /// duration text. By default it is set to
  /// `TextStyle(color: Colors.white)`
  ///
  ///
  /// * [onChangeStart] is a callback to the audio start position.
  ///
  ///
  /// * [onChangeEnd] is a callback to the audio end position.
  ///
  ///
  /// * [onChangePlaybackState] is a callback to the audio playback
  /// state to know whether it is currently playing or paused.
  ///
  ///
  /// * [editorProperties] defines properties for customizing the trim editor.
  ///
  ///
  /// * [areaProperties] defines properties for customizing the trim area.
  ///
  final Color? barColor;
  final Color? backgroundColor;

  final bool allowAudioSelection;

  const TrimViewer(
      {Key? key,
      required this.trimmer,
      this.maxAudioLength = const Duration(milliseconds: 0),
      this.viewerWidth = 50 * 8,
      this.viewerHeight = 50,
      this.showDuration = true,
      this.durationTextStyle = const TextStyle(color: Colors.white),
      this.durationStyle = DurationStyle.FORMAT_HH_MM_SS,
      this.onChangeStart,
      this.onChangeEnd,
      this.onChangePlaybackState,
      this.paddingFraction = 0.2,
      this.editorProperties = const TrimEditorProperties(),
      this.areaProperties = const TrimAreaProperties(),
      this.backgroundColor,
      this.allowAudioSelection = true,
      this.barColor})
      : super(key: key);

  @override
  State<TrimViewer> createState() => _TrimViewerState();
}

class _TrimViewerState extends State<TrimViewer> with TickerProviderStateMixin {
  bool? _isScrollableAllowed;

  @override
  void initState() {
    super.initState();
    widget.trimmer.eventStream.listen((event) async {
      if (event == TrimmerEvent.initialized) {
        final totalDuration = await widget.trimmer.audioPlayer!.getDuration();
        if (totalDuration == null) {
          return;
        }
        final maxAudioLength = widget.maxAudioLength;

        final paddingFraction = widget.paddingFraction;
        final trimAreaDuration = Duration(
            milliseconds: (maxAudioLength.inMilliseconds +
                ((paddingFraction * maxAudioLength.inMilliseconds) * 2)
                    .toInt()));

        final shouldScroll = trimAreaDuration <= totalDuration &&
            maxAudioLength.compareTo(const Duration(milliseconds: 0)) != 0;

        setState(() => _isScrollableAllowed = shouldScroll);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fixedTrimViewer = FixedTrimViewer(
      trimmer: widget.trimmer,
      maxAudioLength: widget.maxAudioLength,
      viewerWidth: widget.viewerWidth,
      viewerHeight: widget.viewerHeight,
      showDuration: widget.showDuration,
      durationTextStyle: widget.durationTextStyle,
      durationStyle: widget.durationStyle,
      onChangeStart: widget.onChangeStart,
      onChangeEnd: widget.onChangeEnd,
      onChangePlaybackState: widget.onChangePlaybackState,
      editorProperties: widget.editorProperties,
      backgroundColor: widget.backgroundColor,
      allowAudioSelection: widget.allowAudioSelection,
      barColor: widget.barColor,
      areaProperties: FixedTrimAreaProperties(
        borderRadius: widget.areaProperties.borderRadius,
      ),
    );

    return _isScrollableAllowed == null ? fixedTrimViewer : const SizedBox();
  }
}
