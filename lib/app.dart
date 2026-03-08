import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'presentation/blocs/file/file_bloc.dart';
import 'presentation/blocs/editor/editor_bloc.dart';
import 'presentation/blocs/sidebar/sidebar_cubit.dart';
import 'presentation/blocs/todo_config/todo_config_cubit.dart';
import 'presentation/pages/home_page.dart';

class MyAgendaApp extends StatelessWidget {
  const MyAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FileBloc()..add(const LoadFiles())),
        BlocProvider(create: (context) => EditorBloc()),
        BlocProvider(create: (context) => SidebarCubit()),
        BlocProvider(
          create: (context) => TodoConfigCubit()..loadDefaultConfig(),
        ),
      ],
      child: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  Timer? _autoSaveTimer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (previous, current) =>
          previous.isDirty != current.isDirty ||
          previous.tree?.filePath != current.tree?.filePath,
      listener: (context, state) {
        // Cancel existing timer
        _autoSaveTimer?.cancel();

        // Auto-save after 2 seconds of inactivity when dirty
        if (state.isDirty && state.tree?.filePath != null) {
          _autoSaveTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              context.read<EditorBloc>().add(const SaveFile());
            }
          });
        }
      },
      child: MaterialApp(
        title: 'My Agenda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
