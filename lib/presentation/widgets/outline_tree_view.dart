import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/outline_node.dart';
import '../blocs/editor/editor_bloc.dart';

/// Android-optimized tree view with touch interactions
class OutlineTreeView extends StatelessWidget {
  final List<OutlineNode> nodes;
  final String? focusedNodeId;

  const OutlineTreeView({super.key, required this.nodes, this.focusedNodeId});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return _EmptyDocumentView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return _OutlineNodeItem(
          node: node,
          isFocused: node.id == focusedNodeId,
          onFocus: () {
            context.read<EditorBloc>().add(SetFocusedNode(node.id));
          },
          onTextChanged: (text) {
            context.read<EditorBloc>().add(UpdateNodeText(node.id, text));
          },
        );
      },
    );
  }
}

class _EmptyDocumentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap + to add your first item',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe from left for files',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineNodeItem extends StatefulWidget {
  final OutlineNode node;
  final bool isFocused;
  final VoidCallback onFocus;
  final ValueChanged<String> onTextChanged;

  const _OutlineNodeItem({
    required this.node,
    required this.isFocused,
    required this.onFocus,
    required this.onTextChanged,
  });

  @override
  State<_OutlineNodeItem> createState() => _OutlineNodeItemState();
}

class _OutlineNodeItemState extends State<_OutlineNodeItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.text);
    _focusNode = FocusNode();

    if (widget.isFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(_OutlineNodeItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node.text != _controller.text) {
      _controller.text = widget.node.text;
    }
    if (widget.isFocused && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    if (!widget.isFocused && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final depth = widget.node.depth;
    final todoState = widget.node.todoState;

    return Container(
      margin: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: widget.isFocused
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Expand/collapse indicator for nodes with children
          if (widget.node.hasChildren)
            GestureDetector(
              onTap: () {
                context.read<EditorBloc>().add(
                  ToggleNodeExpansion(widget.node.id),
                );
              },
              child: SizedBox(
                width: 24,
                height: 40,
                child: Icon(
                  widget.node.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            const SizedBox(width: 24),

          // Bullet point / TODO state indicator
          GestureDetector(
            onTap: () {
              // Single tap cycles TODO state
              context.read<EditorBloc>().add(CycleTodoState(widget.node.id));
            },
            onLongPress: () {
              _showContextMenu(context);
            },
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getTodoColor(todoState, colorScheme),
                border: todoState == null
                    ? Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  _getTodoSymbol(todoState),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: todoState != null ? Colors.white : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  widget.onFocus();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: todoState == 'DONE'
                      ? TextDecoration.lineThrough
                      : null,
                  color: todoState == 'DONE'
                      ? colorScheme.onSurface.withOpacity(0.5)
                      : null,
                ),
                onChanged: widget.onTextChanged,
                textInputAction: TextInputAction.next,
                onSubmitted: (text) {
                  // Move to next item or create new sibling
                  context.read<EditorBloc>().add(
                    AddSibling(afterNodeId: widget.node.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.format_indent_increase, size: 20),
              SizedBox(width: 8),
              Text('Indent'),
            ],
          ),
          onTap: () =>
              context.read<EditorBloc>().add(IndentNode(widget.node.id)),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.format_indent_decrease, size: 20),
              SizedBox(width: 8),
              Text('Dedent'),
            ],
          ),
          onTap: () =>
              context.read<EditorBloc>().add(DedentNode(widget.node.id)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text('Add child'),
            ],
          ),
          onTap: () => context.read<EditorBloc>().add(AddChild(widget.node.id)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          onTap: () =>
              context.read<EditorBloc>().add(DeleteNode(widget.node.id)),
        ),
      ],
    );
  }

  Color _getTodoColor(String? state, ColorScheme colorScheme) {
    // Yellow theme colors for TODO states
    switch (state) {
      case 'TODO':
        return const Color(0xFFFFC107); // Yellow
      case 'NEXT':
        return const Color(0xFFFF9800); // Orange
      case 'DONE':
        return const Color(0xFF4CAF50); // Green
      case 'WAITING':
        return const Color(0xFF9E9E9E); // Grey
      case 'CANCELLED':
        return const Color(0xFFE57373); // Light red
      default:
        return colorScheme.surface;
    }
  }

  String _getTodoSymbol(String? state) {
    switch (state) {
      case 'TODO':
        return 'T';
      case 'NEXT':
        return 'N';
      case 'DONE':
        return '✓';
      case 'WAITING':
        return 'W';
      case 'CANCELLED':
        return '✕';
      default:
        return '•';
    }
  }
}
