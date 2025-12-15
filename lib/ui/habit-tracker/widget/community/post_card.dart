import 'package:flutter/material.dart';
import 'package:purewill/domain/model/community_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final String userId;
  final VoidCallback onLikeToggled;
  final VoidCallback onCommentTapped;
  final VoidCallback onShareTapped;
  final VoidCallback onMoreTapped;

  const PostCard({
    super.key,
    required this.post,
    required this.userId,
    required this.onLikeToggled,
    required this.onCommentTapped,
    required this.onShareTapped,
    required this.onMoreTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with author info
            _buildHeader(),
            const SizedBox(height: 12),
            
            // Post content
            if (post.content.isNotEmpty) _buildContent(),
            if (post.hasImage) _buildImage(),
            if (post.isShared) _buildSharedIndicator(),
            
            // Stats and actions
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: post.author?.avatarUrl != null
              ? NetworkImage(post.author!.avatarUrl!)
              : null,
          child: post.author?.avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey[600],
                )
              : null,
        ),
        const SizedBox(width: 12),
        
        // Author info and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author?.fullName ?? 'Anonymous',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    timeago.format(post.createdAt, locale: 'id'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (post.isEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• Edited',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // More options button
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: onMoreTapped,
          color: Colors.grey[600],
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        post.content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
        ),
        child: Image.network(
          post.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSharedIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Shared from another community',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        if (post.likesCount > 0) ...[
          Icon(
            Icons.favorite,
            size: 16,
            color: Colors.red[400],
          ),
          const SizedBox(width: 4),
          Text(
            _formatNumber(post.likesCount),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (post.commentsCount > 0) ...[
          Icon(
            Icons.comment,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            _formatNumber(post.commentsCount),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (post.shareCount > 0) ...[
          Icon(
            Icons.share,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            _formatNumber(post.shareCount),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const Spacer(),
        Text(
          '${post.viewCount} views',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Like button
          Expanded(
            child: TextButton.icon(
              onPressed: onLikeToggled,
              icon: Icon(
                post.isLikedByUser == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: post.isLikedByUser == true ? Colors.red : Colors.grey[600],
                size: 20,
              ),
              label: Text(
                'Like',
                style: TextStyle(
                  color: post.isLikedByUser == true ? Colors.red : Colors.grey[600],
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Comment button
          Expanded(
            child: TextButton.icon(
              onPressed: onCommentTapped,
              icon: Icon(
                Icons.comment_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              label: const Text(
                'Comment',
                style: TextStyle(color: Colors.grey),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Share button
          Expanded(
            child: TextButton.icon(
              onPressed: onShareTapped,
              icon: Icon(
                Icons.share_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              label: const Text(
                'Share',
                style: TextStyle(color: Colors.grey),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}