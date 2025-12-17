import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purewill/data/services/community/image_service.dart';
import 'package:purewill/data/services/community/post_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class _CreatePostDialogState extends State<CreatePostDialog>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final ImageService _imageService = ImageService();
  final PostService _postService = PostService();
  final SupabaseClient _supabase = Supabase.instance.client;

  XFile? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  bool _isImageUploading = false;
  bool _isCreatingPost = false;
  String? _uploadError;
  String _uploadStatus = '';
  double _uploadProgress = 0.0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialContent ?? '';
    _imageUrl = widget.initialImageUrl;
    _selectedImage = widget.initialImage;

    // Animasi untuk progress bar
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_progressController)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startProgressAnimation() {
    _progressController.reset();
    _progressController.forward();
  }

  void _updateUploadStatus(String status, {double progress = 0.0}) {
    if (mounted) {
      setState(() {
        _uploadStatus = status;
        _uploadProgress = progress;
      });
    }
  }

  // ============ IMAGE UPLOAD ============

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return _imageUrl;
    }

    setState(() {
      _isImageUploading = true;
      _uploadError = null;
      _uploadStatus = 'Memeriksa koneksi...';
      _uploadProgress = 0.1;
    });

    _startProgressAnimation();

    try {
      // 1. Validasi file
      _updateUploadStatus('Memvalidasi file...', progress: 0.2);

      final file = File(_selectedImage!.path);

      if (!await file.exists()) {
        throw Exception('File tidak ditemukan: ${_selectedImage!.path}');
      }

      final fileSize = await file.length();
      final fileSizeMB = fileSize / (1024 * 1024);

      if (fileSize > 20 * 1024 * 1024) {
        throw Exception(
          'File terlalu besar: ${fileSizeMB.toStringAsFixed(2)} MB (Maksimal 20MB)',
        );
      }

      // 2. Generate filename
      _updateUploadStatus('Mempersiapkan upload...', progress: 0.3);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000);

      String extension = 'jpg';
      final originalPath = file.path;
      if (originalPath.toLowerCase().endsWith('.png')) {
        extension = 'png';
      } else if (originalPath.toLowerCase().endsWith('.jpeg')) {
        extension = 'jpeg';
      } else if (originalPath.toLowerCase().endsWith('.gif')) {
        extension = 'gif';
      } else if (originalPath.toLowerCase().endsWith('.webp')) {
        extension = 'webp';
      }

      final fileName = 'post_${widget.userId}_${timestamp}_$random.$extension';

      // 3. Read file bytes
      _updateUploadStatus('Membaca file...', progress: 0.4);
      final bytes = await file.readAsBytes();

      // 4. Upload ke bucket 'communities'
      _updateUploadStatus('Mengupload ke Supabase...', progress: 0.6);

      await _supabase.storage
          .from('communities')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _getMimeType(extension),
              upsert: true,
              cacheControl: '3600',
            ),
          );

      _updateUploadStatus('✅ Upload berhasil!', progress: 0.8);

      // 5. Dapatkan public URL
      final publicUrl = _supabase.storage
          .from('communities')
          .getPublicUrl(fileName);

      // 6. Validasi URL
      if (!publicUrl.contains('/communities/')) {
        throw Exception('URL tidak valid - bukan dari bucket "communities"');
      }

      _updateUploadStatus('✅ Selesai!', progress: 1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      return publicUrl;
    } catch (e) {
      final errorMsg = e.toString();
      _updateUploadStatus('❌ Upload gagal', progress: 0.0);

      // Handle specific errors
      if (errorMsg.contains('bucket') || errorMsg.contains('404')) {
        _uploadError =
            'Bucket "communities" tidak ditemukan. Silakan setup bucket terlebih dahulu.';
      } else if (errorMsg.contains('permission') || errorMsg.contains('403')) {
        _uploadError =
            'Izin ditolak. Pastikan Anda sudah login dan bucket "communities" public.';
      } else if (errorMsg.contains('size') || errorMsg.contains('large')) {
        _uploadError = 'File terlalu besar. Maksimal 20MB.';
      } else if (errorMsg.contains('network') || errorMsg.contains('timeout')) {
        _uploadError = 'Koneksi internet bermasalah. Coba lagi.';
      } else {
        _uploadError =
            'Upload gagal: ${errorMsg.length > 100 ? "${errorMsg.substring(0, 100)}..." : errorMsg}';
      }

      return null;
    } finally {
      if (mounted) {
        setState(() => _isImageUploading = false);
      }
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ============ IMAGE PICKER ============

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 100,
      );

      if (image != null) {
        // Cek file size
        final file = File(image.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSize > 20 * 1024 * 1024) {
          _showError(
            'File terlalu besar (${fileSizeMB.toStringAsFixed(2)} MB). Maksimal 20MB.',
          );
          return;
        }

        setState(() {
          _selectedImage = image;
          _imageUrl = null;
          _uploadError = null;
          _uploadStatus = 'Gambar dipilih';
        });
      }
    } catch (e) {
      _showError('Error memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 100,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageUrl = null;
          _uploadError = null;
          _uploadStatus = 'Foto diambil';
        });
      }
    } catch (e) {
      _showError('Error mengambil foto: ${e.toString()}');
    }
  }

  // ============ POST CREATION ============

  Future<void> _createOrUpdatePost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      _showError('Konten tidak boleh kosong');
      return;
    }

    if (_selectedImage != null && _isImageUploading) {
      _showError('Tunggu upload gambar selesai');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
      _isCreatingPost = true;
      _uploadStatus = 'Mempersiapkan...';
      _uploadProgress = 0.1;
    });

    _startProgressAnimation();

    try {
      String? finalImageUrl;

      // Upload gambar jika ada gambar baru
      if (_selectedImage != null) {
        _updateUploadStatus('Mengupload gambar...', progress: 0.3);
        finalImageUrl = await _uploadImage();

        if (finalImageUrl == null && _uploadError != null) {
          final continueWithoutImage = await _showUploadFailedDialog();
          if (!continueWithoutImage) {
            setState(() {
              _isUploading = false;
              _isCreatingPost = false;
            });
            return;
          }
        }
      } else {
        finalImageUrl = _imageUrl;
      }

      _updateUploadStatus('Menyimpan post...', progress: 0.7);

      if (widget.isEditing && widget.postId != null) {
        await _postService.updatePost(
          postId: widget.postId!,
          content: content,
          imageUrl: finalImageUrl,
        );

        _updateUploadStatus('✅ Berhasil update!', progress: 1.0);
        _showSuccess('Post berhasil diperbarui!');
      } else {
        await _postService.createPost(
          communityId: widget.communityId,
          userId: widget.userId,
          content: content,
          imageUrl: finalImageUrl,
        );

        _updateUploadStatus('✅ Berhasil dibuat!', progress: 1.0);
        _showSuccess('Post berhasil dibuat!');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      widget.onPostCreated();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _updateUploadStatus('❌ Gagal', progress: 0.0);
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isCreatingPost = false;
        });
      }
    }
  }

  Future<bool> _showUploadFailedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Upload Gagal'),
        content: const Text('Upload gambar gagal. Lanjutkan tanpa gambar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
      _uploadError = null;
    });
  }

  // ============ UI BUILDERS ============

  Widget _buildImagePreview() {
    final hasImage =
        _selectedImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty);

    if (!hasImage) return const SizedBox.shrink();

    if (_isImageUploading) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.blue[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              _uploadStatus,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.blue[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            image: _selectedImage != null
                ? DecorationImage(
                    image: FileImage(File(_selectedImage!.path)),
                    fit: BoxFit.cover,
                  )
                : _imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(_imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey[100],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              onPressed: _removeImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamera'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    if (_uploadError == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _uploadError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() => _uploadError = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isProcessing = _isUploading || _isImageUploading || _isCreatingPost;
    final hasContent = _contentController.text.trim().isNotEmpty;

    if (isProcessing) {
      return Column(
        children: [
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            _uploadStatus,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: hasContent ? _createOrUpdatePost : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.blue[100],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.isEditing ? 'Update' : 'Posting',
              style: TextStyle(
                color: hasContent ? Colors.white : Colors.blue[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ UTILITIES ============

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Post' : 'Buat Post Baru',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isUploading && !_isImageUploading)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Content input
                      TextField(
                        controller: _contentController,
                        maxLines: 6,
                        minLines: 3,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          hintText: 'Apa yang ingin Anda bagikan?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Image preview
                      _buildImagePreview(),

                      const SizedBox(height: 8),

                      // Error display
                      _buildErrorDisplay(),

                      const SizedBox(height: 16),

                      // Image picker buttons
                      _buildImagePickerButtons(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}