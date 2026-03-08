import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/file/file_bloc.dart';
import '../blocs/editor/editor_bloc.dart';
import '../widgets/sidebar.dart';
import '../widgets/editor_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: BlocBuilder<FileBloc, FileState>(
          builder: (context, state) {
            String title = 'My Agenda';
            if (state.currentFilePath != null) {
              title = state.currentFilePath!
                  .split('/')
                  .last
                  .replaceAll('.md', '');
            }
            return Text(title);
          },
        ),
        actions: [
          // Save indicator
          BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) {
              if (state.status == EditorStatus.saving) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (state.isDirty) {
                return IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: () {
                    context.read<EditorBloc>().add(const SaveFile());
                  },
                  tooltip: 'Save',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // New file button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewFileDialog(context),
            tooltip: 'New file',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          // Navigation for hardware keyboards
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            _moveFocus(context, -1);
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            _moveFocus(context, 1);
          },
          // Indent/Dedent
          const SingleActivator(LogicalKeyboardKey.tab): () {
            _indent(context);
          },
          const SingleActivator(LogicalKeyboardKey.tab, shift: true): () {
            _dedent(context);
          },
          // New items
          const SingleActivator(LogicalKeyboardKey.enter): () {
            _addSibling(context);
          },
          const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
            _addChild(context);
          },
          // Save
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            context.read<EditorBloc>().add(const SaveFile());
          },
          // New file
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
            _showNewFileDialog(context);
          },
        },
        child: const EditorView(),
      ),
      floatingActionButton: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          // Only show FAB when we have a file loaded
          if (state.tree == null) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              _addSibling(context);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          if (state.tree == null) return const SizedBox.shrink();

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBottomButton(
                      context,
                      icon: Icons.format_indent_increase,
                      label: 'Indent',
                      onPressed: state.focusedNodeId != null
                          ? () => context.read<EditorBloc>().add(
                              IndentNode(state.focusedNodeId!),
                            )
                          : null,
                    ),
                    _buildBottomButton(
                      context,
                      icon: Icons.format_indent_decrease,
                      label: 'Dedent',
                      onPressed: state.focusedNodeId != null
                          ? () => context.read<EditorBloc>().add(
                              DedentNode(state.focusedNodeId!),
                            )
                          : null,
                    ),
                    _buildBottomButton(
                      context,
                      icon: Icons.arrow_upward,
                      label: 'Up',
                      onPressed: state.focusedNodeId != null
                          ? () => context.read<EditorBloc>().add(
                              MoveNodeUp(state.focusedNodeId!),
                            )
                          : null,
                    ),
                    _buildBottomButton(
                      context,
                      icon: Icons.arrow_downward,
                      label: 'Down',
                      onPressed: state.focusedNodeId != null
                          ? () => context.read<EditorBloc>().add(
                              MoveNodeDown(state.focusedNodeId!),
                            )
                          : null,
                    ),
                    _buildBottomButton(
                      context,
                      icon: Icons.delete,
                      label: 'Delete',
                      onPressed: state.focusedNodeId != null
                          ? () => _confirmDelete(context, state.focusedNodeId!)
                          : null,
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final isEnabled = onPressed != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isEnabled
                    ? (color ?? Theme.of(context).colorScheme.onSurface)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isEnabled
                      ? (color ?? Theme.of(context).colorScheme.onSurface)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveFocus(BuildContext context, int direction) {
    final state = context.read<EditorBloc>().state;
    if (state.tree == null) return;

    final nodes = state.tree!.allNodes;
    if (nodes.isEmpty) return;

    final currentIndex = nodes.indexWhere((n) => n.id == state.focusedNodeId);
    int newIndex;

    if (currentIndex == -1) {
      newIndex = 0;
    } else {
      newIndex = (currentIndex + direction).clamp(0, nodes.length - 1);
    }

    context.read<EditorBloc>().add(SetFocusedNode(nodes[newIndex].id));
  }

  void _indent(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    if (state.focusedNodeId != null) {
      context.read<EditorBloc>().add(IndentNode(state.focusedNodeId!));
    }
  }

  void _dedent(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    if (state.focusedNodeId != null) {
      context.read<EditorBloc>().add(DedentNode(state.focusedNodeId!));
    }
  }

  void _addSibling(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    context.read<EditorBloc>().add(
      AddSibling(afterNodeId: state.focusedNodeId),
    );
  }

  void _addChild(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    if (state.focusedNodeId != null) {
      context.read<EditorBloc>().add(AddChild(state.focusedNodeId!));
    }
  }

  void _confirmDelete(BuildContext context, String nodeId) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete this item?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<EditorBloc>().add(DeleteNode(nodeId));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewFileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String fileName = '';
        return AlertDialog(
          title: const Text('Create New File'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter file name',
              prefixIcon: Icon(Icons.description),
            ),
            onChanged: (value) => fileName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (fileName.isNotEmpty) {
                  context.read<FileBloc>().add(CreateFile(fileName));
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
