import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import '../components/custom_button.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _showSuccessBanner = false;
  Timer? _bannerTimer;
  
  // Google Sign-In instance (only for mobile)
  GoogleSignIn? _googleSignIn;


  @override
  void initState() {
    super.initState();
    // Initialize GoogleSignIn only for mobile platforms
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
        // Show success banner when logged in
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showSuccessBanner = true;
            });
            // Auto-hide banner after 1 seconds
            _bannerTimer?.cancel();
            _bannerTimer = Timer(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _showSuccessBanner = false;
                });
              }
            });
          }
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _showSuccessBanner = false;
        });
        _bannerTimer?.cancel();
      }
    });
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException {
      // Handle errors silently or with snackbar if needed
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      return;
    }

    if (_passwordController.text.length < 6) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException {
      // Handle errors silently or with snackbar if needed
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      // Only sign out from Google Sign-In on mobile
      if (!kIsWeb && _googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      
      // Sign out from Facebook
      await FacebookAuth.instance.logOut();
      
      setState(() {
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    }
  }

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // For web, use Firebase Auth popup directly
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // For mobile, use Google Sign-In package
        if (_googleSignIn == null) {
          throw Exception('Google Sign-In not initialized');
        }
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        
        if (googleUser == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // GitHub Sign-In
  Future<void> _signInWithGitHub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // For web, use popup sign-in
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('user:email');
        
        await FirebaseAuth.instance.signInWithPopup(githubProvider);
      } else {
        // For mobile, use redirect (requires proper mobile configuration)
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('user:email');
        
        await FirebaseAuth.instance.signInWithProvider(githubProvider);
      }
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Facebook Sign-In
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // For web, use Firebase Auth popup directly
        FacebookAuthProvider facebookProvider = FacebookAuthProvider();
        facebookProvider.addScope('email');
        facebookProvider.setCustomParameters({
          'display': 'popup',
        });
        
        await FirebaseAuth.instance.signInWithPopup(facebookProvider);
      } else {
        // For mobile, use Facebook Auth package
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
        );

        if (result.status == LoginStatus.success) {
          // Create a credential from the access token
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(result.accessToken!.tokenString);

          // Once signed in, return the UserCredential
          await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        }
      }
    } catch (_) {
      // Handle errors silently or with snackbar if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required String iconPath,
    required double iconSize,
    Color? iconColor,
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
              width: iconSize,
              height: iconSize,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(
                      isEnabled ? iconColor : iconColor.withOpacity(0.5),
                      BlendMode.srcIn,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Authentication',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0b1221),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0b1221),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                // Show login form only when not logged in
                if (!_isLoggedIn) ...[
            const Icon(Icons.lock, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            Text(
              _isSignUp ? 'Create Account' : 'Authentication Required',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSignUp 
                  ? 'Please create an account to access all features.'
                  : 'Please sign in or create an account to access\nstorage features.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // Confirm password field (only for sign up)
            if (_isSignUp) ...[
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
                  
              // Sign in/up button
              CustomGradientButton(
                text: _isLoading 
                    ? 'Loading...' 
                    : (_isSignUp ? 'Sign Up' : 'Sign In'),
                onPressed: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
                width: double.infinity,
                height: 56,
              ),
              const SizedBox(height: 15),
              
                  // Toggle sign in/up
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                child: Text(
                  _isSignUp 
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
                  
                  const SizedBox(height: 30),
                  
                  // Divider with "OR" text
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.white30,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.white30,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Sign-In Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Google Sign-In Button
                      _buildSocialButton(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        iconPath: 'assets/icons/google_logo.svg',
                        iconSize: 32,
                      ),
                      
                      // GitHub Sign-In Button
                      _buildSocialButton(
                        onTap: _isLoading ? null : () async {
                          if (kIsWeb) {
                            await _signInWithGitHub();
                          }
                        },
                        iconPath: 'assets/icons/github_logo.svg',
                        iconSize: 32,
                        iconColor: Colors.white,
                        isEnabled: kIsWeb,
                      ),
                      
                      // Facebook Sign-In Button
                      _buildSocialButton(
                        onTap: _isLoading ? null : _signInWithFacebook,
                        iconPath: 'assets/icons/facebook_logo.svg',
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
                
                // Success UI (when logged in) - completely separate from login form
                if (_isLoggedIn && FirebaseAuth.instance.currentUser != null) ...[
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF2E7D32),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
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
                  
                  // Authenticated Title
                  const Text(
                    'Authenticated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Success Message
                  Text(
                    'You are successfully logged in!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
              
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a2332),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          FirebaseAuth.instance.currentUser!.email ?? 'No email',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'User ID: ${FirebaseAuth.instance.currentUser!.uid.substring(0, 8)}...${FirebaseAuth.instance.currentUser!.uid.substring(FirebaseAuth.instance.currentUser!.uid.length - 8)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Out Button using CustomGradientButton
              CustomGradientButton(
                    text: 'Sign Out',
                onPressed: _signOut,
                width: double.infinity,
                    height: 56,
              ),
            ],
          ],
        ),
          ),
          
          // Success Banner
          if (_showSuccessBanner && _isLoggedIn)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF66BB6A),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
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
                        onPressed: () {
                          _bannerTimer?.cancel();
                          setState(() {
                            _showSuccessBanner = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }
}
