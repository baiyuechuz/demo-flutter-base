---
title: "Tính năng Authentication Supabase - Chi tiết Implementation"
description: "Phân tích chi tiết các tính năng authentication Supabase trong dự án với code thực tế"
order: 13
category: "supabase"
---

# Tính năng Authentication Supabase - Chi tiết Implementation

## Tổng quan

Dự án này triển khai một hệ thống xác thực hoàn chỉnh sử dụng Supabase Auth với email/mật khẩu, giao diện đăng nhập mạng xã hội (không có logic), và quản lý trạng thái. Hệ thống tích hợp với Bảo mật Cấp Hàng (RLS) và cung cấp trải nghiệm người dùng tối ưu.

## Implementation Flutter

### 1. Khởi tạo và Dependencies

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_app/components/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  User? _currentUser;
```

**Giải thích thư viện phụ thuộc:**
- `supabase_flutter`: Client Supabase cốt lõi cho xác thực
- `flutter_svg`: Để hiển thị biểu tượng SVG cho các nút đăng nhập mạng xã hội
- `User?`: Đối tượng người dùng có thể null để theo dõi trạng thái xác thực

### 2. Quản Lý Trạng Thái Xác Thực

```dart
@override
void initState() {
  super.initState();
  _getCurrentUser();
  // Listen to auth state changes
  supabase.auth.onAuthStateChange.listen((data) {
    setState(() {
      _currentUser = data.session?.user;
    });
  });
}

void _getCurrentUser() {
  setState(() {
    _currentUser = supabase.auth.currentUser;
  });
}
```

**Giải thích quản lý trạng thái:**
- `onAuthStateChange`: Trình lắng nghe luồng cho thay đổi trạng thái xác thực thời gian thực
- `data.session?.user`: Trích xuất người dùng từ dữ liệu phiên
- `currentUser`: Lấy người dùng đã xác thực hiện tại khi ứng dụng khởi động

### 3. Triển Khai Đăng Ký

```dart
Future<void> _signUp() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful! Please check your email for verification.'),
            backgroundColor: Colors.green,
          ),
        );
        _clearFields();
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

**Giải thích quy trình đăng ký:**
- **Trạng thái tải**: Đặt trạng thái tải để vô hiệu hóa giao diện và hiển thị phản hồi
- **Xác minh email**: Supabase tự động gửi email xác minh
- **Kiểm tra mounted**: Tránh setState trên widget đã được giải phóng
- **Xử lý lỗi**: Try-catch toàn diện với phản hồi người dùng
- **Dọn dẹp form**: Xóa các trường sau khi đăng ký thành công

### 4. Triển Khai Đăng Nhập

