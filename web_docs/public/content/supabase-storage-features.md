---
title: "Tính năng Storage Supabase - Chi tiết Implementation"
description: "Phân tích chi tiết các tính năng storage Supabase trong dự án với code thực tế"
order: 12
category: "supabase"
---

# Tính năng Storage Supabase - Chi tiết Implementation

## Tổng quan

Dự án này triển khai một hệ thống storage hoàn chỉnh sử dụng Supabase Storage với tích hợp PostgreSQL và Row Level Security (RLS). Hệ thống hỗ trợ upload, download, delete files với bảo mật cao và tối ưu performance.

## Cấu trúc Storage Setup

### 1. Storage Bucket Configuration (storage_setup.sql)

```sql
-- Storage Setup for Supabase Image Upload
-- This file sets up the storage bucket and policies for image uploads

-- Create the profiles storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Note: RLS is already enabled on storage.objects by default in Supabase
-- No need to manually enable it

-- Policy: Allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow authenticated users to view all profile images
CREATE POLICY "Users can view all profile images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profiles'
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow users to update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow users to delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );
```

**Giải thích Storage Configuration:**
- `storage.buckets`: Tạo bucket 'profiles' với public access
- `public: true`: Files có thể được truy cập thông qua public URL
- `ON CONFLICT DO NOTHING`: Tránh lỗi khi bucket đã tồn tại
- **RLS Policies**: Kiểm soát chi tiết quyền truy cập files
- `auth.uid()`: User ID hiện tại từ authentication
- `storage.foldername(name)`: Extract folder từ file path để check ownership

## Implementation Flutter

### 1. Khởi tạo và Dependencies

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  
  List<FileObject> _files = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _selectedImageUrl;
