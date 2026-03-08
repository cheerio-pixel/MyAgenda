import 'package:equatable/equatable.dart';
import 'outline_node.dart';

class OutlineTree extends Equatable {
  final String? filePath;
  final List<OutlineNode> rootNodes;
  final String? focusedNodeId;

  const OutlineTree({
    this.filePath,
    this.rootNodes = const [],
    this.focusedNodeId,
  });

  OutlineTree copyWith({
    String? filePath,
    List<OutlineNode>? rootNodes,
    String? focusedNodeId,
  }) {
    return OutlineTree(
      filePath: filePath ?? this.filePath,
      rootNodes: rootNodes ?? this.rootNodes,
      focusedNodeId: focusedNodeId ?? this.focusedNodeId,
    );
  }

  List<OutlineNode> get allNodes {
    final result = <OutlineNode>[];
    void traverse(List<OutlineNode> nodes) {
      for (final node in nodes) {
        result.add(node);
        if (node.isExpanded) {
          traverse(node.children);
        }
      }
    }

    traverse(rootNodes);
    return result;
  }

  OutlineNode? findNode(String id) {
    OutlineNode? search(List<OutlineNode> nodes) {
      for (final node in nodes) {
        if (node.id == id) return node;
        final found = search(node.children);
        if (found != null) return found;
      }
      return null;
    }

    return search(rootNodes);
  }

  OutlineNode? findParent(String childId) {
    OutlineNode? search(List<OutlineNode> nodes, String? parentId) {
      for (final node in nodes) {
        if (node.id == childId) {
          return parentId != null ? findNode(parentId) : null;
        }
        final found = search(node.children, node.id);
        if (found != null) return found;
      }
      return null;
    }

    return search(rootNodes, null);
  }

  OutlineTree withNode(OutlineNode node) {
    return copyWith(rootNodes: [...rootNodes, node]);
  }

  OutlineTree withoutNode(String id) {
    OutlineNode? removeFrom(List<OutlineNode> nodes) {
      for (int i = 0; i < nodes.length; i++) {
        if (nodes[i].id == id) {
          final removed = nodes[i];
          nodes.removeAt(i);
          return removed;
        }
        final removed = removeFrom(nodes[i].children);
        if (removed != null) return removed;
      }
      return null;
    }

    final newRoots = List<OutlineNode>.from(rootNodes);
    removeFrom(newRoots);
    return copyWith(rootNodes: newRoots);
  }

  OutlineTree withUpdatedNode(OutlineNode updatedNode) {
    OutlineNode updateInTree(OutlineNode node) {
      if (node.id == updatedNode.id) {
        return updatedNode;
      }
      return node.copyWith(children: node.children.map(updateInTree).toList());
    }

    return copyWith(rootNodes: rootNodes.map(updateInTree).toList());
  }

  int get nodeCount {
    int count = 0;
    void traverse(List<OutlineNode> nodes) {
      for (final node in nodes) {
        count++;
        traverse(node.children);
      }
    }

    traverse(rootNodes);
    return count;
  }

  @override
  List<Object?> get props => [filePath, rootNodes, focusedNodeId];
}
