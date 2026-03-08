part of 'editor_bloc.dart';

enum EditorStatus { initial, loading, loaded, saving, error }

class EditorState extends Equatable {
  final EditorStatus status;
  final OutlineTree? tree;
  final String? focusedNodeId;
  final bool isDirty;
  final String? error;

  const EditorState({
    this.status = EditorStatus.initial,
    this.tree,
    this.focusedNodeId,
    this.isDirty = false,
    this.error,
  });

  EditorState copyWith({
    EditorStatus? status,
    OutlineTree? tree,
    String? focusedNodeId,
    bool? isDirty,
    String? error,
  }) {
    return EditorState(
      status: status ?? this.status,
      tree: tree ?? this.tree,
      focusedNodeId: focusedNodeId ?? this.focusedNodeId,
      isDirty: isDirty ?? this.isDirty,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, tree, focusedNodeId, isDirty, error];
}
