import 'package:equatable/equatable.dart';

class OutlineNode extends Equatable {
  final String id;
  final String text;
  final String? todoState;
  final int depth;
  final List<String> tags;
  final List<OutlineNode> children;
  final bool isExpanded;
  final String? parentId;

  const OutlineNode({
    required this.id,
    required this.text,
    this.todoState,
    this.depth = 0,
    this.tags = const [],
    this.children = const [],
    this.isExpanded = true,
    this.parentId,
  });

  OutlineNode copyWith({
    String? id,
    String? text,
    String? todoState,
    int? depth,
    List<String>? tags,
    List<OutlineNode>? children,
    bool? isExpanded,
    String? parentId,
  }) {
    return OutlineNode(
      id: id ?? this.id,
      text: text ?? this.text,
      todoState: todoState ?? this.todoState,
      depth: depth ?? this.depth,
      tags: tags ?? this.tags,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      parentId: parentId ?? this.parentId,
    );
  }

  OutlineNode withChild(OutlineNode child) {
    return copyWith(children: [...children, child]);
  }

  OutlineNode withUpdatedChild(String childId, OutlineNode updatedChild) {
    return copyWith(
      children: children
          .map((c) => c.id == childId ? updatedChild : c)
          .toList(),
    );
  }

  OutlineNode withoutChild(String childId) {
    return copyWith(children: children.where((c) => c.id != childId).toList());
  }

  bool get hasChildren => children.isNotEmpty;
  bool get isLeaf => children.isEmpty;

  @override
  List<Object?> get props => [
    id,
    text,
    todoState,
    depth,
    tags,
    children,
    isExpanded,
    parentId,
  ];
}
