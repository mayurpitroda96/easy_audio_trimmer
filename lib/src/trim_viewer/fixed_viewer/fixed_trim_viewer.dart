import 'dart:developer';
import 'dart:io';

import 'package:easy_audio_trimmer/src/trim_viewer/trim_area_properties.dart';
import 'package:easy_audio_trimmer/src/trim_viewer/trim_editor_properties.dart';
import 'package:easy_audio_trimmer/src/trimmer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../utils/duration_style.dart';
import '../../utils/editor_drag_type.dart';

import '../trim_editor_painter.dart';
import 'fixed_bar_viewer.dart';

class FixedTrimViewer extends StatefulWidget {
  /// The Trimmer instance controlling the data.
  final Trimmer trimmer;

  /// For defining the total trimmer area width
  final double viewerWidth;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For defining the maximum length of the output audio.
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

  /// Properties for customizing the trim editor.
  final TrimEditorProperties editorProperties;

  /// Properties for customizing the fixed trim area.
  final FixedTrimAreaProperties areaProperties;

  /// Widget for displaying the audio trimmer.
  ///
  /// This has frame wise preview of the audio with a
  /// slider for selecting the part of the audio to be
  /// trimmed.
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
  /// * [maxAudioLength] for specifying the maximum length of the
  /// output audio.
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
  /// * [areaProperties] defines properties for customizing the fixed trim area.
  ///
  ///
  ///
  ///
  final Color? barColor;
  final Color? backgroundColor;

  final bool allowAudioSelection;

  const FixedTrimViewer(
      {super.key,
      required this.trimmer,
      this.viewerWidth = 50.0 * 8,
      this.viewerHeight = 50,
      this.maxAudioLength = const Duration(milliseconds: 0),
      this.showDuration = true,
      this.durationTextStyle = const TextStyle(color: Colors.white),
      this.durationStyle = DurationStyle.FORMAT_HH_MM_SS,
      this.onChangeStart,
      this.onChangeEnd,
      this.onChangePlaybackState,
      this.editorProperties = const TrimEditorProperties(),
      this.areaProperties = const FixedTrimAreaProperties(),
      this.barColor,
      this.backgroundColor,
      required this.allowAudioSelection});

  @override
  State<FixedTrimViewer> createState() => _FixedTrimViewerState();
}

