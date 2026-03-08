import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TodoState extends Equatable {
  final String name;
  final Color color;
  final String? nextState;

  const TodoState({required this.name, required this.color, this.nextState});

  @override
  List<Object?> get props => [name, color, nextState];
}

class TodoConfigState extends Equatable {
  final List<TodoState> states;
  final Map<String, TodoState> stateMap;

  const TodoConfigState({required this.states, required this.stateMap});

  factory TodoConfigState.defaultConfig() {
    const todo = TodoState(name: 'TODO', color: Colors.red, nextState: 'NEXT');
    const next = TodoState(name: 'NEXT', color: Colors.blue, nextState: 'DONE');
    const done = TodoState(
      name: 'DONE',
      color: Colors.green,
      nextState: 'TODO',
    );

    return TodoConfigState(
      states: const [todo, next, done],
      stateMap: const {'TODO': todo, 'NEXT': next, 'DONE': done},
    );
  }

  TodoState? getNextState(String currentState) {
    final current = stateMap[currentState];
    if (current?.nextState == null) return null;
    return stateMap[current!.nextState];
  }

  @override
  List<Object> get props => [states, stateMap];
}

class TodoConfigCubit extends Cubit<TodoConfigState> {
  TodoConfigCubit() : super(TodoConfigState.defaultConfig());

  void loadDefaultConfig() {
    emit(TodoConfigState.defaultConfig());
  }

  void updateStates(List<TodoState> states) {
    final stateMap = {for (var s in states) s.name: s};
    emit(TodoConfigState(states: states, stateMap: stateMap));
  }

  TodoState? cycleState(String? currentState) {
    if (currentState == null) {
      return state.states.firstOrNull;
    }
    return state.getNextState(currentState);
  }
}
