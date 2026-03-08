import '../../domain/entities/outline_node.dart';
import '../../domain/entities/outline_tree.dart';

class TaskPaperSerializer {
  /// Serialize an OutlineTree to TaskPaper format
  static String serialize(OutlineTree tree) {
    final buffer = StringBuffer();

    for (final node in tree.rootNodes) {
      _serializeNode(buffer, node, 0);
    }

    return buffer.toString().trimRight();
  }

  static void _serializeNode(StringBuffer buffer, OutlineNode node, int depth) {
    final indent = '  ' * depth;

    // Check if it's a project (has children and no todo state)
    if (node.hasChildren && node.todoState == null) {
      buffer.writeln('$indent${node.text}:'.trimRight());
    } else {
      // It's a task
      final todoPrefix = node.todoState != null ? '${node.todoState} ' : '';
      final tagsSuffix = node.tags.isNotEmpty ? ' ${node.tags.join(' ')}' : '';
      buffer.writeln('$indent- $todoPrefix${node.text}$tagsSuffix'.trimRight());
    }

    // Serialize children
    for (final child in node.children) {
      _serializeNode(buffer, child, depth + 1);
    }
  }

  /// Serialize just the nodes (without file metadata)
  static String serializeNodes(List<OutlineNode> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      _serializeNode(buffer, node, 0);
    }
    return buffer.toString().trimRight();
  }
}
