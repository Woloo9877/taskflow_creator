import 'dart:async';
import 'package:flutter/foundation.dart';

enum PomodoroPhase { focus, breakTime }

class PomodoroEngine {
  static const int focusDurationSeconds = 25 * 60;
  static const int breakDurationSeconds = 5 * 60;

  final _secondsController = StreamController<int>.broadcast();
  final _phaseController = StreamController<PomodoroPhase>.broadcast();

  final VoidCallback? onFocusComplete;

  Timer? _timer;
  int _remainingSeconds = focusDurationSeconds;
  PomodoroPhase _phase = PomodoroPhase.focus;
  bool _isRunning = false;

  PomodoroEngine({this.onFocusComplete});

  Stream<int> get secondsStream => _secondsController.stream;
  Stream<PomodoroPhase> get phaseStream => _phaseController.stream;

  int get remainingSeconds => _remainingSeconds;
  PomodoroPhase get phase => _phase;
  bool get isRunning => _isRunning;

  void start() {
    _timer?.cancel();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _phase = PomodoroPhase.focus;
    _remainingSeconds = focusDurationSeconds;
    _secondsController.add(_remainingSeconds);
    _phaseController.add(_phase);
  }

  void _tick() {
    if (_remainingSeconds <= 1) {
      _completeCurrentPhase();
      return;
    }
    _remainingSeconds--;
    _secondsController.add(_remainingSeconds);
  }

  void _completeCurrentPhase() {
    _timer?.cancel();
    _isRunning = false;

    if (_phase == PomodoroPhase.focus) {
      onFocusComplete?.call();
      _phase = PomodoroPhase.breakTime;
      _remainingSeconds = breakDurationSeconds;
    } else {
      _phase = PomodoroPhase.focus;
      _remainingSeconds = focusDurationSeconds;
    }

    _secondsController.add(_remainingSeconds);
    _phaseController.add(_phase);
  }

  void dispose() {
    _timer?.cancel();
    _secondsController.close();
    _phaseController.close();
  }
}