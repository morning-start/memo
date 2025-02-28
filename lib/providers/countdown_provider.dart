import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/countdown_model.dart';

class CountdownNotifier extends StateNotifier<List<Countdown>> {
  CountdownNotifier() : super([]);

  void addTask(Countdown task) {
    state = [...state, task];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void updateTask(String id, Countdown updatedTask) {
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }

}

final countdownProvider = StateNotifierProvider<CountdownNotifier, List<Countdown>>(
  (ref) => CountdownNotifier(),
);