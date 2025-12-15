import 'package:flutter/material.dart';
import 'package:purewill/data/services/community_service.dart';
import 'package:purewill/domain/model/community_model.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String communityName;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.communityName,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final String _currentUserId = ''; // TODO: Get from auth

  List<CommunityComment> _comments = [];
  bool _isLoading = true;
  String? _replyingToCommentId;
  String? _replyingToUserName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _communityService.getPostComments(
        widget.postId,
        userId: _currentUserId,
      );
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = await _communityService.addComment(
        postId: widget.postId,
        userId: _currentUserId,
        content: _commentController.text,
        parentCommentId: _replyingToCommentId,
      );

      setState(() {
        if (_replyingToCommentId != null) {
          // Add as reply
          final parentIndex = _comments.indexWhere(
            (c) => c.id == _replyingToCommentId,
          );
          if (parentIndex != -1) {
            final parentComment = _comments[parentIndex];
            final updatedReplies = <CommunityComment>[
              ...(parentComment.replies ?? []),
              comment,
            ];
            _comments[parentIndex] = parentComment.copyWith(
              replies: updatedReplies,
              replyCount: updatedReplies.length,
            );
          }
        } else {
          // Add as top-level comment
          _comments.insert(0, comment);
        }
        _commentController.clear();
        _replyingToCommentId = null;
        _replyingToUserName = null;
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  void _setReplyingTo(CommunityComment? comment) {
    setState(() {
      _replyingToCommentId = comment?.id;
      _replyingToUserName = comment?.author?.fullName;
      if (comment != null) {
        _commentController.text = '@${comment.author?.fullName ?? 'User'} ';
      } else {
        _commentController.clear();
      }
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget _buildCommentItem(CommunityComment comment, {bool isReply = false}) {
    return Container(
      margin: EdgeInsets.only(left: isReply ? 32 : 0, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: comment.author?.avatarUrl != null
                    ? NetworkImage(comment.author!.avatarUrl!)
                    : null,
                child: comment.author?.avatarUrl == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.author?.fullName ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  comment.isLikedByUser == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 16,
                  color: comment.isLikedByUser == true
                      ? Colors.red
                      : Colors.grey,
                ),
                onPressed: () {},
              ),
              Text(
                comment.likesCount > 0 ? comment.likesCount.toString() : '',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => _setReplyingTo(comment),
                child: const Text('Reply', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (comment.hasReplies) ...[
            const SizedBox(height: 12),
            ...(comment.replies ?? []).map(
              (reply) => _buildCommentItem(reply, isReply: true),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komentar')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Center(child: Text('Belum ada komentar'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(_comments[index]);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                if (_replyingToUserName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Membalas @$_replyingToUserName',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _setReplyingTo(null),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