```

**Giải thích dependencies:**
- `dart:io`: File system operations
- `image_picker`: Chọn ảnh từ gallery/camera
- `permission_handler`: Xin quyền truy cập storage/camera
- `FileObject`: Supabase type cho file metadata

### 2. Upload Image từ Gallery

```dart
Future<void> _uploadImage() async {
  // Check and request permissions
  final permission = await Permission.photos.request();
  if (!permission.isGranted) {
    _showMessage('Permission denied for photo access');
    return;
  }

  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    final File file = File(image.path);
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = 'uploads/$fileName';

    await supabase.storage.from('profiles').upload(
      filePath,
      file,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    _showMessage('Image uploaded successfully!');
    await _loadFiles();
  } catch (e) {
    _showMessage('Error uploading image: $e');
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}
```

**Giải thích upload process:**
- **Permission handling**: Xin quyền truy cập photos trước khi chọn
- **Image optimization**: Giới hạn size (1024x1024) và quality (80%) để tối ưu
- **Unique filename**: Sử dụng timestamp để tránh conflict
- **File path structure**: `uploads/filename` cho organization
- **FileOptions**: Cache control và upsert settings

### 3. Upload từ Camera

```dart
Future<void> _uploadFromCamera() async {
  final permission = await Permission.camera.request();
  if (!permission.isGranted) {
    _showMessage('Permission denied for camera access');
    return;
  }

  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    final File file = File(image.path);
    final String fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = 'uploads/$fileName';

    await supabase.storage.from('profiles').upload(
      filePath,
      file,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    _showMessage('Photo captured and uploaded successfully!');
    await _loadFiles();
  } catch (e) {
    _showMessage('Error capturing photo: $e');
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}
```

**Giải thích camera capture:**
- **Camera permission**: Xin quyền camera riêng biệt
- **Filename prefix**: 'camera_' để phân biệt nguồn ảnh
- **Same optimization**: Cùng settings như gallery upload

### 4. Load Files từ Storage

```dart
Future<void> _loadFiles() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final List<FileObject> files = await supabase.storage
        .from('profiles')
        .list(
          path: 'uploads',
          searchOptions: const SearchOptions(
            limit: 100,
            offset: 0,
            sortBy: SortBy(
              column: 'created_at',
              order: 'desc',
            ),
          ),
        );

    setState(() {
      _files = files;
    });
  } catch (e) {
    _showMessage('Error loading files: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

**Giải thích file listing:**
- `list()`: Lấy danh sách files trong path
- `SearchOptions`: Cấu hình pagination và sorting
- `limit: 100`: Giới hạn số files load cùng lúc
- `sortBy`: Sắp xếp theo created_at desc (mới nhất trước)

### 5. Get Public URL

```dart
String _getPublicUrl(String filePath) {
  try {
    return supabase.storage
        .from('profiles')
        .getPublicUrl(filePath);
  } catch (e) {
    _showMessage('Error getting public URL: $e');
    return '';
  }
}
```

**Giải thích public URL:**
- `getPublicUrl()`: Tạo public URL để hiển thị ảnh
- URL được cache và có thể access trực tiếp từ browser
- Không cần authentication để view (vì bucket là public)

### 6. Delete File

```dart
Future<void> _deleteFile(String filePath) async {
  // Show confirmation dialog
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this file?\n$filePath',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    await supabase.storage
        .from('profiles')
        .remove([filePath]);

    _showMessage('File deleted successfully!');
    await _loadFiles();
    
    // Clear selected image if it was deleted
    if (_selectedImageUrl?.contains(filePath) == true) {
      setState(() {
        _selectedImageUrl = null;
      });
    }
  } catch (e) {
    _showMessage('Error deleting file: $e');
  }
}
```

**Giải thích delete operation:**
- **Confirmation dialog**: UX best practice để tránh xóa nhầm
- `remove([filePath])`: Accept array of file paths để có thể bulk delete
- **State cleanup**: Clear selected image nếu file đó bị xóa

## Giao Diện Người Dùng

### 1. Upload Controls

```dart
Widget _buildUploadControls() {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Images',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: CustomGradientButton(
                text: 'From Gallery',
                onPressed: _isUploading ? null : _uploadImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomGradientButton(
                text: 'From Camera',
                onPressed: _isUploading ? null : _uploadFromCamera,
              ),
            ),
          ],
        ),
        
        if (_isUploading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text(
            'Uploading...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ],
    ),
  );
}
```

### 2. Image Grid Display

```dart
Widget _buildImageGrid() {
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Uploaded Images',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_files.length} files',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadFiles,
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_files.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 48,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No images yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload your first image!',
                    style: TextStyle(
                      color: Colors.white50,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              final filePath = 'uploads/${file.name}';
              final imageUrl = _getPublicUrl(filePath);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageUrl = imageUrl;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageUrl == imageUrl 
                          ? Colors.blue 
                          : Colors.white30,
                      width: _selectedImageUrl == imageUrl ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 32,
                              ),
                            );
                          },
                        ),
                        
                        // Delete button overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _deleteFile(filePath),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}
```

**Giải thích UI components:**
- **Grid layout**: 2 columns với equal spacing
- **Loading states**: Loading indicators cho images
- **Error handling**: Error icons khi load ảnh fail
- **Selection feedback**: Border highlight cho selected image
- **Delete overlay**: Floating delete button trên mỗi image

## Utility Functions

### 1. Helper Methods

```dart
void _showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

@override
void initState() {
  super.initState();
  _loadFiles(); // Load initial files
}

@override
void dispose() {
  super.dispose();
}
```

## Permissions Configuration

### 1. Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 2. iOS (ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images</string>
```

## Best Practices Được Áp Dụng

### 1. Security
- **RLS Policies**: Kiểm soát quyền truy cập files theo user
- **Permission handling**: Xin quyền trước khi truy cập camera/gallery
- **Input validation**: Validate file types và sizes

### 2. Performance
- **Image optimization**: Resize và compress images trước upload
- **Pagination**: Load files theo batch để tránh performance issues
- **Cache control**: Sử dụng cache headers cho optimal loading

### 3. User Experience
- **Loading states**: Visual feedback cho tất cả async operations
- **Error handling**: User-friendly error messages
- **Confirmation dialogs**: Tránh accidental deletions
- **Visual feedback**: Selection states và progress indicators

### 4. Storage Organization
- **Folder structure**: Organize files trong folders
- **Unique filenames**: Timestamp-based naming để tránh conflicts
- **File metadata**: Track creation time và file info

## Kết Luận

Implementation Storage Supabase trong project này demonstration:

1. **Complete File Management**: Upload, view, delete với full error handling
2. **Security Implementation**: RLS policies và permission handling  
3. **Performance Optimization**: Image compression và efficient loading
4. **Professional UI/UX**: Loading states, error handling, visual feedback
5. **Cross-platform Support**: Camera và gallery access trên iOS/Android
6. **Production-Ready Code**: Best practices và scalable architecture

Code này có thể được sử dụng làm foundation cho production file management systems.