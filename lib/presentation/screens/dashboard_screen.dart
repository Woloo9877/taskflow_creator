import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/date_time_formatters.dart';
import '../../core/utils/input_validators.dart';
import '../../data/models/task_model.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/custom_progress_ring.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  TaskPriority? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = _authService.currentUser!.uid;

    final taskStream = _selectedPriority == null
        ? _firestoreService.watchUserTasks(uid)
        : _firestoreService.watchUserTasksByPriority(uid, _selectedPriority!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Creator'),
        actions: [
          IconButton(
            icon: Icon(
              ThemeControllerScope.of(context).isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ThemeControllerScope.of(context).toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context, uid),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: taskStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 40, color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Couldn\'t load your tasks.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          final todayTasks =
              tasks.where((t) => DateTimeFormatters.isToday(t.createdAt)).toList();
          final completedToday = todayTasks.where((t) => t.isCompleted).length;
          final progress = todayTasks.isEmpty
              ? 0.0
              : completedToday / todayTasks.length;

          return Column(
            children: [
              const SizedBox(height: 16),
              CustomProgressRing(percentage: progress),
              const SizedBox(height: 4),
              Text(
                todayTasks.isEmpty
                    ? 'No tasks scheduled today'
                    : '$completedToday of ${todayTasks.length} done today',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _PriorityFilterBar(
                selected: _selectedPriority,
                onSelected: (priority) =>
                    setState(() => _selectedPriority = priority),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tasks.isEmpty
                    ? _EmptyState(isFiltered: _selectedPriority != null)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onToggleComplete: (isCompleted) {
                              _firestoreService.setTaskCompleted(
                                taskId: task.id!,
                                isCompleted: isCompleted,
                              );
                            },
                            onDelete: () =>
                                _firestoreService.deleteTask(task.id!),
                            onTap: () => showTaskDetailSheet(
                              context,
                              task: task,
                              firestoreService: _firestoreService,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, String uid) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TaskPriority selectedPriority = TaskPriority.growth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('New Task', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Task title'),
                      validator: InputValidators.taskTitle,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: TaskPriority.values.map((priority) {
                        return ChoiceChip(
                          label: Text(_priorityLabel(priority)),
                          selected: selectedPriority == priority,
                          onSelected: (_) =>
                              setSheetState(() => selectedPriority = priority),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        _firestoreService.createTask(
                          TaskModel(
                            ownerId: uid,
                            title: titleController.text.trim(),
                            priority: selectedPriority,
                            createdAt: DateTime.now(),
                          ),
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Add task'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High-Value';
      case TaskPriority.growth:
        return 'Growth';
    }
  }
}

class _PriorityFilterBar extends StatelessWidget {
  final TaskPriority? selected;
  final ValueChanged<TaskPriority?> onSelected;

  const _PriorityFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(context, label: 'All', value: null),
          _chip(context, label: 'Critical', value: TaskPriority.critical,
              color: AppColors.priorityCritical),
          _chip(context, label: 'High-Value', value: TaskPriority.high,
              color: AppColors.priorityHigh),
          _chip(context, label: 'Growth', value: TaskPriority.growth,
              color: AppColors.priorityGrowth),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required TaskPriority? value,
    Color? color,
  }) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: (color ?? AppColors.sunsetCopper).withValues(alpha: 0.25),
        checkmarkColor: color ?? AppColors.sunsetCopper,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_rtl,
              size: 56,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No tasks in this category yet'
                  : 'Your pipeline is empty',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different filter, or add a task with this priority.'
                  : 'Tap the + button to start planning your next upload.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}