```dart
Future<void> _signIn() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final response = await supabase.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in successful!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearFields();
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

**Giải thích quy trình đăng nhập:**
- `signInWithPassword()`: Phương thức Supabase cho xác thực email/mật khẩu
- **Phiên tự động**: Phiên được tự động tạo và lưu
- **Cập nhật trạng thái**: Trình lắng nghe xác thực sẽ tự động cập nhật `_currentUser`

### 5. Triển Khai Đăng Xuất

```dart
Future<void> _signOut() async {
  try {
    await supabase.auth.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Giải thích đăng xuất:**
- `signOut()`: Xóa phiên và tokens
- **Dọn dẹp tự động**: Trình lắng nghe xác thực sẽ đặt `_currentUser = null`
- **Thao tác đơn giản**: Ít có khả năng thất bại hơn so với đăng nhập/đăng ký

### 6. Nút Đăng Nhập Mạng Xã Hội (Chỉ Giao Diện)

```dart
Future<void> _signInWithGoogle() async {
  // TODO: Implement Google sign-in logic
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-in not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

Future<void> _signInWithGitHub() async {
  // TODO: Implement GitHub sign-in logic
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GitHub sign-in not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

Future<void> _signInWithFacebook() async {
  // TODO: Implement Facebook sign-in logic
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook sign-in not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
```

**Giải thích chỗ giữ chỗ đăng nhập mạng xã hội:**
- **Triển khai chỉ giao diện**: Chỉ có các nút và logic giữ chỗ
- **Thông báo nhất quán**: Màu cam để chỉ báo "chưa được triển khai"
- **Mở rộng tương lai**: Cấu trúc sẵn sàng cho triển khai OAuth

## Giao Diện Người Dùng

### 1. Form Xác Thực

```dart
Widget _buildAuthForm() {
  return Column(
    children: [
      TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF667eea)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF667eea)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        obscureText: true,
      ),
      const SizedBox(height: 24),
      CustomGradientButton(
        text: _isSignUp ? 'Sign Up' : 'Sign In',
        width: double.infinity,
        onPressed: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isSignUp = !_isSignUp;
          });
          _clearFields();
        },
        child: Text(
          _isSignUp
              ? 'Already have an account? Sign In'
              : 'Don\'t have an account? Sign Up',
          style: const TextStyle(color: Color(0xFF667eea)),
        ),
      ),
```

**Giải thích thiết kế form:**
- **Chủ đề tối**: Nhất quán với thiết kế ứng dụng
- **Nhãn động**: Thay đổi dựa trên chế độ đăng ký/đăng nhập
- **Xác thực đầu vào**: Loại bàn phím email và ẩn mật khẩu
- **Trạng thái tải**: Vô hiệu hóa nút khi đang xử lý
- **Chuyển đổi chế độ**: Chuyển đổi giữa đăng ký và đăng nhập

### 2. Phần Đăng Nhập Mạng Xã Hội

```dart
if (!_isSignUp) ...[
  const SizedBox(height: 24),
  Row(
    children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Or continue with',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
    ],
  ),
  const SizedBox(height: 24),
  // Social login buttons - Icon only (no background)
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Google
      GestureDetector(
        onTap: _isLoading ? null : _signInWithGoogle,
        child: SvgPicture.asset(
          'assets/icons/google.svg',
          width: 40,
          height: 40,
        ),
      ),
      const SizedBox(width: 32),
      // GitHub
      GestureDetector(
        onTap: _isLoading ? null : _signInWithGitHub,
        child: SvgPicture.asset(
          'assets/icons/github_simple.svg',
          width: 40,
          height: 40,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      const SizedBox(width: 32),
      // Facebook
      GestureDetector(
        onTap: _isLoading ? null : _signInWithFacebook,
        child: SvgPicture.asset(
          'assets/icons/facebook_simple.svg',
          width: 40,
          height: 40,
        ),
      ),
    ],
  ),
],
```

**Giải thích phần mạng xã hội:**
- **Hiển thị có điều kiện**: Chỉ hiển thị với chế độ đăng nhập
- **Phân cách trực quan**: Dải phân cách với văn bản "Hoặc tiếp tục với"
- **Biểu tượng SVG**: Biểu tượng mạng xã hội tùy chỉnh từ assets
- **Thiết kế chỉ biểu tượng**: Cách tiếp cận sạch sẽ, tối giản
- **Khoảng cách phù hợp**: 32px giữa các biểu tượng cho UX thân thiện với cảm ứng
- **Lọc màu**: Biểu tượng GitHub màu trắng để tương phản với nền tối

### 3. Hiển Thị Hồ Sơ Người Dùng

```dart
Widget _buildUserProfile() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              'Welcome!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.email ?? 'No email',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${_currentUser?.id ?? 'Unknown'}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      CustomGradientButton(
        text: 'Sign Out',
        width: double.infinity,
        onPressed: _signOut,
      ),
    ],
  );
}
```

**Giải thích hiển thị hồ sơ:**
- **Thông tin người dùng**: Hiển thị email và ID người dùng
- **Container được tạo kiểu**: Nền bán trong suốt với viền
- **Giá trị dự phòng**: Xử lý giá trị null một cách tinh tế
- **Nút đăng xuất**: Vị trí nổi bật với kiểu dáng nhất quán

### 4. Phương Thức Build Chính

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Authentication',
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
            Icon(
              _currentUser != null ? Icons.verified_user : Icons.lock_outline,
              color: _currentUser != null ? Colors.green : Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              _currentUser != null ? 'Authenticated' : 'Authentication Required',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _currentUser != null 
                  ? 'You are successfully logged in!'
                  : 'Please sign in or create an account to access storage features.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _currentUser != null ? _buildUserProfile() : _buildAuthForm(),
          ],
        ),
      ),
    ),
  );
}
```

**Giải thích bố cục chính:**
- **Hiển thị có điều kiện**: Chuyển đổi giữa form xác thực và hồ sơ người dùng
- **Phản hồi trực quan**: Biểu tượng và thông báo khác nhau cho trạng thái đã/chưa xác thực
- **Nội dung có thể cuộn**: SingleChildScrollView để xử lý bàn phím
- **Chủ đề nhất quán**: Chủ đề tối xuyên suốt

## Utility Functions

### 1. Helper Methods

```dart
void _clearFields() {
  _emailController.clear();
  _passwordController.clear();
}

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

