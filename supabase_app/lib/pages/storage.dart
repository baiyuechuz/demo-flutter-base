import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_app/components/custom_button.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('User not authenticated - cannot load profile image');
        setState(() {
          _profileImageUrl = null;
        });
        return;
      }

      final String fileName = '${user.id}/profile_${user.id}.jpg';

      // Check if file exists first
      try {
        final files = await supabase.storage
            .from('profiles')
            .list(path: user.id);
        
        final fileExists = files.any((file) => file.name == 'profile_${user.id}.jpg');
        
        if (!fileExists) {
          print('Profile image does not exist yet');
          setState(() {
            _profileImageUrl = null;
          });
          return;
        }
      } catch (e) {
        print('Error checking file existence: $e');
        setState(() {
          _profileImageUrl = null;
        });
        return;
      }

      // Try to get public URL first (if bucket is public)
      try {
        final String publicUrl = supabase.storage
            .from('profiles')
            .getPublicUrl(fileName);
        
        // Add cache-busting parameter
        final String cacheBustedUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        
        setState(() {
          _profileImageUrl = cacheBustedUrl;
        });
        print('Loaded profile image: $cacheBustedUrl');
      } catch (e) {
        // If public URL fails, try signed URL
        try {
          final response = await supabase.storage
              .from('profiles')
              .createSignedUrl(fileName, 60 * 60);

          setState(() {
            _profileImageUrl = response;
          });
          print('Loaded profile image (signed): $response');
        } catch (signedUrlError) {
          print('Could not get signed URL: $signedUrlError');
          setState(() {
            _profileImageUrl = null;
          });
        }
      }
    } catch (e) {
      print('Could not load profile image: $e');
      setState(() {
        _profileImageUrl = null;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo permission is required to upload images'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    await _requestPermissions();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in to upload images');
      }

      final String fileName = '${user.id}/profile_${user.id}.jpg';

      print('Uploading file: $fileName for user: ${user.id}');

      await supabase.storage
          .from('profiles')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      print('Upload successful, getting public URL...');

      // Add a small delay to ensure the file is fully processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the public URL with a cache-busting timestamp
      final String imageUrl = supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);
      
      // Add cache-busting parameter to force reload
      final String cacheBustedUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      print('Image URL: $cacheBustedUrl');

      setState(() {
        _profileImageUrl = cacheBustedUrl;
        _isUploading = false;
      });

      // Reload the image to ensure it displays properly
      await Future.delayed(const Duration(milliseconds: 200));
      await _loadProfileImage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      print('Upload error: $e');

      String errorMessage = 'Upload failed: $e';
      
      // Provide more specific error messages
      if (e.toString().contains('permission') || e.toString().contains('policy')) {
        errorMessage = 'Permission denied. Please ensure you are logged in and storage policies are configured correctly.';
      } else if (e.toString().contains('bucket')) {
        errorMessage = 'Storage bucket not found. Please check your Supabase storage configuration.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildProfileImageFrame() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0b1221),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _profileImageUrl != null
                ? Image.network(
                    _profileImageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    headers: {
                      'Cache-Control': 'no-cache',
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error: $error');
                      return _buildPlaceholderAvatar();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF667eea),
                          ),
                        ),
                      );
                    },
                  )
                : _buildPlaceholderAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person, size: 80, color: Colors.white54),
    );
  }

  Widget _buildAuthStatus() {
    final user = supabase.auth.currentUser;
    
    if (user != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Logged in as: ${user.email}',
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please log in first to upload images. Go to Authentication page.',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Storage Demo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0b1221),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0b1221),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAuthStatus(),
              const SizedBox(height: 20),
              _buildProfileImageFrame(),
              const SizedBox(height: 40),
              CustomGradientButton(
                text: _isUploading ? 'Uploading...' : 'Upload Image',
                onPressed: _isUploading ? null : _pickAndUploadImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

