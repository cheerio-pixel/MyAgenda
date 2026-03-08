import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TodoState extends Equatable {
  final String name;
  final Color color;
  final String? nextStateName;

  const TodoState({
    required this.name,
    required this.color,
    this.nextStateName,
  });

  TodoState copyWith({String? name, Color? color, String? nextStateName}) {
    return TodoState(
      name: name ?? this.name,
      color: color ?? this.color,
      nextStateName: nextStateName ?? this.nextStateName,
    );
  }

  @override
  List<Object?> get props => [name, color, nextStateName];
}
