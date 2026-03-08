import '../../domain/entities/outline_node.dart';
import '../../domain/entities/outline_tree.dart';

class TaskPaperParser {
  /// Parse TaskPaper format text into an OutlineTree
  static OutlineTree parse(String content, {String? filePath}) {
    final lines = content.split('\n');
    final rootNodes = <OutlineNode>[];
    final nodeStack = <OutlineNode>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final (node, depth) = _parseLine(line);
      if (node == null) continue;

      // Adjust stack based on depth
      while (nodeStack.length > depth) {
        nodeStack.removeLast();
      }

      if (nodeStack.isEmpty) {
        // Root level node
        rootNodes.add(node);
      } else {
        // Child node - add to parent
        final parent = nodeStack.last;
        final nodeWithParent = node.copyWith(
          parentId: parent.id,
          depth: parent.depth + 1,
        );

        // Update parent in stack
        final updatedParent = parent.withChild(nodeWithParent);
        nodeStack[nodeStack.length - 1] = updatedParent;

        // Update parent's parent in the tree if needed
        if (nodeStack.length > 1) {
          final grandparent = nodeStack[nodeStack.length - 2];
          nodeStack[nodeStack.length - 2] = grandparent.withUpdatedChild(
            updatedParent.id,
            updatedParent,
          );
        }
      }

      nodeStack.add(node);
    }

    return OutlineTree(filePath: filePath, rootNodes: rootNodes);
  }

  /// Parse a single line into an OutlineNode
  static (OutlineNode?, int) _parseLine(String line) {
    final trimmed = line.trimRight();
    if (trimmed.isEmpty) return (null, 0);

    // Calculate depth based on leading whitespace
    final leadingWhitespace = line.length - line.trimLeft().length;
    final depth = leadingWhitespace ~/ 2; // 2 spaces = 1 level

    final content = trimmed;

    // Check if it's a project (ends with :)
    if (content.endsWith(':') &&
        !content.startsWith('- ') &&
        !content.startsWith('* ')) {
      final projectName = content.substring(0, content.length - 1).trim();
      return (
        OutlineNode(
          id: _generateId(),
          text: projectName,
          depth: depth,
          isExpanded: true,
        ),
        depth,
      );
    }

    // Check if it's a task (starts with - or *)
    String? text = content;
    String? todoState;
    List<String> tags = [];

    if (content.startsWith('- ') || content.startsWith('* ')) {
      text = content.substring(2);

      // Extract TODO state if present (TODO, NEXT, DONE, etc.)
      final todoMatch = RegExp(
        r'^(TODO|NEXT|DONE|WAITING|CANCELLED)\s+',
      ).firstMatch(text);
      if (todoMatch != null) {
        todoState = todoMatch.group(1);
        text = text.substring(todoMatch.end).trim();
      }

      // Extract tags (@tag or @tag(value))
      final tagRegex = RegExp(r'@(\w+)(?:\([^)]*\))?');
      final tagMatches = tagRegex.allMatches(text);
      tags = tagMatches.map((m) => m.group(0)!).toList();

      // Remove tags from text for cleaner display
      text = text.replaceAll(tagRegex, '').trim();
    }

    return (
      OutlineNode(
        id: _generateId(),
        text: text ?? content,
        todoState: todoState,
        depth: depth,
        tags: tags,
        isExpanded: true,
      ),
      depth,
    );
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + DateTime.now().microsecond).toString();
  }
}
