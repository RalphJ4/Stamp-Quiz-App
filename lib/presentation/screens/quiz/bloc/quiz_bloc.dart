// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

export 'quiz_event.dart';
export 'quiz_state.dart';
import '../../../../domain/entities/question.dart';
import '../../../../data/datasources/local_question_datasource.dart';
import '../../../../data/repositories/question_repository_impl.dart';
import '../../../../domain/usecases/get_questions.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final LocalQuestionDataSource _local = LocalQuestionDataSource();
  late final GetQuestions _getQuestions;
  final AuthBloc _authBloc;
  Timer? _questionTimer;
  StreamSubscription<AuthState>? _authSubscription;

  QuizBloc(this._authBloc, {bool skipLoad = false}) : super(const QuizState()) {
    final repo = QuestionRepositoryImpl(local: _local);
    _getQuestions = GetQuestions(repo);

    on<QuizLoadQuestions>(_onLoadQuestions);
    on<QuizSelectCategory>(_onSelectCategory);
    on<QuizStartTimer>(_onStartTimer);
    on<QuizPauseTimer>(_onPauseTimer);
    on<QuizTimerTick>(_onTimerTick);
    on<QuizSelectOption>(_onSelectOption);
    on<QuizNextQuestion>(_onNextQuestion);
    on<QuizFinish>(_onFinish);
    on<QuizUseHint>(_onUseHint);
    on<QuizDeductStamps>(_onDeductStamps);
    on<QuizAwardStamps>(_onAwardStamps);
    on<QuizAddHint>(_onAddHint);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.initialized) {
        _loadStats();
      }
    });
    if (!skipLoad) {
      _loadStats();
    }
  }

  String get _storagePrefix {
    final user = _authBloc.state.user;
    if (user == null) return 'default';
    return '${user.isGuest ? 'guest' : 'user'}_${user.id}';
  }

  int questionCountForCategory(QuestionCategory category) {
    return _questionCounts[category] ?? 0;
  }

  List<CategoryStats> get allCategoryStats {
    return QuestionCategory.values.map((cat) {
      final count = state.allQuestions.where((q) => q.category == cat).length;
      return CategoryStats(category: cat.name, stamps: count);
    }).toList();
  }

  void _onLoadQuestions(QuizLoadQuestions event, Emitter<QuizState> emit) async {
    final allQuestions = await _getQuestions.execute();
    final filtered = allQuestions.where((q) => q.category == state.selectedCategory).toList();
    emit(state.copyWith(allQuestions: allQuestions, questions: filtered));
  }

  static const _questionCounts = {
    QuestionCategory.space: 8,
    QuestionCategory.animals: 6,
    QuestionCategory.history: 6,
    QuestionCategory.science: 6,
    QuestionCategory.geography: 6,
  };

  void _onSelectCategory(QuizSelectCategory event, Emitter<QuizState> emit) {
    _cancelTimer();
    var filtered = state.allQuestions.where((q) => q.category == event.category).toList();
    filtered.shuffle();
    final count = _questionCounts[event.category]!;
    filtered = filtered.take(min(count, filtered.length)).toList();
    emit(state.copyWith(
      selectedCategory: event.category,
      questions: filtered,
      currentIndex: 0,
      answered: false,
      clearSelectedOption: true,
      animateStamp: false,
      isQuizFinished: false,
      quizStarted: false,
      hintsRemaining: 3,
      usedHint: false,
      eliminatedOptions: {},
      remainingSeconds: 30,
    ));
    add(QuizStartTimer());
  }

  void _onStartTimer(QuizStartTimer event, Emitter<QuizState> emit) {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(QuizTimerTick());
    });
  }

  void _onPauseTimer(QuizPauseTimer event, Emitter<QuizState> emit) {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _onTimerTick(QuizTimerTick event, Emitter<QuizState> emit) {
    final newRemaining = state.remainingSeconds - 1;
    emit(state.copyWith(remainingSeconds: newRemaining));
    if (newRemaining <= 0) {
      _questionTimer?.cancel();
      if (!state.answered) {
        if (state.currentIndex < state.questions.length - 1) {
          add(QuizNextQuestion());
        } else {
          add(QuizFinish());
        }
      }
    }
  }

  void _cancelTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _onSelectOption(QuizSelectOption event, Emitter<QuizState> emit) {
    if (state.answered) return;
    _cancelTimer();
    var newStamps = state.stamps;
    var newStreak = state.currentStreak;
    var newBestStreak = state.bestStreak;
    var newTotalCorrect = state.totalCorrect;
    var newTotalAnswered = state.totalAnswered + 1;
    var newAnimateStamp = false;

    if (state.questions[state.currentIndex].correctIndex == event.index) {
      var reward = state.questions[state.currentIndex].stampReward;
      if (state.usedHint) reward = max(reward ~/ 2, 1);
      newStamps += reward;
      newStreak++;
      if (newStreak > newBestStreak) {
        newBestStreak = newStreak;
      }
      newTotalCorrect++;
      newAnimateStamp = true;
      _saveStatsSilent(newStamps, newBestStreak, newTotalCorrect, newTotalAnswered);
    } else {
      newStreak = 0;
    }

    emit(state.copyWith(
      selectedOption: event.index,
      answered: true,
      stamps: newStamps,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      totalCorrect: newTotalCorrect,
      totalAnswered: newTotalAnswered,
      animateStamp: newAnimateStamp,
    ));
  }

  void _onNextQuestion(QuizNextQuestion event, Emitter<QuizState> emit) {
    if (state.currentIndex < state.questions.length - 1) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        answered: false,
        clearSelectedOption: true,
        animateStamp: false,
        usedHint: false,
        eliminatedOptions: {},
        remainingSeconds: 30,
      ));
      add(QuizStartTimer());
    }
  }

  void _onFinish(QuizFinish event, Emitter<QuizState> emit) {
    _cancelTimer();
    emit(state.copyWith(isQuizFinished: true));
  }

  static const int hintCost = 5;

  void _onUseHint(QuizUseHint event, Emitter<QuizState> emit) {
    if (state.hintsRemaining <= 0 || state.answered) return;
    if (state.stamps < hintCost) return;

    final correctIdx = state.questions[state.currentIndex].correctIndex;
    final wrongIndices = List.generate(state.questions[state.currentIndex].options.length, (i) => i)
        .where((i) => i != correctIdx)
        .toList();
    wrongIndices.shuffle();
    final eliminated = wrongIndices.take(min(2, wrongIndices.length)).toSet();
    final newStamps = state.stamps - hintCost;

    emit(state.copyWith(
      stamps: newStamps,
      hintsRemaining: state.hintsRemaining - 1,
      usedHint: true,
      eliminatedOptions: eliminated,
    ));
    _saveStatsSilent(newStamps, state.bestStreak, state.totalCorrect, state.totalAnswered);
  }

  void _onDeductStamps(QuizDeductStamps event, Emitter<QuizState> emit) {
    final newStamps = max(state.stamps - event.amount, 0);
    emit(state.copyWith(stamps: newStamps));
    _saveStatsSilent(newStamps, state.bestStreak, state.totalCorrect, state.totalAnswered);
  }

  void _onAwardStamps(QuizAwardStamps event, Emitter<QuizState> emit) {
    final newStamps = state.stamps + event.amount;
    emit(state.copyWith(stamps: newStamps));
    _saveStatsSilent(newStamps, state.bestStreak, state.totalCorrect, state.totalAnswered);
  }

  void _onAddHint(QuizAddHint event, Emitter<QuizState> emit) {
    emit(state.copyWith(hintsRemaining: state.hintsRemaining + 1));
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    if (_authBloc.state.isLoggedIn) {
      final uid = _authBloc.state.user?.id;
      if (uid != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (doc.exists && doc.data()!.containsKey('stamps')) {
            emit(state.copyWith(
              stamps: (doc.data()!['stamps'] as num?)?.toInt() ?? 0,
              bestStreak: (doc.data()!['bestStreak'] as num?)?.toInt() ?? 0,
              totalCorrect: (doc.data()!['totalCorrect'] as num?)?.toInt() ?? 0,
              totalAnswered: (doc.data()!['totalAnswered'] as num?)?.toInt() ?? 0,
            ));
            return;
          }
        } catch (_) {}
      }
    }

    final bestStreak = prefs.getInt('${_storagePrefix}_bestStreak') ?? 0;
    final totalCorrect = prefs.getInt('${_storagePrefix}_totalCorrect') ?? 0;
    final totalAnswered = prefs.getInt('${_storagePrefix}_totalAnswered') ?? 0;
    var stamps = prefs.getInt('${_storagePrefix}_stamps') ?? 0;

    if (stamps <= 0 && _authBloc.state.isLoggedIn) {
      final guestId = prefs.getString('guest_session_id');
      if (guestId != null && guestId.isNotEmpty) {
        final guestPrefix = 'guest_$guestId';
        final guestStamps = prefs.getInt('${guestPrefix}_stamps') ?? 0;
        if (guestStamps > 0) {
          stamps = guestStamps;
          emit(state.copyWith(
            stamps: stamps,
            bestStreak: prefs.getInt('${guestPrefix}_bestStreak') ?? 0,
            totalCorrect: prefs.getInt('${guestPrefix}_totalCorrect') ?? 0,
            totalAnswered: prefs.getInt('${guestPrefix}_totalAnswered') ?? 0,
          ));
          _saveStatsSilent(stamps, state.bestStreak, state.totalCorrect, state.totalAnswered);
          return;
        }
      }
    }

    emit(state.copyWith(
      stamps: stamps,
      bestStreak: bestStreak,
      totalCorrect: totalCorrect,
      totalAnswered: totalAnswered,
    ));
  }

  void _saveStatsSilent(int stamps, int bestStreak, int totalCorrect, int totalAnswered) {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setInt('${_storagePrefix}_stamps', stamps);
      await prefs.setInt('${_storagePrefix}_bestStreak', bestStreak);
      await prefs.setInt('${_storagePrefix}_totalCorrect', totalCorrect);
      await prefs.setInt('${_storagePrefix}_totalAnswered', totalAnswered);

      if (_authBloc.state.isLoggedIn) {
        final uid = _authBloc.state.user?.id;
        if (uid != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'stamps': stamps,
              'bestStreak': bestStreak,
              'totalCorrect': totalCorrect,
              'totalAnswered': totalAnswered,
            }, SetOptions(merge: true));
          } catch (_) {}
        }
      }
    });
  }

  @override
  Future<void> close() {
    _cancelTimer();
    _authSubscription?.cancel();
    return super.close();
  }
}