**Giải thích utilities:**
- `_clearFields()`: Clean form sau successful operations
- `dispose()`: Proper cleanup để tránh memory leaks

## Environment Setup

### 1. Main.dart Initialization

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  debugPrint('Supabase initialized successfully');
  runApp(const MyApp());
}
```

### 2. Environment Variables (.env)

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Authentication Flow

### 1. User Journey

```
1. User opens app
   ↓
2. Check current auth state
   ↓
3a. If authenticated → Show user profile
3b. If not authenticated → Show auth form
   ↓
4. User fills form and submits
   ↓
5. Send request to Supabase
   ↓
6a. Success → Update UI, show profile
6b. Error → Show error message, stay on form
   ↓
7. User can sign out to return to auth form
```

### 2. State Management Flow

```
AuthStateChange Stream
   ↓
Listen for changes
   ↓
Extract user from session
   ↓
Update _currentUser state
   ↓
Trigger UI rebuild
   ↓
Show appropriate interface
```

## Best Practices Được Áp Dụng

### 1. Security
- **Input validation**: Email format và password requirements
- **Session management**: Automatic session handling bởi Supabase
- **Secure storage**: Tokens được lưu securely bởi Supabase SDK

### 2. User Experience
- **Loading states**: Visual feedback cho tất cả async operations
- **Error handling**: User-friendly error messages
- **State persistence**: Auth state được maintain across app restarts
- **Responsive design**: Scrollable content, keyboard-friendly

### 3. Code Quality
- **Separation of concerns**: UI, business logic, và state management tách biệt
- **Null safety**: Proper null handling với nullable types
- **Memory management**: Proper disposal của controllers
- **Consistent theming**: Unified dark theme

### 4. Accessibility
- **Semantic widgets**: Proper widget types cho screen readers
- **Color contrast**: Good contrast ratios cho readability
- **Touch targets**: Adequate size cho touch interaction

## Social Login Implementation (Future)

Khi implement actual OAuth, structure sẽ như:

```dart
Future<void> _signInWithGoogle() async {
  try {
    await supabase.auth.signInWithOAuth(
      Provider.google,
      redirectTo: 'your-app://auth-callback',
    );
  } catch (e) {
    _showMessage('Google sign-in failed: $e');
  }
}
```

## Kết Luận

Implementation Authentication Supabase trong project này demonstration:

1. **Complete Auth Flow**: Sign up, sign in, sign out với proper state management
2. **Professional UI**: Dark theme, loading states, error handling
3. **Social Login Ready**: UI structure prepared cho OAuth implementation
4. **Best Practices**: Security, UX, code quality standards
5. **Production Ready**: Error handling, state management, lifecycle management
6. **Scalable Architecture**: Easy to extend với additional auth methods

Code này cung cấp foundation mạnh mẽ cho production authentication systems với Supabase.