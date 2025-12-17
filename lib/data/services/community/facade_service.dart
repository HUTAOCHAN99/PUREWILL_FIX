import 'dart:io';
import 'package:purewill/data/services/community/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purewill/domain/model/community_model.dart';

// Facade untuk menyederhanakan penggunaan service
class CommunityFacadeService {
  final CommunityService _communityService;
  final PostService _postService;
  final CommentService _commentService;
  final ImageService _imageService;
  final ProfileService _profileService;

  CommunityFacadeService({
    required CommunityService communityService,
    required PostService postService,
    required CommentService commentService,
    required ImageService imageService,
    required ProfileService profileService,
  })  : _communityService = communityService,
        _postService = postService,
        _commentService = commentService,
        _imageService = imageService,
        _profileService = profileService;

  // ============ FACADE METHODS ============

  // Komunitas
  Future<List<Community>> getCommunities(String userId) =>
      _communityService.getCommunities(userId);

  Future<Community> getCommunityDetails(String communityId, String userId) =>
      _communityService.getCommunityDetails(communityId, userId);

  Future<bool> joinCommunity(String communityId, String userId) =>
      _communityService.joinCommunity(communityId, userId);

  Future<bool> leaveCommunity(String communityId, String userId) =>
      _communityService.leaveCommunity(communityId, userId);

  // Post
  Future<List<CommunityPost>> getCommunityPosts(
    String communityId, {
    String? userId,
  }) =>
      _postService.getCommunityPosts(communityId, userId: userId);

  Future<CommunityPost> createPostWithImage({
    required String communityId,
    required String userId,
    required String content,
    XFile? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      final file = File(imageFile.path);
      if (!await file.exists()) {
        throw Exception('Image file tidak ditemukan');
      }

      imageUrl = await _imageService.uploadImage(file, userId);
    }

    return _postService.createPost(
      communityId: communityId,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  Future<bool> toggleLikePost(String postId, String userId) =>
      _postService.toggleLikePost(postId, userId);

  // Komentar
  Future<CommunityComment> addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) =>
      _commentService.addComment(
        postId: postId,
        userId: userId,
        content: content,
        parentCommentId: parentCommentId,
      );

  Future<List<CommunityComment>> getPostComments(
    String postId, {
    String? userId,
  }) =>
      _commentService.getPostComments(postId, userId: userId);

  // Gambar
  Future<XFile?> pickImage() => _imageService.pickImage();

  // Profile
  Future<Profile?> getUserProfile(String userId) =>
      _profileService.getUserProfile(userId);
}