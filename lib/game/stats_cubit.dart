import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class StatsState {
  final int totalGamesPlayed;
  final int pvpPlayer1Wins;
  final int pvpPlayer2Wins;
  final int pvpDraws;
  final int aiEasyWins;
  final int aiEasyLosses;
  final int aiEasyDraws;
  final int aiNormalWins;
  final int aiNormalLosses;
  final int aiNormalDraws;
  final int aiHardWins;
  final int aiHardLosses;
  final int aiHardDraws;
  final bool isLoading;

  const StatsState({
    this.totalGamesPlayed = 0,
    this.pvpPlayer1Wins = 0,
    this.pvpPlayer2Wins = 0,
    this.pvpDraws = 0,
    this.aiEasyWins = 0,
    this.aiEasyLosses = 0,
    this.aiEasyDraws = 0,
    this.aiNormalWins = 0,
    this.aiNormalLosses = 0,
    this.aiNormalDraws = 0,
    this.aiHardWins = 0,
    this.aiHardLosses = 0,
    this.aiHardDraws = 0,
    this.isLoading = false,
  });

  int get totalAiWins => aiEasyWins + aiNormalWins + aiHardWins;
  int get totalAiLosses => aiEasyLosses + aiNormalLosses + aiHardLosses;
  int get totalAiDraws => aiEasyDraws + aiNormalDraws + aiHardDraws;
  int get totalAiGames => totalAiWins + totalAiLosses + totalAiDraws;

  double get overallWinRate =>
      totalAiGames == 0 ? 0.0 : (totalAiWins / totalAiGames) * 100.0;

  double get easyWinRate => (aiEasyWins + aiEasyLosses + aiEasyDraws) == 0
      ? 0.0
      : (aiEasyWins / (aiEasyWins + aiEasyLosses + aiEasyDraws)) * 100.0;

  double get normalWinRate => (aiNormalWins + aiNormalLosses + aiNormalDraws) == 0
      ? 0.0
      : (aiNormalWins / (aiNormalWins + aiNormalLosses + aiNormalDraws)) * 100.0;

  double get hardWinRate => (aiHardWins + aiHardLosses + aiHardDraws) == 0
      ? 0.0
      : (aiHardWins / (aiHardWins + aiHardLosses + aiHardDraws)) * 100.0;

  StatsState copyWith({
    int? totalGamesPlayed,
    int? pvpPlayer1Wins,
    int? pvpPlayer2Wins,
    int? pvpDraws,
    int? aiEasyWins,
    int? aiEasyLosses,
    int? aiEasyDraws,
    int? aiNormalWins,
    int? aiNormalLosses,
    int? aiNormalDraws,
    int? aiHardWins,
    int? aiHardLosses,
    int? aiHardDraws,
    bool? isLoading,
  }) {
    return StatsState(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      pvpPlayer1Wins: pvpPlayer1Wins ?? this.pvpPlayer1Wins,
      pvpPlayer2Wins: pvpPlayer2Wins ?? this.pvpPlayer2Wins,
      pvpDraws: pvpDraws ?? this.pvpDraws,
      aiEasyWins: aiEasyWins ?? this.aiEasyWins,
      aiEasyLosses: aiEasyLosses ?? this.aiEasyLosses,
      aiEasyDraws: aiEasyDraws ?? this.aiEasyDraws,
      aiNormalWins: aiNormalWins ?? this.aiNormalWins,
      aiNormalLosses: aiNormalLosses ?? this.aiNormalLosses,
      aiNormalDraws: aiNormalDraws ?? this.aiNormalDraws,
      aiHardWins: aiHardWins ?? this.aiHardWins,
      aiHardLosses: aiHardLosses ?? this.aiHardLosses,
      aiHardDraws: aiHardDraws ?? this.aiHardDraws,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  static const String _keyTotalGames = 'stats_total_games';
  static const String _keyPvpP1 = 'stats_pvp_p1';
  static const String _keyPvpP2 = 'stats_pvp_p2';
  static const String _keyPvpDraw = 'stats_pvp_draw';

  static const String _keyAiEasyW = 'stats_ai_easy_w';
  static const String _keyAiEasyL = 'stats_ai_easy_l';
  static const String _keyAiEasyD = 'stats_ai_easy_d';

  static const String _keyAiNormalW = 'stats_ai_normal_w';
  static const String _keyAiNormalL = 'stats_ai_normal_l';
  static const String _keyAiNormalD = 'stats_ai_normal_d';

  static const String _keyAiHardW = 'stats_ai_hard_w';
  static const String _keyAiHardL = 'stats_ai_hard_l';
  static const String _keyAiHardD = 'stats_ai_hard_d';

  StatsCubit() : super(const StatsState(isLoading: true)) {
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    emit(
      StatsState(
        totalGamesPlayed: prefs.getInt(_keyTotalGames) ?? 0,
        pvpPlayer1Wins: prefs.getInt(_keyPvpP1) ?? 0,
        pvpPlayer2Wins: prefs.getInt(_keyPvpP2) ?? 0,
        pvpDraws: prefs.getInt(_keyPvpDraw) ?? 0,
        aiEasyWins: prefs.getInt(_keyAiEasyW) ?? 0,
        aiEasyLosses: prefs.getInt(_keyAiEasyL) ?? 0,
        aiEasyDraws: prefs.getInt(_keyAiEasyD) ?? 0,
        aiNormalWins: prefs.getInt(_keyAiNormalW) ?? 0,
        aiNormalLosses: prefs.getInt(_keyAiNormalL) ?? 0,
        aiNormalDraws: prefs.getInt(_keyAiNormalD) ?? 0,
        aiHardWins: prefs.getInt(_keyAiHardW) ?? 0,
        aiHardLosses: prefs.getInt(_keyAiHardL) ?? 0,
        aiHardDraws: prefs.getInt(_keyAiHardD) ?? 0,
        isLoading: false,
      ),
    );
  }

  Future<void> recordGameEnd({
    required GameMode mode,
    required AIDifficulty difficulty,
    required int? winner,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int total = state.totalGamesPlayed + 1;
    await prefs.setInt(_keyTotalGames, total);

    if (mode == GameMode.pvp) {
      if (winner == 1) {
        final val = state.pvpPlayer1Wins + 1;
        await prefs.setInt(_keyPvpP1, val);
        emit(state.copyWith(totalGamesPlayed: total, pvpPlayer1Wins: val));
      } else if (winner == 2) {
        final val = state.pvpPlayer2Wins + 1;
        await prefs.setInt(_keyPvpP2, val);
        emit(state.copyWith(totalGamesPlayed: total, pvpPlayer2Wins: val));
      } else {
        final val = state.pvpDraws + 1;
        await prefs.setInt(_keyPvpDraw, val);
        emit(state.copyWith(totalGamesPlayed: total, pvpDraws: val));
      }
    } else {
      // vs AI mode: Player 1 is human, Player 2 is AI
      if (winner == 1) {
        switch (difficulty) {
          case AIDifficulty.easy:
            final val = state.aiEasyWins + 1;
            await prefs.setInt(_keyAiEasyW, val);
            emit(state.copyWith(totalGamesPlayed: total, aiEasyWins: val));
            break;
          case AIDifficulty.normal:
            final val = state.aiNormalWins + 1;
            await prefs.setInt(_keyAiNormalW, val);
            emit(state.copyWith(totalGamesPlayed: total, aiNormalWins: val));
            break;
          case AIDifficulty.hard:
            final val = state.aiHardWins + 1;
            await prefs.setInt(_keyAiHardW, val);
            emit(state.copyWith(totalGamesPlayed: total, aiHardWins: val));
            break;
        }
      } else if (winner == 2) {
        switch (difficulty) {
          case AIDifficulty.easy:
            final val = state.aiEasyLosses + 1;
            await prefs.setInt(_keyAiEasyL, val);
            emit(state.copyWith(totalGamesPlayed: total, aiEasyLosses: val));
            break;
          case AIDifficulty.normal:
            final val = state.aiNormalLosses + 1;
            await prefs.setInt(_keyAiNormalL, val);
            emit(state.copyWith(totalGamesPlayed: total, aiNormalLosses: val));
            break;
          case AIDifficulty.hard:
            final val = state.aiHardLosses + 1;
            await prefs.setInt(_keyAiHardL, val);
            emit(state.copyWith(totalGamesPlayed: total, aiHardLosses: val));
            break;
        }
      } else {
        switch (difficulty) {
          case AIDifficulty.easy:
            final val = state.aiEasyDraws + 1;
            await prefs.setInt(_keyAiEasyD, val);
            emit(state.copyWith(totalGamesPlayed: total, aiEasyDraws: val));
            break;
          case AIDifficulty.normal:
            final val = state.aiNormalDraws + 1;
            await prefs.setInt(_keyAiNormalD, val);
            emit(state.copyWith(totalGamesPlayed: total, aiNormalDraws: val));
            break;
          case AIDifficulty.hard:
            final val = state.aiHardDraws + 1;
            await prefs.setInt(_keyAiHardD, val);
            emit(state.copyWith(totalGamesPlayed: total, aiHardDraws: val));
            break;
        }
      }
    }
  }

  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTotalGames);
    await prefs.remove(_keyPvpP1);
    await prefs.remove(_keyPvpP2);
    await prefs.remove(_keyPvpDraw);
    await prefs.remove(_keyAiEasyW);
    await prefs.remove(_keyAiEasyL);
    await prefs.remove(_keyAiEasyD);
    await prefs.remove(_keyAiNormalW);
    await prefs.remove(_keyAiNormalL);
    await prefs.remove(_keyAiNormalD);
    await prefs.remove(_keyAiHardW);
    await prefs.remove(_keyAiHardL);
    await prefs.remove(_keyAiHardD);

    emit(const StatsState());
  }
}
