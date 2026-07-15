import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  Stream<List<TaskModel>> watchUserTasks(String uid) {
    return _tasksCollection
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<TaskModel>> watchUserTasksByPriority(
    String uid,
    TaskPriority priority,
  ) {
    return _tasksCollection
        .where('ownerId', isEqualTo: uid)
        .where('priority', isEqualTo: priority.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<String> createTask(TaskModel task) async {
    final docRef = await _tasksCollection.add(task.toJson());
    return docRef.id;
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw ArgumentError(
        'Cannot update a task with no id. Use createTask() for new tasks.',
      );
    }
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> setTaskCompleted({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }

  Future<void> incrementPomodoroCount(String taskId) async {
    await _tasksCollection.doc(taskId).update({
      'pomodorosCompleted': FieldValue.increment(1),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
}