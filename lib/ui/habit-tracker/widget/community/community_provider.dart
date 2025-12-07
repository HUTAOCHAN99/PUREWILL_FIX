// lib\ui\habit-tracker\community_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/community_service.dart';
import 'package:purewill/domain/model/community_model.dart';

final communityServiceProvider = Provider((ref) => CommunityService());

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>(
  (ref) => CommunityNotifier(ref.read(communityServiceProvider)),
);

class CommunityState {
  final List<Community> communities;
  final List<Community> userCommunities;
  final bool isLoading;
  final String? error;
  final Map<String, List<CommunityPost>> communityPosts;

  CommunityState({
    this.communities = const [],
    this.userCommunities = const [],
    this.isLoading = false,
    this.error,
    this.communityPosts = const {},
  });

  CommunityState copyWith({
    List<Community>? communities,
    List<Community>? userCommunities,
    bool? isLoading,
    String? error,
    Map<String, List<CommunityPost>>? communityPosts,
  }) {
    return CommunityState(
      communities: communities ?? this.communities,
      userCommunities: userCommunities ?? this.userCommunities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      communityPosts: communityPosts ?? this.communityPosts,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityService _communityService;
  String? _currentUserId;

  CommunityNotifier(this._communityService) : super(CommunityState());

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> loadCommunities() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final communities = await _communityService.getCommunities(_currentUserId!);
      final userCommunities = communities.where((c) => c.isJoined).toList();

      state = state.copyWith(
        communities: communities,
        userCommunities: userCommunities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load communities: $e',
        isLoading: false,
      );
    }
  }

  Future<void> joinCommunity(String communityId) async {
    if (_currentUserId == null) return;

    try {
      final success = await _communityService.joinCommunity(
        communityId,
        _currentUserId!,
      );

      if (success) {
        // Update local state
        final updatedCommunities = state.communities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(isJoined: true);
          }
          return community;
        }).toList();

        final updatedUserCommunities = updatedCommunities
            .where((c) => c.isJoined)
            .toList();

        state = state.copyWith(
          communities: updatedCommunities,
          userCommunities: updatedUserCommunities,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to join community: $e');
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    if (_currentUserId == null) return;

    try {
      final success = await _communityService.leaveCommunity(
        communityId,
        _currentUserId!,
      );

      if (success) {
        // Update local state
        final updatedCommunities = state.communities.map((community) {
          if (community.id == communityId) {
            return community.copyWith(isJoined: false);
          }
          return community;
        }).toList();

        final updatedUserCommunities = updatedCommunities
            .where((c) => c.isJoined)
            .toList();

        state = state.copyWith(
          communities: updatedCommunities,
          userCommunities: updatedUserCommunities,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to leave community: $e');
    }
  }

  Future<void> loadCommunityPosts(String communityId) async {
    try {
      final posts = await _communityService.getCommunityPosts(communityId);
      final updatedPosts = Map<String, List<CommunityPost>>.from(state.communityPosts);
      updatedPosts[communityId] = posts;

      state = state.copyWith(communityPosts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load posts: $e');
    }
  }

  Future<void> refresh() async {
    if (_currentUserId != null) {
      await loadCommunities();
    }
  }
}