---
title: "Getting Started"
description: "Introduction to Supabase and Firebase with Flutter"
order: 1
category: "basics"
---

# Giới thiệu về Firebase với Flutter

Firebase là một nền tảng phát triển ứng dụng di động và web do Google cung cấp, giúp các nhà phát triển xây dựng ứng dụng nhanh chóng mà không cần quản lý cơ sở hạ tầng backend. Nó được biết đến như một dịch vụ **Backend-as-a-Service (BaaS)** toàn diện.

## So sánh Firebase và Supabase

|                       | Firebase                                                                                                                                           | Supabase                                                                                                                                   |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| **Cơ sở dữ liệu**     | Sử dụng **Firestore** (NoSQL), dữ liệu dạng tài liệu và bộ sưu tập. Cấu trúc linh hoạt nhưng khó thực hiện các truy vấn phức tạp (join, tổng hợp). | Sử dụng **PostgreSQL** (cơ sở dữ liệu quan hệ), hỗ trợ cấu trúc schema rõ ràng và các truy vấn SQL phức tạp.                               |
| **Realtime**          | Hỗ trợ realtime bằng cách lắng nghe thay đổi của tài liệu/bộ sưu tập.                                                                              | Dựa trên tính năng **logical replication** của Postgres, cho phép lắng nghe các sự kiện `INSERT/UPDATE/DELETE` trực tiếp từ cơ sở dữ liệu. |
| **Lưu trữ (Storage)** | Firebase Storage dựa trên Google Cloud Storage.                                                                                                    | Supabase Storage dựa trên Postgres và S3.                                                                                                  |
| **Xác thực (Auth)**   | Hỗ trợ email/mật khẩu, SSO (Google, Facebook), phone OTP.                                                                                          | Dựa trên JWT và Postgres, hỗ trợ email/mật khẩu, magic link, OAuth, phone OTP, và tích hợp sâu với Row Level Security.                     |

## Các tính năng chính của Firebase trong Flutter

Dự án demo này minh họa cách sử dụng Firebase với Flutter.

### 1. Cơ sở dữ liệu (Firestore)

Ứng dụng demo này sử dụng Cloud Firestore để thực hiện các thao tác **CRUD** (Create, Read, Update, Delete) trên một bộ sưu tập có tên là `notes`.

#### Khởi tạo Firestore

```dart
// firebase_app/lib/pages/database.dart

final firestore = FirebaseFirestore.instance;
```

#### Thêm dữ liệu (Create)

Sử dụng phương thức `add` để thêm một tài liệu mới vào bộ sưu tập.

```dart
// firebase_app/lib/pages/database.dart

Future<void> _addNote() async {
  // ...
  await firestore.collection('notes').add({
    'title': _titleController.text.trim(),
    'description': _descriptionController.text.trim(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  // ...
}
```

#### Đọc dữ liệu (Read)

Sử dụng phương thức `get` để lấy tất cả các tài liệu từ bộ sưu tập.

```dart
// firebase_app/lib/pages/database.dart

Future<void> _fetchNotes() async {
  // ...
  final querySnapshot = await firestore
      .collection('notes')
      .orderBy('createdAt', descending: true)
      .get();
  // ...
}
```

#### Cập nhật dữ liệu (Update)

Sử dụng phương thức `update` trên một tài liệu cụ thể để sửa đổi dữ liệu.

```dart
// firebase_app/lib/pages/database.dart

Future<void> _updateNote() async {
  // ...
  await firestore.collection('notes').doc(_editingId).update({
    'title': _titleController.text.trim(),
    'description': _descriptionController.text.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  // ...
}
```

#### Xóa dữ liệu (Delete)

Sử dụng phương thức `delete` để xóa một tài liệu.

```dart
// firebase_app/lib/pages/database.dart

Future<void> _deleteNote(String id) async {
  // ...
  await firestore.collection('notes').doc(id).delete();
  // ...
}
```

### 2. Realtime Database

Ứng dụng demo này sử dụng Firebase Realtime Database để đồng bộ hóa dữ liệu tức thì, chẳng hạn như một bộ đếm được chia sẻ.

#### Lắng nghe sự thay đổi của dữ liệu

Sử dụng `onValue.listen` để nhận diện lệnh lắng nghe các sự kiện thay đổi dữ liệu.

```dart
// firebase_app/lib/pages/realtime_database.dart

_counterRef.onValue.listen((DatabaseEvent event) {
  final data = event.snapshot.value;
  setState(() {
    _counter = data is int ? data : 0;
  });
});
```

#### Cập nhật dữ liệu Realtime

Sử dụng phương thức `set` để cập nhật giá trị của một đường dẫn dữ liệu.

```dart
// firebase_app/lib/pages/realtime_database.dart

Future<void> _incrementCounter() async {
  try {
    await _counterRef.set(_counter + 1);
  } catch (error) {
    _showSnackBar('Error updating counter: $error', Colors.red);
  }
}
```

### 3. Xác thực (Authentication)

Ta có thể sử dụng packet `firebase_auth` để dễ dàng thêm các chức năng đăng ký, đăng nhập và đăng xuất.

### 4. Lưu trữ file (Storage)

Tương tự như trên, ta có thể sử dụng packet `firebase_storage` để tải lên và quản lý tệp tin.

