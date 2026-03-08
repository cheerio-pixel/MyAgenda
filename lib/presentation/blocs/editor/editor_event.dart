part of 'editor_bloc.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadFile extends EditorEvent {
  final String filePath;
  const LoadFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UpdateNodeText extends EditorEvent {
  final String nodeId;
  final String text;
  const UpdateNodeText(this.nodeId, this.text);

  @override
  List<Object?> get props => [nodeId, text];
}

class AddSibling extends EditorEvent {
  final String? afterNodeId;
  const AddSibling({this.afterNodeId});

  @override
  List<Object?> get props => [afterNodeId];
}

class AddChild extends EditorEvent {
  final String parentNodeId;
  const AddChild(this.parentNodeId);

  @override
  List<Object?> get props => [parentNodeId];
}

class IndentNode extends EditorEvent {
  final String nodeId;
  const IndentNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class DedentNode extends EditorEvent {
  final String nodeId;
  const DedentNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class DeleteNode extends EditorEvent {
  final String nodeId;
  const DeleteNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class MoveNodeUp extends EditorEvent {
  final String nodeId;
  const MoveNodeUp(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class MoveNodeDown extends EditorEvent {
  final String nodeId;
  const MoveNodeDown(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class SetFocusedNode extends EditorEvent {
  final String? nodeId;
  const SetFocusedNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class SaveFile extends EditorEvent {
  const SaveFile();
}

class CycleTodoState extends EditorEvent {
  final String nodeId;
  const CycleTodoState(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class ToggleNodeExpansion extends EditorEvent {
  final String nodeId;
  const ToggleNodeExpansion(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}
