import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game/game_controller.dart';
import 'game/settings_cubit.dart';
import 'game/stats_cubit.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FourInARowApp());
}

class FourInARowApp extends StatelessWidget {
  const FourInARowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(),
        ),
        BlocProvider<StatsCubit>(
          create: (_) => StatsCubit(),
        ),
        BlocProvider<GameController>(
          create: (ctx) => GameController(
            statsCubit: ctx.read<StatsCubit>(),
          ),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final palette = settings.palette;

    return MaterialApp(
      title: 'FiarPixel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: palette.background,
        colorScheme: ColorScheme.dark(
          primary: palette.accent,
          secondary: palette.player2,
          surface: palette.surface,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
