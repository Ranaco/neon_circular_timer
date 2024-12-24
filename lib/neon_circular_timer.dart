library neon_circular_timer;

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'neon_circular_painter.dart';

/// Create a Circular Countdown Timer.
class NeonCircularTimer extends StatefulWidget {
  /// the degree of neon effect
  final double neon;

  /// Key for Countdown Timer.
  final Key? key;

  /// Filling Color for Countdown Widget.
  final Color innerFillColor;

  /// Filling Gradient for Countdown Widget.
  final Gradient? innerFillGradient;

  /// Filling Color for Countdown circle.
  final Color? backgroundColor;

  /// Ring Color for Countdown Widget.
  final Color? neonColor;

  /// Ring Gradient for Countdown Widget.
  final Gradient? neonGradient;

  /// Background Color for Countdown Widget.
  final Color? outerStrokeColor;

  /// Background Gradient for Countdown Widget.
  final Gradient? outerStrokeGradient;

  /// This Callback will execute when the Countdown Ends.
  final VoidCallback? onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback? onStart;

  /// Countdown duration in Seconds.
  final int? duration;

  /// Countdown initial elapsed Duration in Seconds.
  final int initialDuration;

  /// Width of the Countdown Widget.
  final double width;

  /// Border Thickness of the Countdown Ring.
  final double strokeWidth;

  ///show neumorphicEffect true by default
  final bool neumorphicEffect;

  /// Begin and end contours with a flat edge and no extension.
  final StrokeCap strokeCap;

  /// Text Style for Countdown Text.
  final TextStyle? textStyle;

  /// To show duration
  final bool showDuration;

  /// On duration selected
  final Function(int) onDurationSelected;

  /// Format for the Countdown Text.
  final TextFormat? textFormat;

  /// Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
  final bool isReverse;

  /// Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
  final bool isReverseAnimation;

  /// Handles visibility of the Countdown Text.
  final bool isTimerTextShown;

  /// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
  final CountDownController? controller;

  /// Handles the timer start.
  final bool autoStart;

  NeonCircularTimer(
      {required this.width,
      this.duration,
      required this.controller,
      required this.onDurationSelected,
      this.innerFillColor = Colors.black12,
      this.outerStrokeColor = Colors.white,
      this.backgroundColor = Colors.white54,
      this.neonColor = Colors.white54,
      this.neon = 4,
      this.innerFillGradient,
      this.neonGradient,
      this.outerStrokeGradient,
      this.initialDuration = 0,
      this.isReverse = false,
      this.isReverseAnimation = false,
      this.onComplete,
      this.onStart,
      this.strokeWidth = 10.0,
      this.strokeCap = StrokeCap.round,
      this.textStyle,
      this.key,
      this.isTimerTextShown = true,
      this.autoStart = true,
      this.showDuration = true,
      this.textFormat = TextFormat.MM_SS,
      this.neumorphicEffect = true})
      : super(key: key);

  @override
  NeonCircularTimerState createState() => NeonCircularTimerState();
}

