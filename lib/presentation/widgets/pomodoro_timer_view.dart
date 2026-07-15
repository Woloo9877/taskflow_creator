import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'pomodoro_engine.dart';

class PomodoroTimerView extends StatefulWidget {
  final VoidCallback onFocusComplete;

  const PomodoroTimerView({super.key, required this.onFocusComplete});

  @override
  State<PomodoroTimerView> createState() => _PomodoroTimerViewState();
}

class _PomodoroTimerViewState extends State<PomodoroTimerView> {
  late final PomodoroEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = PomodoroEngine(onFocusComplete: widget.onFocusComplete);
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<PomodoroPhase>(
      stream: _engine.phaseStream,
      initialData: _engine.phase,
      builder: (context, phaseSnapshot) {
        final phase = phaseSnapshot.data ?? PomodoroPhase.focus;
        final isFocus = phase == PomodoroPhase.focus;
        final phaseColor = isFocus ? AppColors.sunsetCopper : AppColors.sageGreen;

        return Column(
          children: [
            Text(
              isFocus ? 'FOCUS SESSION' : 'BREAK',
              style: theme.textTheme.bodySmall?.copyWith(
                color: phaseColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: _engine.secondsStream,
              initialData: _engine.remainingSeconds,
              builder: (context, secondsSnapshot) {
                final seconds = secondsSnapshot.data ?? _engine.remainingSeconds;
                return Text(
                  _formatTime(seconds),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: phaseColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _engine.reset()),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _engine.isRunning ? _engine.pause() : _engine.start();
                  }),
                  icon: Icon(_engine.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_engine.isRunning ? 'Pause' : 'Start'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}