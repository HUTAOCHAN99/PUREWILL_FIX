// lib\ui\habit-tracker\screen\community_detail_screen.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/community_service.dart';
import 'package:purewill/domain/model/community_model.dart';
import 'package:purewill/ui/habit-tracker/widget/community/post_card.dart';
import 'package:purewill/ui/habit-tracker/widget/community/create_post_dialog.dart';
import 'package:purewill/ui/habit-tracker/widget/community/comments_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider untuk post dalam komunitas
final communityPostsProvider = StreamProvider.autoDispose.family<List<CommunityPost>, String>((ref, communityId) async* {
  final communityService = CommunityService();
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    yield [];
    return;
  }

  yield* communityService.streamCommunityPosts(communityId, user.id);
});

final communityDetailsProvider = FutureProvider.autoDispose.family<Community, String>((ref, communityId) async {
  final communityService = CommunityService();
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  return await communityService.getCommunityDetails(communityId, user.id);
});

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityDetailScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final CommunityService _communityService = CommunityService();
  late String _currentUserId;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        communityId: widget.communityId,
        userId: _currentUserId,
        onPostCreated: () {
          // Refresh posts
          ref.invalidate(communityPostsProvider(widget.communityId));
        },
      ),
    );
  }

  void _showComments(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: post.id,
          communityName: widget.communityName,
        ),
      ),
    );
  }

  Future<void> _toggleLikePost(CommunityPost post) async {
    try {
      await _communityService.toggleLikePost(post.id, _currentUserId);
      // Stream akan otomatis update karena ada perubahan di database
    } catch (e) {
      log('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPostOptions(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Laporkan Post'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(post);
              },
            ),
            if (post.authorId == _currentUserId) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Post', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(post);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Salin Link'),
              onTap: () {
                Navigator.pop(context);
                _copyPostLink(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(CommunityPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Post'),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _communityService.deletePost(post.id);
        // Stream akan otomatis update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        log('Error deleting post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportDialog(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Post'),
        content: const Text('Terima kasih telah melaporkan. Tim kami akan meninjau laporan ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPost(CommunityPost post) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        communityId: widget.communityId,
        userId: _currentUserId,
        initialContent: post.content,
        initialImageUrl: post.imageUrl,
        isEditing: true,
        postId: post.id,
        onPostCreated: () {
          ref.invalidate(communityPostsProvider(widget.communityId));
        },
      ),
    );

    if (result == true) {
      // Stream akan otomatis update
    }
  }

  void _copyPostLink(CommunityPost post) {
    // In real app, you would copy the link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link disalin ke clipboard')),
    );
  }

  Future<void> _joinCommunity() async {
    if (_currentUserId.isEmpty) return;
    
    setState(() => _isJoining = true);
    try {
      final success = await _communityService.joinCommunity(
        widget.communityId,
        _currentUserId,
      );
      
      if (success) {
        // Refresh community details
        ref.invalidate(communityDetailsProvider(widget.communityId));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil bergabung dengan komunitas!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Error joining community: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  Future<void> _leaveCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Komunitas'),
        content: const Text('Apakah Anda yakin ingin keluar dari komunitas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _communityService.leaveCommunity(
          widget.communityId,
          _currentUserId,
        );
        
        if (success) {
          // Refresh community details
          ref.invalidate(communityDetailsProvider(widget.communityId));
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil keluar dari komunitas'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        log('Error leaving community: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildJoinButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: _isJoining ? null : _joinCommunity,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isJoining
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Bergabung dengan Komunitas',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildCommunityHeader(Community community) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            community.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (community.description != null) ...[
            const SizedBox(height: 8),
            Text(
              community.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${community.memberCount} anggota',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.category, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                community.category?.name ?? 'General',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          if (!community.isJoined) const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMember) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada post',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMember 
              ? 'Jadilah yang pertama membuat post!'
              : 'Bergabunglah untuk melihat dan membuat post',
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (isMember) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreatePostDialog,
              icon: const Icon(Icons.add),
              label: const Text('Buat Post Pertama'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(communityDetailsProvider(widget.communityId));
    final postsAsync = ref.watch(communityPostsProvider(widget.communityId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.communityName),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (communityAsync.hasValue && communityAsync.value!.isJoined)
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Keluar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'leave') {
                _leaveCommunity();
              }
            },
          ),
        ],
      ),
      body: communityAsync.when(
        data: (community) {
          return Column(
            children: [
              _buildCommunityHeader(community),
              if (!community.isJoined) _buildJoinButton(),
              Expanded(
                child: postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return _buildEmptyState(community.isJoined);
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(communityPostsProvider(widget.communityId));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Column(
                            children: [
                              PostCard(
                                post: post,
                                userId: _currentUserId,
                                onLikeToggled: () => _toggleLikePost(post),
                                onCommentTapped: () => _showComments(post),
                                onShareTapped: () {}, // TODO: Implement share
                                onMoreTapped: () => _showPostOptions(post),
                              ),
                              if (index < posts.length - 1)
                                const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Gagal memuat post',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat detail komunitas',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(communityDetailsProvider(widget.communityId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: communityAsync.when(
        data: (community) => community.isJoined
            ? FloatingActionButton.extended(
                onPressed: _showCreatePostDialog,
                icon: const Icon(Icons.add),
                label: const Text('Post'),
                backgroundColor: Colors.blue,
              )
            : null,
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }
}