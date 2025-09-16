---
title: "Tính năng Xác thực Firebase - Chi tiết Triển khai"
description: "Phân tích chi tiết các tính năng xác thực Firebase trong dự án với code thực tế"
order: 12
category: "firebase"
---

# Tính năng Xác thực Firebase - Chi tiết Triển khai

## Tổng quan

Dự án này triển khai một hệ thống xác thực hoàn chỉnh sử dụng Firebase Auth với các tính năng chính:

- **Email/Mật khẩu**: Đăng ký và đăng nhập truyền thống
- **OAuth Social**: Google, Facebook, GitHub sign-in
- **Multi-platform**: Hỗ trợ web và mobile với tối ưu hóa riêng
- **Real-time State**: Quản lý trạng thái xác thực theo thời gian thực
- **Modern UI**: Giao diện tối với animations và feedback

## Cấu trúc Code

### 1. Khởi tạo và Dependencies

```dart
class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  // Controllers and state
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // State management
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _showSuccessBanner = false;
  Timer? _bannerTimer;
  
  // Platform-specific Google Sign-In
  GoogleSignIn? _googleSignIn;
}
```

### 2. Quản lý Trạng thái Xác thực

```dart
@override
void initState() {
  super.initState();
  // Initialize GoogleSignIn for mobile only
  if (!kIsWeb) {
    _googleSignIn = GoogleSignIn();
  }
  _checkAuthState();
}

void _checkAuthState() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
      _showSuccessBanner();
    } else {
      setState(() {
        _isLoggedIn = false;
        _showSuccessBanner = false;
      });
    }
  });
}
```

### 3. Các Phương thức Xác thực

#### Xác thực Email/Password