class NeonCircularTimerState extends State<NeonCircularTimer>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _countDownAnimation;
  int duration = 0;

  String get time {
    if (widget.isReverse && _controller!.isDismissed) {
      if (widget.textFormat == TextFormat.MM_SS) {
        return "00:00";
      } else if (widget.textFormat == TextFormat.SS) {
        return "00";
      } else if (widget.textFormat == TextFormat.S) {
        return "0";
      } else {
        return "00:00:00";
      }
    } else {
      Duration duration = _controller!.duration! * _controller!.value;
      return _getTime(duration);
    }
  }

  int get currentTime =>
      (_controller!.duration! * _controller!.value).inSeconds;

  void _setAnimation() {
    if (widget.autoStart) {
      if (widget.isReverse) {
        _controller!.reverse(from: 1);
      } else {
        _controller!.forward();
      }
    }
  }

  void _setAnimationDirection() {
    if ((!widget.isReverse && widget.isReverseAnimation) ||
        (widget.isReverse && !widget.isReverseAnimation)) {
      _countDownAnimation =
          Tween<double>(begin: 1, end: 0).animate(_controller!);
    }
  }

  void _setController() {
    widget.controller?._state = this;
    widget.controller?._isReverse = widget.isReverse;
    widget.controller?._initialDuration = widget.initialDuration;
    widget.controller?._duration = duration;

    if (widget.initialDuration > 0 && widget.autoStart) {
      if (widget.isReverse) {
        _controller?.value = 1 - (widget.initialDuration / duration);
      } else {
        _controller?.value = (widget.initialDuration / duration);
      }

      widget.controller?.start();
    }
  }

  String _getTime(Duration duration) {
    // For HH:mm:ss format
    if (widget.textFormat == TextFormat.HH_MM_SS) {
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    // For mm:ss format
    else if (widget.textFormat == TextFormat.MM_SS) {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    // For ss format
    else if (widget.textFormat == TextFormat.SS) {
      return '${(duration.inSeconds).toString().padLeft(2, '0')}';
    }
    // For s format
    else if (widget.textFormat == TextFormat.S) {
      return '${(duration.inSeconds)}';
    } else {
      // Default format
      return _defaultFormat(duration);
    }
  }

  _defaultFormat(Duration duration) {
    if (duration.inHours != 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else if (duration.inMinutes != 0) {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inSeconds % 60}';
    }
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  void _selectDuration() async {
    Duration? selDuration = await showDurationPicker(
        context: context, initialTime: Duration(seconds: 0));

    if (selDuration != null) {
      widget.onDurationSelected(selDuration.inSeconds);
      setState(() {
        duration = selDuration.inSeconds;
        _controller!.duration = Duration(seconds: duration);
      });
    }
  }

  Widget _playPauseButton() {
    return IconButton(
      icon: Icon(_controller!.isAnimating ? Icons.pause : Icons.play_arrow),
      onPressed: () {
        if (_controller!.isAnimating) {
          _controller!.stop();
          setState(() {});
        } else {
          _selectDuration();
          if (widget.isReverse) {
            _controller!.reverse(from: _controller!.value);
          } else {
            _controller!.forward(from: _controller!.value);
          }
          setState(() {});
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    duration = widget.duration ?? 0;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    );

    _controller!.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _onStart();
          break;

        case AnimationStatus.reverse:
          _onStart();
          break;

        case AnimationStatus.dismissed:
          _onComplete();
          break;
        case AnimationStatus.completed:

          /// [AnimationController]'s value is manually set to [1.0] that's why [AnimationStatus.completed] is invoked here this animation is [isReverse]
          /// Only call the [_onComplete] block when the animation is not reversed.
          if (!widget.isReverse) _onComplete();
          break;
        default:
        // Do nothing
      }
    });

    _setAnimation();
    _setAnimationDirection();
    _setController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.width,
        height: widget.width,
        child: AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return Align(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CustomTimerPainter(
                              neumorphicEffect: widget.neumorphicEffect,
                              backgroundColor: widget.backgroundColor,
                              animation: _countDownAnimation ?? _controller,
                              innerFillColor: widget.innerFillColor,
                              innerFillGradient: widget.innerFillGradient,
                              neonColor: widget.neonColor,
                              neonGradient: widget.neonGradient,
                              strokeWidth: widget.strokeWidth,
                              strokeCap: widget.strokeCap,
                              outerStrokeColor: widget.outerStrokeColor,
                              outerStrokeGradient: widget.outerStrokeGradient,
                              neon: widget.neon),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.isTimerTextShown
                                ? AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    decoration: BoxDecoration(
                                      color: (_controller!.duration! *
                                                      _controller!.value)
                                                  .inSeconds <
                                              30
                                          ? Colors.red
                                          : Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      time,
                                      style: widget.textStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .displaySmall,
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 20,
                            ),
                            widget.showDuration && duration > 0
                                ? Text(
                                    'Total: ${Duration(seconds: duration).inMinutes.toString().padLeft(2, '0')}:${(Duration(seconds: duration).inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: widget.textStyle ??
                                        Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                  )
                                : Container(),
                            SizedBox(
                              height: 30,
                            ),
                            _playPauseButton()
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  @override
  void dispose() {
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }
}

/// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
class CountDownController {
  late NeonCircularTimerState _state;
  late bool _isReverse;
  int? _initialDuration, _duration;

  /// This Method Starts the Countdown Timer
  void start() {
    if (_isReverse) {
      _state._controller?.reverse(
          from:
              _initialDuration == 0 ? 1 : 1 - (_initialDuration! / _duration!));
    } else {
      _state._controller?.forward(
          from: _initialDuration == 0 ? 0 : (_initialDuration! / _duration!));
    }
  }

  bool get isRunning => _state._controller!.isAnimating;

  /// This Method Pauses the Countdown Timer
  void pause() {
    _state._controller?.stop(canceled: false);
  }

  /// This Method Resumes the Countdown Timer
  void resume() {
    if (_isReverse) {
      _state._controller?.reverse(from: _state._controller!.value);
    } else {
      _state._controller?.forward(from: _state._controller!.value);
    }
  }

  /// This Method Restarts the Countdown Timer,
  /// Here optional int parameter **duration** is the updated duration for countdown timer
  void restart({int? duration}) {
    _state._controller!.duration =
        Duration(seconds: duration ?? _state._controller!.duration!.inSeconds);
    if (_isReverse) {
      _state._controller?.reverse(from: 1);
    } else {
      _state._controller?.forward(from: 0);
    }
  }

  /// This Method returns the **Current Time** of Countdown Timer
  /// Formated into the selected [TextFormat]
  String getTime() {
    return _state
        ._getTime(_state._controller!.duration! * _state._controller!.value);
  }

  /// This Method returns the **Current Time** of Countdown Timer
  /// in seconds
  int getTimeInSeconds() {
    return _state.currentTime;
  }
}

enum TextFormat { HH_MM_SS, MM_SS, SS, S }
