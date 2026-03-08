import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/file/file_bloc.dart';
import '../blocs/editor/editor_bloc.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header with app branding
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.primary,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.onPrimary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Agenda',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Actions Section
            _buildActions(context),
            const Divider(height: 1),

            // Files header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'FILES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // File List
            Expanded(child: _buildFileList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionChip(
            icon: Icons.calendar_today,
            label: 'Agenda',
            onTap: () {
              Scaffold.of(context).closeDrawer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agenda view coming soon')),
              );
            },
          ),
          _ActionChip(
            icon: Icons.search,
            label: 'Search',
            onTap: () {
              Scaffold.of(context).closeDrawer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search view coming soon')),
              );
            },
          ),
          _ActionChip(
            icon: Icons.book,
            label: 'Journal',
            onTap: () {
              Scaffold.of(context).closeDrawer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal view coming soon')),
              );
            },
          ),
          _ActionChip(
            icon: Icons.calendar_month,
            label: 'Calendar',
            onTap: () {
              Scaffold.of(context).closeDrawer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar view coming soon')),
              );
            },
          ),
          _ActionChip(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Scaffold.of(context).closeDrawer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings view coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state.status == FileStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No files yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Scaffold.of(context).closeDrawer();
                    _showNewFileDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create file'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.files.length,
          itemBuilder: (context, index) {
            final file = state.files[index];
            final isSelected = file == state.currentFilePath;
            final fileName = file.split('/').last.replaceAll('.md', '');

            return ListTile(
              dense: true,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? Icons.description : Icons.description_outlined,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ),
              title: Text(
                fileName,
                style: TextStyle(
                  color: isSelected ? colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                  fontSize: 15,
                ),
              ),
              selected: isSelected,
              selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
              onTap: () {
                context.read<FileBloc>().add(SelectFile(file));
                context.read<EditorBloc>().add(LoadFile(file));
                Scaffold.of(context).closeDrawer();
              },
            );
          },
        );
      },
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

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}