```dart
// Sign up
Future<void> _signUp() async {
  if (!_validateSignUpForm()) return;
  
  setState(() => _isLoading = true);
  
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  } on FirebaseAuthException catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}

// Đăng nhập
Future<void> _signIn() async {
  if (!_validateSignInForm()) return;
  
  setState(() => _isLoading = true);
  
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  } on FirebaseAuthException catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Google Sign-In

```dart
Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);

  try {
    if (kIsWeb) {
      // Web: Firebase popup
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Mobile: Google Sign-In package
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Facebook Sign-In

```dart
Future<void> _signInWithFacebook() async {
  setState(() => _isLoading = true);

  try {
    if (kIsWeb) {
      // Web: Firebase popup
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      facebookProvider.addScope('email');
      await FirebaseAuth.instance.signInWithPopup(facebookProvider);
    } else {
      // Mobile: Facebook Auth package
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    }
  } catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### GitHub Sign-In

```dart
Future<void> _signInWithGitHub() async {
  setState(() => _isLoading = true);

  try {
    GithubAuthProvider githubProvider = GithubAuthProvider();
    githubProvider.addScope('user:email');
    
    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(githubProvider);
    } else {
      await FirebaseAuth.instance.signInWithProvider(githubProvider);
    }
  } catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 4. Đăng xuất

```dart
Future<void> _signOut() async {
  try {
    // Sign out from all providers
    await FirebaseAuth.instance.signOut();
    
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    
    await FacebookAuth.instance.logOut();
    
    // Clear form
    _clearForm();
  } catch (e) {
    _handleAuthError(e);
  }
}
```

## Giao diện Người dùng

### 1. Form Xác thực

```dart
Widget _buildAuthForm() {
  return Column(
    children: [
      // Email field
      _buildTextField(
        controller: _emailController,
        hintText: 'Email',
        keyboardType: TextInputType.emailAddress,
      ),
      
      const SizedBox(height: 16),
      
      // Password field
      _buildTextField(
        controller: _passwordController,
        hintText: 'Password',
        obscureText: true,
      ),
      
      // Confirm password (signup only)
      if (_isSignUp) ...[
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: true,
        ),
      ],
      
      const SizedBox(height: 24),
      
      // Sign in/up button
      CustomGradientButton(
        text: _isLoading 
            ? 'Loading...' 
            : (_isSignUp ? 'Sign Up' : 'Sign In'),
        onPressed: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
        width: double.infinity,
        height: 56,
      ),
      
      // Toggle sign in/up
      _buildToggleButton(),
    ],
  );
}
```

### 2. Các nút Đăng nhập Mạng xã hội

```dart
Widget _buildSocialLoginSection() {
  return Column(
    children: [
      // Divider with "OR" text
      _buildOrDivider(),
      
      const SizedBox(height: 24),
      
      // Social buttons row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(
            onTap: _signInWithGoogle,
            iconPath: 'assets/icons/google_logo.svg',
          ),
          _buildSocialButton(
            onTap: kIsWeb ? _signInWithGitHub : null,
            iconPath: 'assets/icons/github_logo.svg',
            isEnabled: kIsWeb,
          ),
          _buildSocialButton(
            onTap: _signInWithFacebook,
            iconPath: 'assets/icons/facebook_logo.svg',
          ),
        ],
      ),
    ],
  );
}

Widget _buildSocialButton({
  required VoidCallback? onTap,
  required String iconPath,
  bool isEnabled = true,
}) {
  return Container(
    width: 72,
    height: 72,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.transparent,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        onTap: isEnabled ? onTap : null,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
            colorFilter: isEnabled 
                ? null 
                : ColorFilter.mode(
                    Colors.white.withOpacity(0.5), 
                    BlendMode.srcIn
                  ),
          ),
        ),
      ),
    ),
  );
}
```

### 3. Hiển thị Hồ sơ Người dùng

```dart
Widget _buildUserProfile() {
  final user = FirebaseAuth.instance.currentUser!;
  
  return Column(
    children: [
      // Success icon
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.verified_user,
          color: Colors.white,
          size: 60,
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Welcome card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1a2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'No email',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'User ID: ${user.uid.substring(0, 8)}...${user.uid.substring(user.uid.length - 8)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Sign out button
      CustomGradientButton(
        text: 'Sign Out',
        onPressed: _signOut,
        width: double.infinity,
        height: 56,
        backgroundColor: Colors.red,
      ),
    ],
  );
}
```

### 4. Biểu ngữ Thành công

```dart
Widget _buildSuccessBanner() {
  if (!_showSuccessBanner || !_isLoggedIn) return const SizedBox.shrink();
  
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sign in successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _showSuccessBanner = false),
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## Các Hàm Tiện ích

### Xác thực Form

```dart
bool _validateSignUpForm() {
  if (_emailController.text.isEmpty || 
      _passwordController.text.isEmpty || 
      _confirmPasswordController.text.isEmpty) {
    return false;
  }
  
  if (_passwordController.text != _confirmPasswordController.text) {
    return false;
  }
  
  if (_passwordController.text.length < 6) {
    return false;
  }
  
  return true;
}

bool _validateSignInForm() {
  return _emailController.text.isNotEmpty && 
         _passwordController.text.isNotEmpty;
}
```

### Xử lý Lỗi

```dart
void _handleAuthError(dynamic error) {
  String message = 'Authentication error occurred';
  
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        message = 'Email already in use';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'user-not-found':
        message = 'User not found';
        break;
      case 'wrong-password':
        message = 'Wrong password';
        break;
      case 'invalid-email':
        message = 'Invalid email format';
        break;
      default:
        message = error.message ?? 'Authentication failed';
    }
  }
  
  // Show error message (implement based on your UI needs)
  debugPrint('Auth Error: $message');
}
```
## Tóm tắt logic & hàm chính

### 1.Trình lắng nghe trạng thái xác thực: chuyển UI giữa form và hồ sơ người dùng

```dart
// Auth state listener - switches UI on login/logout
@override
void initState() {
  super.initState();
  if (!kIsWeb) _googleSignIn = GoogleSignIn();
  FirebaseAuth.instance.authStateChanges().listen((user) {
    setState(() {
      _isLoggedIn = user != null;
      _showSuccessBanner = user != null;
    });
  });
}
```

### 2.Đăng ký/Đăng nhập email-mật khẩu: kiểm tra form → gọi Firebase → cập nhật trạng thái tải

```dart
// Email/password sign in
Future<void> _signIn() async {
  if (!_validateSignInForm()) return;
  setState(() => _isLoading = true);
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  } on FirebaseAuthException catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 3.Google/Facebook/GitHub: tách luồng web (popup) và di động (SDK/provider)

