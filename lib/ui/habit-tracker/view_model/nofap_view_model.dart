import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/data/services/nofap/nofap_session_api_service.dart';
import 'package:purewill/domain/model/nofap_session_model.dart';

enum NofapStatus { initial, loading, success, failure }

class NofapState {
  final NofapStatus status;
  final String? errorMessage;
  final NofapSessionModel? currentSession;
  final List<NofapSessionModel> meSessions;
  final String motivationalQuote;
  final List<String> benefits;

  const NofapState({
    this.status = NofapStatus.initial,
    this.errorMessage,
    this.currentSession,
    this.meSessions = const [],
    this.motivationalQuote =
        'The greatest victory is that which requires no battle. - Sun Tzu',
    this.benefits = const [
      'Increased energy and motivation',
      'Better focus and concentration',
      'Improved self-confidence',
      'Better sleep quality',
      'Enhanced social interactions',
    ],
  });

  bool get isHabitStarted => currentSession?.isActive == true;

  int get currentStreak {
    final session = currentSession;
    if (session == null || !session.isActive) return 0;

    return _dateOnly(
      DateTime.now(),
    ).difference(_dateOnly(session.startDate)).inDays;
  }

  // NOTE: GET /api/me/nofap-sessions saat ini mengembalikan satu session,
  // bukan history. Karena desain backend unique per user, statistik historis
  // maksimal yang bisa dihitung adalah dari satu record session tersebut.
  int get longestStreak {
    final sessions = meSessions.isNotEmpty
        ? meSessions
        : [if (currentSession != null) currentSession!];

    var longest = 0;
    for (final session in sessions) {
      final endDate = session.endDate ?? DateTime.now();
      final days = _dateOnly(
        endDate,
      ).difference(_dateOnly(session.startDate)).inDays;
      if (days > longest) {
        longest = days;
      }
    }

    return longest;
  }

  int get totalRelapses {
    return meSessions.where((session) => session.endDate != null).length;
  }

  List<DateTime> get successDays {
    final session = currentSession;
    if (session == null || !session.isActive) return const [];

    final now = _dateOnly(DateTime.now());
    var cursor = _dateOnly(session.startDate);
    final days = <DateTime>[];

    while (!cursor.isAfter(now)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    return days;
  }

  NofapState copyWith({
    NofapStatus? status,
    String? errorMessage,
    NofapSessionModel? currentSession,
    List<NofapSessionModel>? meSessions,
    bool clearCurrentSession = false,
  }) {
    return NofapState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentSession: clearCurrentSession
          ? null
          : currentSession ?? this.currentSession,
      meSessions: meSessions ?? this.meSessions,
      motivationalQuote: motivationalQuote,
      benefits: benefits,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class NofapViewModel extends StateNotifier<NofapState> {
  final NofapSessionApiService _apiService;
  final MeApiService _meApiService;

  NofapViewModel(this._apiService, this._meApiService)
    : super(const NofapState());

  Future<void> loadCurrentSession() async {
    state = state.copyWith(status: NofapStatus.loading, errorMessage: null);

    try {
      final currentResponse = await _apiService.getCurrentSession();
      final currentData = currentResponse['data'];
      final meSessions = await _loadMeSessions();

      state = state.copyWith(
        status: NofapStatus.success,
        currentSession: currentData is Map<String, dynamic>
            ? NofapSessionModel.fromJson(currentData)
            : null,
        meSessions: meSessions,
        clearCurrentSession: currentData == null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NofapStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> startSession() async {
    state = state.copyWith(status: NofapStatus.loading, errorMessage: null);

    try {
      final response = await _apiService.createSession();
      final data = response['data'];
      final session = data is Map<String, dynamic>
          ? NofapSessionModel.fromJson(data)
          : null;

      state = state.copyWith(
        status: NofapStatus.success,
        currentSession: session,
        meSessions: [if (session != null) session],
        clearCurrentSession: session == null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NofapStatus.failure,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> stopCurrentSession({String? relapseNotes}) async {
    state = state.copyWith(status: NofapStatus.loading, errorMessage: null);

    try {
      final response = await _apiService.updateCurrentSession(
        endDate: DateTime.now(),
        relapseNotes: relapseNotes,
      );
      final data = response['data'];
      final stoppedSession = data is Map<String, dynamic>
          ? NofapSessionModel.fromJson(data)
          : null;
      final meSessions = await _loadMeSessions();

      state = state.copyWith(
        status: NofapStatus.success,
        meSessions: meSessions.isNotEmpty
            ? meSessions
            : [if (stoppedSession != null) stoppedSession],
        clearCurrentSession: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: NofapStatus.failure,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<List<NofapSessionModel>> _loadMeSessions() async {
    final response = await _meApiService.getMeNofapSessions();
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return [NofapSessionModel.fromJson(data)];
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (json) =>
                NofapSessionModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    return const [];
  }
}
