import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/datasources/taskpaper_parser.dart';
import '../../../data/datasources/taskpaper_serializer.dart';
import '../../../data/repositories/local_file_repository.dart';
import '../../../domain/entities/outline_node.dart';
import '../../../domain/entities/outline_tree.dart';

part 'editor_event.dart';
part 'editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final LocalFileRepository _fileRepository;

  EditorBloc({LocalFileRepository? fileRepository})
    : _fileRepository = fileRepository ?? LocalFileRepository(),
      super(const EditorState()) {
    on<LoadFile>(_onLoadFile);
    on<UpdateNodeText>(_onUpdateNodeText);
    on<AddSibling>(_onAddSibling);
    on<AddChild>(_onAddChild);
    on<IndentNode>(_onIndentNode);
    on<DedentNode>(_onDedentNode);
    on<DeleteNode>(_onDeleteNode);
    on<MoveNodeUp>(_onMoveNodeUp);
    on<MoveNodeDown>(_onMoveNodeDown);
    on<SetFocusedNode>(_onSetFocusedNode);
    on<SaveFile>(_onSaveFile);
    on<CycleTodoState>(_onCycleTodoState);
    on<ToggleNodeExpansion>(_onToggleNodeExpansion);
  }

  Future<void> _onLoadFile(LoadFile event, Emitter<EditorState> emit) async {
    emit(state.copyWith(status: EditorStatus.loading));
    try {
      final content = await _fileRepository.readFile(event.filePath);
      final tree = TaskPaperParser.parse(content, filePath: event.filePath);
      emit(
        state.copyWith(
          status: EditorStatus.loaded,
          tree: tree,
          focusedNodeId: tree.rootNodes.isNotEmpty
              ? tree.rootNodes.first.id
              : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: EditorStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUpdateNodeText(
    UpdateNodeText event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    final updatedNode = node.copyWith(text: event.text);
    final newTree = currentTree.withUpdatedNode(updatedNode);

    emit(state.copyWith(tree: newTree, isDirty: true));
  }

  Future<void> _onAddSibling(
    AddSibling event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final newNode = OutlineNode(id: _generateId(), text: '');

    OutlineTree newTree;
    if (event.afterNodeId == null) {
      // Add at root level
      newTree = currentTree.withNode(newNode);
    } else {
      // Add as sibling
      final parent = currentTree.findParent(event.afterNodeId!);
      if (parent != null) {
        // Find the index of the sibling
        final siblings = parent.children;
        final index = siblings.indexWhere((n) => n.id == event.afterNodeId);
        if (index >= 0) {
          // Insert after
          final newChildren = [...siblings];
          newChildren.insert(index + 1, newNode.copyWith(parentId: parent.id));
          final updatedParent = parent.copyWith(children: newChildren);
          newTree = currentTree.withUpdatedNode(updatedParent);
        } else {
          newTree = currentTree.withNode(newNode);
        }
      } else {
        // Add at root level after the node
        final index = currentTree.rootNodes.indexWhere(
          (n) => n.id == event.afterNodeId,
        );
        if (index >= 0) {
          final newRootNodes = [...currentTree.rootNodes];
          newRootNodes.insert(index + 1, newNode);
          newTree = currentTree.copyWith(rootNodes: newRootNodes);
        } else {
          newTree = currentTree.withNode(newNode);
        }
      }
    }

    emit(
      state.copyWith(tree: newTree, focusedNodeId: newNode.id, isDirty: true),
    );
  }

  Future<void> _onAddChild(AddChild event, Emitter<EditorState> emit) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final parent = currentTree.findNode(event.parentNodeId);
    if (parent == null) return;

    final newNode = OutlineNode(
      id: _generateId(),
      text: '',
      parentId: parent.id,
      depth: parent.depth + 1,
    );

    final updatedParent = parent.withChild(newNode);
    final newTree = currentTree.withUpdatedNode(updatedParent);

    emit(
      state.copyWith(tree: newTree, focusedNodeId: newNode.id, isDirty: true),
    );
  }

  Future<void> _onIndentNode(
    IndentNode event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    // Find the previous sibling to become the new parent
    final parent = currentTree.findParent(event.nodeId);
    if (parent != null) {
      final siblings = parent.children;
      final index = siblings.indexWhere((n) => n.id == event.nodeId);
      if (index > 0) {
        // Move under previous sibling
        final newParent = siblings[index - 1];
        final updatedNewParent = newParent.withChild(
          node.copyWith(parentId: newParent.id, depth: newParent.depth + 1),
        );

        // Remove from old parent
        final updatedOldParent = parent.withoutChild(event.nodeId);

        // Update tree
        var newTree = currentTree.withUpdatedNode(updatedOldParent);
        newTree = newTree.withUpdatedNode(updatedNewParent);

        emit(state.copyWith(tree: newTree, isDirty: true));
        return;
      }
    } else {
      // At root level - indent under previous root node
      final index = currentTree.rootNodes.indexWhere(
        (n) => n.id == event.nodeId,
      );
      if (index > 0) {
        final newParent = currentTree.rootNodes[index - 1];
        final updatedNewParent = newParent.withChild(
          node.copyWith(parentId: newParent.id, depth: newParent.depth + 1),
        );

        // Remove from root and update
        final newRootNodes = [...currentTree.rootNodes];
        newRootNodes.removeAt(index);
        newRootNodes[index - 1] = updatedNewParent;

        final newTree = currentTree.copyWith(rootNodes: newRootNodes);

        emit(state.copyWith(tree: newTree, isDirty: true));
      }
    }
  }

  Future<void> _onDedentNode(
    DedentNode event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    final parent = currentTree.findParent(event.nodeId);
    if (parent == null) return; // Can't dedent root level

    final grandparent = currentTree.findParent(parent.id);

    // Remove from current parent
    final updatedParent = parent.withoutChild(event.nodeId);
    var newTree = currentTree.withUpdatedNode(updatedParent);

    // Move to grandparent or root
    final updatedNode = node.copyWith(
      parentId: grandparent?.id,
      depth: grandparent != null ? grandparent.depth + 1 : 0,
    );

    if (grandparent != null) {
      // Insert after parent in grandparent's children
      final siblings = grandparent.children;
      final parentIndex = siblings.indexWhere((n) => n.id == parent.id);
      final newChildren = [...siblings];
      newChildren.insert(parentIndex + 1, updatedNode);
      final updatedGrandparent = grandparent.copyWith(children: newChildren);
      newTree = newTree.withUpdatedNode(updatedGrandparent);
    } else {
      // Move to root level after parent
      final index = newTree.rootNodes.indexWhere((n) => n.id == parent.id);
      final newRootNodes = [...newTree.rootNodes];
      newRootNodes.insert(index + 1, updatedNode);
      newTree = newTree.copyWith(rootNodes: newRootNodes);
    }

    emit(state.copyWith(tree: newTree, isDirty: true));
  }

  Future<void> _onDeleteNode(
    DeleteNode event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    // Move children to parent or siblings
    final parent = currentTree.findParent(event.nodeId);

    // Remove node
    var newTree = currentTree.withoutNode(event.nodeId);

    // If node had children, they need to be re-parented
    if (node.hasChildren) {
      if (parent != null) {
        // Add children to parent
        final updatedParent = parent.copyWith(
          children: [
            ...parent.children,
            ...node.children.map(
              (c) => c.copyWith(parentId: parent.id, depth: parent.depth + 1),
            ),
          ],
        );
        newTree = newTree.withUpdatedNode(updatedParent);
      } else {
        // Add children to root
        final newRootNodes = [
          ...newTree.rootNodes,
          ...node.children.map((c) => c.copyWith(parentId: null, depth: 0)),
        ];
        newTree = newTree.copyWith(rootNodes: newRootNodes);
      }
    }

    // Update focused node
    String? newFocusId;
    final allNodes = newTree.allNodes;
    if (allNodes.isNotEmpty) {
      newFocusId = allNodes.first.id;
    }

    emit(
      state.copyWith(tree: newTree, focusedNodeId: newFocusId, isDirty: true),
    );
  }

  Future<void> _onMoveNodeUp(
    MoveNodeUp event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    final parent = currentTree.findParent(event.nodeId);
    if (parent != null) {
      final siblings = parent.children;
      final index = siblings.indexWhere((n) => n.id == event.nodeId);
      if (index > 0) {
        final newChildren = [...siblings];
        final temp = newChildren[index - 1];
        newChildren[index - 1] = newChildren[index];
        newChildren[index] = temp;
        final updatedParent = parent.copyWith(children: newChildren);
        final newTree = currentTree.withUpdatedNode(updatedParent);
        emit(state.copyWith(tree: newTree, isDirty: true));
      }
    } else {
      final index = currentTree.rootNodes.indexWhere(
        (n) => n.id == event.nodeId,
      );
      if (index > 0) {
        final newRootNodes = [...currentTree.rootNodes];
        final temp = newRootNodes[index - 1];
        newRootNodes[index - 1] = newRootNodes[index];
        newRootNodes[index] = temp;
        final newTree = currentTree.copyWith(rootNodes: newRootNodes);
        emit(state.copyWith(tree: newTree, isDirty: true));
      }
    }
  }

  Future<void> _onMoveNodeDown(
    MoveNodeDown event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    final parent = currentTree.findParent(event.nodeId);
    if (parent != null) {
      final siblings = parent.children;
      final index = siblings.indexWhere((n) => n.id == event.nodeId);
      if (index < siblings.length - 1) {
        final newChildren = [...siblings];
        final temp = newChildren[index + 1];
        newChildren[index + 1] = newChildren[index];
        newChildren[index] = temp;
        final updatedParent = parent.copyWith(children: newChildren);
        final newTree = currentTree.withUpdatedNode(updatedParent);
        emit(state.copyWith(tree: newTree, isDirty: true));
      }
    } else {
      final index = currentTree.rootNodes.indexWhere(
        (n) => n.id == event.nodeId,
      );
      if (index < currentTree.rootNodes.length - 1) {
        final newRootNodes = [...currentTree.rootNodes];
        final temp = newRootNodes[index + 1];
        newRootNodes[index + 1] = newRootNodes[index];
        newRootNodes[index] = temp;
        final newTree = currentTree.copyWith(rootNodes: newRootNodes);
        emit(state.copyWith(tree: newTree, isDirty: true));
      }
    }
  }

  Future<void> _onSetFocusedNode(
    SetFocusedNode event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(focusedNodeId: event.nodeId));
  }

  Future<void> _onSaveFile(SaveFile event, Emitter<EditorState> emit) async {
    final currentTree = state.tree;
    if (currentTree == null || currentTree.filePath == null) return;

    emit(state.copyWith(status: EditorStatus.saving));
    try {
      final content = TaskPaperSerializer.serialize(currentTree);
      await _fileRepository.writeFile(currentTree.filePath!, content);
      emit(state.copyWith(status: EditorStatus.loaded, isDirty: false));
    } catch (e) {
      emit(state.copyWith(status: EditorStatus.error, error: e.toString()));
    }
  }

  Future<void> _onCycleTodoState(
    CycleTodoState event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    // Cycle through TODO states: null -> TODO -> NEXT -> DONE -> null
    final states = [null, 'TODO', 'NEXT', 'DONE'];
    final currentIndex = states.indexOf(node.todoState);
    final nextIndex = (currentIndex + 1) % states.length;
    final nextState = states[nextIndex];

    final updatedNode = node.copyWith(todoState: nextState);
    final newTree = currentTree.withUpdatedNode(updatedNode);

    emit(state.copyWith(tree: newTree, isDirty: true));
  }

  Future<void> _onToggleNodeExpansion(
    ToggleNodeExpansion event,
    Emitter<EditorState> emit,
  ) async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    final node = currentTree.findNode(event.nodeId);
    if (node == null) return;

    final updatedNode = node.copyWith(isExpanded: !node.isExpanded);
    final newTree = currentTree.withUpdatedNode(updatedNode);

    emit(state.copyWith(tree: newTree));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + DateTime.now().microsecond).toString();
  }
}
