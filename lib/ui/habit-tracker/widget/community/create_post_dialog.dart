import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purewill/data/services/community_service.dart';

class CreatePostDialog extends StatefulWidget {
  final String communityId;
  final String userId;
  final String? initialContent;
  final String? initialImageUrl;
  final XFile? initialImage;
  final bool isEditing;
  final String? postId;
  final VoidCallback onPostCreated;

  const CreatePostDialog({
    super.key,
    required this.communityId,
    required this.userId,
    this.initialContent,
    this.initialImageUrl,
    this.initialImage,
    this.isEditing = false,
    this.postId,
    required this.onPostCreated,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialContent ?? '';
    _imageUrl = widget.initialImageUrl;
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _createOrUpdatePost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konten tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      if (widget.isEditing && widget.postId != null) {
        // Update existing post
        await _communityService.updatePost(
          postId: widget.postId!,
          content: _contentController.text,
          imageUrl: _imageUrl,
        );
      } else {
        // Create new post
        await _communityService.createPostWithImage(
          communityId: widget.communityId,
          userId: widget.userId,
          content: _contentController.text,
          imageFile: _selectedImage,
        );
      }

      widget.onPostCreated();
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEditing ? 'Edit Post' : 'Buat Post Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Apa yang ingin Anda bagikan?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null || _imageUrl != null)
                      _buildImagePreview(),
                    const SizedBox(height: 16),
                    _buildImagePickerButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _createOrUpdatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.isEditing ? 'Update' : 'Posting'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final image = _selectedImage ?? (_imageUrl != null ? null : null);
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: image != null
                ? DecorationImage(
                    image: image is XFile
                        ? FileImage(File(image.path))
                        : NetworkImage(_imageUrl!) as ImageProvider,
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey[200],
          ),
          child: image == null && _imageUrl != null
              ? Image.network(_imageUrl!, fit: BoxFit.cover)
              : null,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _imageUrl = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerButton() {
    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.image_outlined),
      label: const Text('Tambah Gambar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}