import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_formatters.dart';
import '../../core/utils/input_validators.dart';
import '../../data/models/task_model.dart';
import '../../data/services/firestore_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final FirestoreService firestoreService;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.firestoreService,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await widget.firestoreService.updateTask(
        TaskModel(
          id: widget.task.id,
          ownerId: widget.task.ownerId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          isCompleted: widget.task.isCompleted,
          createdAt: widget.task.createdAt,
          dueDate: _dueDate,
          pomodorosCompleted: widget.task.pomodorosCompleted,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isSaving = true);
    try {
      await widget.firestoreService.deleteTask(widget.task.id!);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _titleController,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Task title'),
                    validator: InputValidators.taskTitle,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Priority', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskPriority.values.map((priority) {
                      return ChoiceChip(
                        label: Text(_priorityLabel(priority)),
                        selected: _priority == priority,
                        onSelected: (_) => setState(() => _priority = priority),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Due date', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      _dueDate == null
                          ? 'Set a due date'
                          : DateTimeFormatters.friendlyDate(_dueDate!),
                    ),
                  ),
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () => setState(() => _dueDate = null),
                      child: const Text('Clear due date'),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _delete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.priorityCritical,
                            side: const BorderSide(color: AppColors.priorityCritical),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void showTaskDetailSheet(
  BuildContext context, {
  required TaskModel task,
  required FirestoreService firestoreService,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => TaskDetailScreen(
      task: task,
      firestoreService: firestoreService,
    ),
  );
}