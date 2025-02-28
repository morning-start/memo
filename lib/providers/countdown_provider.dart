import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/countdown_model.dart';

class CountdownNotifier extends StateNotifier<List<CountdownTask>> {
  CountdownNotifier() : super([]);

  void addTask(CountdownTask task) {
    state = [...state, task];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void updateTask(String id, CountdownTask updatedTask) {
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }

}

final countdownProvider = StateNotifierProvider<CountdownNotifier, List<CountdownTask>>(
  (ref) => CountdownNotifier(),
);