```dart
// Google sign in - web uses popup, mobile uses GoogleSignIn
Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);
  try {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      final user = await _googleSignIn!.signIn();
      if (user == null) return; // user cancelled
      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    _handleAuthError(e);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 4. Đăng xuất: Firebase + dịch vụ đăng nhập (nếu dùng), dọn dẹp form

```dart
// Sign out from Firebase and providers
Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
  if (!kIsWeb && _googleSignIn != null) await _googleSignIn!.signOut();
  await FacebookAuth.instance.logOut();
  _clearForm();
}
```

#### Ghi chú:
- GitHub (web: `signInWithPopup`, mobile: `signInWithProvider`) không tạo phiên SDK riêng, nên chỉ cần `FirebaseAuth.instance.signOut()` là đủ.
- Google trên mobile và Facebook dùng SDK riêng, vì thế cần gọi thêm `GoogleSignIn().signOut()` và `FacebookAuth.instance.logOut()` như ví dụ.

## Tính năng Chính

### Hỗ trợ Đa nền tảng
- **Web**: Xác thực popup của Firebase
- **Di động**: Tích hợp SDK native
- **Nhận diện nền tảng**: Dùng `kIsWeb` cho triển khai có điều kiện

### Luồng OAuth Hoàn chỉnh
- **Google**: Quyền email và profile
- **Facebook**: Quyền email và public_profile
- **GitHub**: Truy cập phạm vi user:email

### Quản lý Trạng thái
- **Trạng thái xác thực thời gian thực**: Lắng nghe `authStateChanges()`
- **Trạng thái tải**: Phản hồi UI khi thao tác bất đồng bộ
- **Phản hồi thành công**: Biểu ngữ có hoạt ảnh và tự ẩn

### Xử lý Lỗi
- **Ngoại lệ Firebase**: Bắt lỗi toàn diện
- **Phản hồi người dùng**: Thông điệp lỗi phù hợp
- **Giảm thiểu tác động**: Xử lý lỗi im lặng khi phù hợp

### Thực hành Bảo mật
- **Quản lý token**: Lưu trữ an toàn tự động
- **Quản lý phiên**: Phiên do Firebase quản lý
- **Quản lý phạm vi**: Chỉ yêu cầu quyền tối thiểu cần thiết

## User flow

1. Mở ứng dụng → khởi tạo Firebase và lắng nghe `authStateChanges()`
2. Nếu đã đăng nhập → hiển thị hồ sơ người dùng + nút Sign Out
3. Nếu chưa đăng nhập → hiển thị form đăng nhập/đăng ký + nút mạng xã hội
4. Người dùng chọn phương thức:
   - Email/Mật khẩu: nhập form → bấm Sign In/Sign Up
   - Google/Facebook/GitHub: kích hoạt luồng OAuth (web: popup, mobile: SDK)
5. Firebase trả kết quả:
   - Thành công → cập nhật `_isLoggedIn = true`, hiện banner thành công, chuyển UI sang hồ sơ
   - Thất bại → gọi `_handleAuthError(...)`, hiển thị thông báo phù hợp
6. Người dùng có thể Sign Out để quay lại form xác thực

## Kết luận

Triển khai Firebase Authentication này mang lại:

1. **Sẵn sàng sản xuất**: Xử lý lỗi toàn diện và tối ưu theo nền tảng
2. **Thân thiện người dùng**: UI hiện đại với trạng thái tải và phản hồi thành công
3. **Khả năng mở rộng**: Dễ mở rộng với các dịch vụ đăng nhập xác thực khác
4. **Bảo mật**: Tuân thủ các thực hành bảo mật của Firebase
5. **Đa nền tảng**: Tối ưu cho cả web và di động

Kiến trúc hỗ trợ bảo trì dễ dàng và mở rộng trong tương lai, đồng thời cung cấp nền tảng vững chắc cho xác thực trong ứng dụng Flutter.