class _FixedTrimViewerState extends State<FixedTrimViewer>
    with TickerProviderStateMixin {
  final _trimmerAreaKey = GlobalKey();
  File? get _audioFile => widget.trimmer.currentAudioFile;

  double _audioStartPos = 0.0;
  double _audioEndPos = 0.0;

  Offset _startPos = const Offset(0, 0);
  Offset _endPos = const Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _audioDuration = 0;
  int _currentPosition = 0;

  double _barViewerW = 0.0;
  double _barViewerH = 0.0;

  int _numberOfBars = 0;

  late double _startCircleSize;
  late double _endCircleSize;
  late double _borderRadius;

  double? fraction;
  double? maxLengthPixels;

  FixedBarViewer? barWidget;

  Animation<double>? _scrubberAnimation;
  AnimationController? _animationController;
  late Tween<double> _linearTween;

  /// Quick access to AudioPlayerController, only not null after [TrimmerEvent.initialized]
  /// has been emitted.
  AudioPlayer get audioPlayerController => widget.trimmer.audioPlayer!;

  /// Keep track of the drag type, e.g. whether the user drags the left, center or
  /// right part of the frame. Set this in [_onDragStart] when the dragging starts.
  EditorDragType _dragType = EditorDragType.left;

  /// Whether the dragging is allowed. Dragging is ignore if the user's gesture is outside
  /// of the frame, to make the UI more realistic.
  bool _allowDrag = true;

  bool _isAnimationControllerDispose = false;

  @override
  void initState() {
    super.initState();
    _startCircleSize = widget.editorProperties.circleSize;
    _endCircleSize = widget.editorProperties.circleSize;
    _borderRadius = widget.editorProperties.borderRadius;
    _barViewerH = widget.viewerHeight;
    log('barViewerW: $_barViewerW');
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final renderBox =
          _trimmerAreaKey.currentContext?.findRenderObject() as RenderBox?;
      final trimmerActualWidth = renderBox?.size.width;
      log('RENDER BOX: $trimmerActualWidth');
      if (trimmerActualWidth == null) return;
      _barViewerW = trimmerActualWidth;
      _initializeAudioController();
      audioPlayerController.seek(const Duration(milliseconds: 0));
      _numberOfBars = trimmerActualWidth ~/ _barViewerH;
      log('numberOfBars: $_numberOfBars');
      log('barViewerW: $_barViewerW');
      Duration? totalDuration = await audioPlayerController.getDuration();

      setState(() {
        _barViewerW = _numberOfBars * _barViewerH;

        final FixedBarViewer barWidget = FixedBarViewer(
          audioFile: _audioFile!,
          audioDuration: _audioDuration,
          fit: widget.areaProperties.barFit,
          barHeight: _barViewerH,
          barWeight: _barViewerW,
          backgroundColor: widget.backgroundColor,
          barColor: widget.barColor,
        );
        this.barWidget = barWidget;

        if (totalDuration == null) {
          return;
        }

        if (widget.maxAudioLength > const Duration(milliseconds: 0) &&
            widget.maxAudioLength < totalDuration) {
          if (widget.maxAudioLength < totalDuration) {
            fraction = widget.maxAudioLength.inMilliseconds /
                totalDuration.inMilliseconds;

            maxLengthPixels = _barViewerW * fraction!;
          }
        } else {
          maxLengthPixels = _barViewerW;
        }

        _audioEndPos = fraction != null
            ? _audioDuration.toDouble() * fraction!
            : _audioDuration.toDouble();

        widget.onChangeEnd!(_audioEndPos);

        _endPos = Offset(
          maxLengthPixels != null ? maxLengthPixels! : _barViewerW,
          _barViewerH,
        );

        // Defining the tween points
        _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);
        _animationController = AnimationController(
          vsync: this,
          duration:
              Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt()),
        );

        _scrubberAnimation = _linearTween.animate(_animationController!)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController!.stop();
            }
          });
      });
    });
  }

  Future<void> _initializeAudioController() async {
    if (_audioFile != null) {
      audioPlayerController.onPlayerStateChanged.listen((event) {
        final bool isPlaying = event == PlayerState.playing;

        if (!isPlaying) {
          if (_animationController != null) {
            if ((_scrubberAnimation?.value ?? 0).toInt() ==
                (_endPos.dx).toInt()) {
              _animationController!.reset();
            }
            if (!_isAnimationControllerDispose) {
              _animationController?.stop();
            }

            widget.onChangePlaybackState!(false);
          }
        } else {
          widget.onChangePlaybackState!(true);
        }
      });

      audioPlayerController.onPositionChanged.listen((event) async {
        final bool isPlaying =
            audioPlayerController.state == PlayerState.playing;

        if (isPlaying) {
          setState(() {
            _currentPosition = event.inMilliseconds;

            if (_currentPosition > _audioEndPos.toInt()) {
              audioPlayerController.pause();
              widget.onChangePlaybackState!(false);

              if (!_isAnimationControllerDispose) {
                _animationController?.stop();
              }
            } else {
              if (!_animationController!.isAnimating) {
                widget.onChangePlaybackState!(true);
                _animationController!.forward();
              }
            }
          });
        }
      });
      // audioPlayerController.addListener(() async {

      // });

      audioPlayerController.setVolume(1.0);
      _audioDuration =
          (await audioPlayerController.getDuration())!.inMilliseconds;
    }
  }

  /// Called when the user starts dragging the frame, on either side on the whole frame.
  /// Determine which [EditorDragType] is used.
  void _onDragStart(DragStartDetails details) {
    debugPrint("_onDragStart");
    debugPrint(details.localPosition.toString());
    debugPrint((_startPos.dx - details.localPosition.dx).abs().toString());
    debugPrint((_endPos.dx - details.localPosition.dx).abs().toString());

    final startDifference = _startPos.dx - details.localPosition.dx;
    final endDifference = _endPos.dx - details.localPosition.dx;

    // First we determine whether the dragging motion should be allowed. The allowed
    // zone is widget.sideTapSize (left) + frame (center) + widget.sideTapSize (right)
    if (startDifference <= widget.editorProperties.sideTapSize &&
        endDifference >= -widget.editorProperties.sideTapSize) {
      _allowDrag = true;
    } else {
      debugPrint("Dragging is outside of frame, ignoring gesture...");
      _allowDrag = false;
      return;
    }

    // Now we determine which part is dragged
    if (details.localPosition.dx <=
        _startPos.dx + widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.left;
    } else if (details.localPosition.dx <=
        _endPos.dx - widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.center;
    } else {
      _dragType = EditorDragType.right;
    }
  }

  /// Called during dragging, only executed if [_allowDrag] was set to true in
  /// [_onDragStart].
  /// Makes sure the limits are respected.
  void _onDragUpdate(DragUpdateDetails details) {
    if (!_allowDrag) return;

    if (_dragType == EditorDragType.left) {
      if (!widget.allowAudioSelection) return;
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_startPos.dx + details.delta.dx <= _endPos.dx) &&
          !(_endPos.dx - _startPos.dx - details.delta.dx > maxLengthPixels!)) {
        _startPos += details.delta;
        _onStartDragged();
      }
    } else if (_dragType == EditorDragType.center) {
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_endPos.dx + details.delta.dx <= _barViewerW)) {
        _startPos += details.delta;
        _endPos += details.delta;
        _onStartDragged();
        _onEndDragged();
      }
    } else {
      if (!widget.allowAudioSelection) return;
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_endPos.dx + details.delta.dx <= _barViewerW) &&
          (_endPos.dx + details.delta.dx >= _startPos.dx) &&
          !(_endPos.dx - _startPos.dx + details.delta.dx > maxLengthPixels!)) {
        _endPos += details.delta;
        _onEndDragged();
      }
    }
    setState(() {});
  }

  void _onStartDragged() {
    _startFraction = (_startPos.dx / _barViewerW);
    _audioStartPos = _audioDuration * _startFraction;
    widget.onChangeStart!(_audioStartPos);
    _linearTween.begin = _startPos.dx;
    _animationController!.duration =
        Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt());
    _animationController!.reset();
  }

  void _onEndDragged() {
    _endFraction = _endPos.dx / _barViewerW;
    _audioEndPos = _audioDuration * _endFraction;
    widget.onChangeEnd!(_audioEndPos);
    _linearTween.end = _endPos.dx;
    _animationController!.duration =
        Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt());
    _animationController!.reset();
  }

  /// Drag gesture ended, update UI accordingly.
  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _startCircleSize = widget.editorProperties.circleSize;
      _endCircleSize = widget.editorProperties.circleSize;
      if (_dragType == EditorDragType.right) {
        audioPlayerController
            .seek(Duration(milliseconds: _audioEndPos.toInt()));
      } else {
        audioPlayerController
            .seek(Duration(milliseconds: _audioStartPos.toInt()));
      }
    });
  }

  @override
  void dispose() {
    audioPlayerController.pause();

    _isAnimationControllerDispose = true;
    widget.onChangePlaybackState!(false);
    if (_audioFile != null) {
      audioPlayerController.setVolume(0.0);
      audioPlayerController.dispose();
      widget.onChangePlaybackState!(false);
    }
    _animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.showDuration
              ? SizedBox(
                  width: _barViewerW,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          Duration(milliseconds: _audioStartPos.toInt())
                              .format(widget.durationStyle),
                          style: widget.durationTextStyle,
                        ),
                        audioPlayerController.state == PlayerState.playing
                            ? Text(
                                Duration(milliseconds: _currentPosition.toInt())
                                    .format(widget.durationStyle),
                                style: widget.durationTextStyle,
                              )
                            : Container(),
                        Text(
                          Duration(milliseconds: _audioEndPos.toInt())
                              .format(widget.durationStyle),
                          style: widget.durationTextStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          CustomPaint(
            foregroundPainter: TrimEditorPainter(
              startPos: _startPos,
              endPos: _endPos,
              scrubberAnimationDx: _scrubberAnimation?.value ?? 0,
              startCircleSize: _startCircleSize,
              endCircleSize: _endCircleSize,
              borderRadius: _borderRadius,
              borderWidth: widget.editorProperties.borderWidth,
              scrubberWidth: widget.editorProperties.scrubberWidth,
              circlePaintColor: widget.editorProperties.circlePaintColor,
              borderPaintColor: widget.editorProperties.borderPaintColor,
              scrubberPaintColor: widget.editorProperties.scrubberPaintColor,
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(widget.areaProperties.borderRadius),
              child: Container(
                key: _trimmerAreaKey,
                color: Colors.grey[900],
                height: _barViewerH,
                width: _barViewerW == 0.0 ? widget.viewerWidth : _barViewerW,
                child: barWidget ?? Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
