---
title: "Tính năng Storage Supabase - Chi tiết Implementation"
description: "Phân tích chi tiết các tính năng storage Supabase trong dự án với code thực tế"
order: 12
category: "supabase"
---

# Tính năng Storage Supabase - Chi tiết Implementation

## Tổng quan

Dự án này triển khai một hệ thống lưu trữ hoàn chỉnh sử dụng Supabase Storage với tích hợp PostgreSQL và Bảo mật Cấp Hàng (RLS). Hệ thống hỗ trợ tải lên, tải xuống, xóa tập tin với bảo mật cao và tối ưu hiệu suất.

## Cấu Trúc Thiết Lập Lưu Trữ

### 1. Cấu Hình Bucket Lưu Trữ (storage_setup.sql)

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

**Giải thích Cấu Hình Lưu Trữ:**
- `storage.buckets`: Tạo bucket 'profiles' với truy cập công khai
- `public: true`: Tập tin có thể được truy cập thông qua URL công khai
- `ON CONFLICT DO NOTHING`: Tránh lỗi khi bucket đã tồn tại
- **Chính sách RLS**: Kiểm soát chi tiết quyền truy cập tập tin
- `auth.uid()`: ID người dùng hiện tại từ xác thực
- `storage.foldername(name)`: Trích xuất thư mục từ đường dẫn tập tin để kiểm tra quyền sở hữu

## Triển Khai Flutter

### 1. Khởi Tạo và Thư Viện Phụ Thuộc

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

**Giải thích thư viện phụ thuộc:**
- `dart:io`: Các thao tác hệ thống tập tin
- `image_picker`: Chọn ảnh từ thư viện/máy ảnh
- `permission_handler`: Xin quyền truy cập lưu trữ/máy ảnh
- `FileObject`: Kiểu Supabase cho siêu dữ liệu tập tin

### 2. Tải Lên Ảnh Từ Thư Viện

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

**Giải thích quá trình tải lên:**
- **Xử lý quyền**: Xin quyền truy cập ảnh trước khi chọn
- **Tối ưu hóa ảnh**: Giới hạn kích thước (1024x1024) và chất lượng (80%) để tối ưu
- **Tên tập tin duy nhất**: Sử dụng dấu thời gian để tránh xung đột
- **Cấu trúc đường dẫn tập tin**: `uploads/filename` cho tổ chức
- **Tùy chọn tập tin**: Kiểm soát bộ đệm và cài đặt cập nhật

### 3. Tải Lên Từ Máy Ảnh

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

**Giải thích chụp ảnh bằng máy ảnh:**
- **Quyền máy ảnh**: Xin quyền máy ảnh riêng biệt
- **Tiền tố tên tập tin**: 'camera_' để phân biệt nguồn ảnh
- **Tối ưu hóa giống nhau**: Cùng cài đặt như tải lên thư viện

### 4. Tải Tập Tin Từ Lưu Trữ

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

**Giải thích liệt kê tập tin:**
- `list()`: Lấy danh sách tập tin trong đường dẫn
- `Tùy chọn tìm kiếm`: Cấu hình phân trang và sắp xếp
- `limit: 100`: Giới hạn số tập tin tải cùng lúc
- `sortBy`: Sắp xếp theo created_at giảm dần (mới nhất trước)

### 5. Lấy URL Công Khai

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

**Giải thích URL công khai:**
- `getPublicUrl()`: Tạo URL công khai để hiển thị ảnh
- URL được lưu trong bộ đệm và có thể truy cập trực tiếp từ trình duyệt
- Không cần xác thực để xem (vì bucket là công khai)

### 6. Xóa Tập Tin

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

**Giải thích thao tác xóa:**
- **Hộp thoại xác nhận**: Thực hành UX tốt nhất để tránh xóa nhầm
- `remove([filePath])`: Chấp nhận mảng đường dẫn tập tin để có thể xóa hàng loạt
- **Dọn dẹp trạng thái**: Xóa ảnh đã chọn nếu tập tin đó bị xóa

## Giao Diện Người Dùng

### 1. Điều Khiển Tải Lên

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

### 2. Hiển Thị Lưới Ảnh

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

**Giải thích các thành phần giao diện:**
- **Bố cục lưới**: 2 cột với khoảng cách đều nhau
- **Trạng thái tải**: Chỉ báo tải cho ảnh
- **Xử lý lỗi**: Biểu tượng lỗi khi tải ảnh thất bại
- **Phản hồi lựa chọn**: Làm nổi bật viền cho ảnh đã chọn
- **Lớp phủ xóa**: Nút xóa nổi trên mỗi ảnh

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

## Cấu Hình Quyền

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

## Thực Hành Tốt Nhất Được Áp Dụng

### 1. Security
- **Chính sách RLS**: Kiểm soát quyền truy cập tập tin theo người dùng
- **Xử lý quyền**: Xin quyền trước khi truy cập máy ảnh/thư viện
- **Xác thực đầu vào**: Xác thực loại tập tin và kích thước

### 2. Performance
- **Tối ưu hóa ảnh**: Thay đổi kích thước và nén ảnh trước khi tải lên
- **Phân trang**: Tải tập tin theo lô để tránh vấn đề hiệu suất
- **Kiểm soát bộ đệm**: Sử dụng header bộ đệm cho việc tải tối ưu

### 3. User Experience
- **Trạng thái tải**: Phản hồi trực quan cho tất cả các thao tác bất đồng bộ
- **Xử lý lỗi**: Thông báo lỗi thân thiện với người dùng
- **Hộp thoại xác nhận**: Tránh xóa nhầm
- **Phản hồi trực quan**: Trạng thái lựa chọn và chỉ báo tiến độ

### 4. Tổ Chức Lưu Trữ
- **Cấu trúc thư mục**: Tổ chức tập tin trong các thư mục
- **Tên tập tin duy nhất**: Đặt tên dựa trên dấu thời gian để tránh xung đột
- **Siêu dữ liệu tập tin**: Theo dõi thời gian tạo và thông tin tập tin

## Kết Luận

Triển khai Lưu trữ Supabase trong dự án này thể hiện:

1. **Quản Lý Tập Tin Hoàn Chỉnh**: Tải lên, xem, xóa với xử lý lỗi đầy đủ
2. **Triển Khai Bảo Mật**: Chính sách RLS và xử lý quyền
3. **Tối Ơu Hóa Hiệu Suất**: Nén ảnh và tải hiệu quả
4. **Giao Diện/Trải Nghiệm Chuyên Nghiệp**: Trạng thái tải, xử lý lỗi, phản hồi trực quan
5. **Hỗ Trợ Đa Nền Tảng**: Truy cập máy ảnh và thư viện trên iOS/Android
6. **Mã Sẵn Sàng Sản Xuất**: Thực hành tốt nhất và kiến trúc có thể mở rộng

Mã này có thể được sử dụng làm nền tảng cho các hệ thống quản lý tập tin sản xuất.