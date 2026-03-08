import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/editor/editor_bloc.dart';

class KeyboardMenuBar extends StatelessWidget {
  const KeyboardMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MenuButton(
                icon: Icons.format_indent_increase,
                tooltip: 'Indent (Tab)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      IndentNode(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.format_indent_decrease,
                tooltip: 'Dedent (Shift+Tab)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      DedentNode(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.check_circle,
                tooltip: 'Next TODO (Ctrl+T)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      CycleTodoState(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.add,
                tooltip: 'New Item (Enter)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  context.read<EditorBloc>().add(
                    AddSibling(afterNodeId: state.focusedNodeId),
                  );
                },
              ),
              _MenuButton(
                icon: Icons.subdirectory_arrow_right,
                tooltip: 'New Child (Shift+Enter)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      AddChild(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.delete,
                tooltip: 'Delete',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      DeleteNode(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.arrow_upward,
                tooltip: 'Move Up (Ctrl+↑)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      MoveNodeUp(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.arrow_downward,
                tooltip: 'Move Down (Ctrl+↓)',
                onPressed: () {
                  final state = context.read<EditorBloc>().state;
                  if (state.focusedNodeId != null) {
                    context.read<EditorBloc>().add(
                      MoveNodeDown(state.focusedNodeId!),
                    );
                  }
                },
              ),
              _MenuButton(
                icon: Icons.unfold_less,
                tooltip: 'Toggle Fold (Ctrl+.)',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
  }
}
