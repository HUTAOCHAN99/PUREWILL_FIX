import 'package:flutter/material.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';
import 'package:purewill/ui/auth/screen/resetpassword_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/auth/view_model/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.failure) {
        _showSnackBar("Login Gagal: ${next.errorMessage}");
      } else if (next.status == AuthStatus.success && next.user != null) {
        _showSnackBar("Login Berhasil!");
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    
    return Scaffold(
      // Tambahkan resizeToAvoidBottomInset untuk mencegah resize otomatis
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        // Tambahkan GestureDetector untuk dismiss keyboard saat tap di luar
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/auth/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                children: [
                  // Logo section
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color.fromRGBO(102, 121, 163, 1),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                "assets/images/auth/icon.png",
                                width: screenWidth * 0.24,
                                height: screenWidth * 0.24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "Your journey to self-control starts here",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Form section - Gunakan Expanded dengan SingleChildScrollView
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      // Tambahkan physics untuk scroll yang lebih smooth
                      physics: const ClampingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container icon dengan teks di samping
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon container
                                  Container(
                                    width: screenWidth * 0.15,
                                    height: screenWidth * 0.12,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                        82,
                                        140,
                                        207,
                                        1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: screenWidth * 0.06,
                                        height: screenWidth * 0.06,
                                        child: Image.asset(
                                          "assets/images/auth/icon_walk.png",
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  // Teks di samping icon
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome Back",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.038,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: screenWidth * 0.02,
                                        ),
                                        child: Text(
                                          "Continue",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Journey Sir",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.038,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // Email TextField
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 254, 254, 254),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      217,
                                      217,
                                      217,
                                      255,
                                    ),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          hintText: "Enter your email address",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                          errorStyle: const TextStyle(
                                            fontSize: 0,
                                            height: 0,
                                          ),
                                        ),
                                        // Auto scroll ketika keyboard muncul
                                        onTap: () {
                                          Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () {
                                              _scrollController.animateTo(
                                                _scrollController.position.maxScrollExtent,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeOut,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/images/auth/mail.png",
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16),

                              // Password TextField
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 254, 254, 254),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      217,
                                      217,
                                      217,
                                      255,
                                    ),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          hintText: "Enter your password",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                          errorStyle: const TextStyle(
                                            fontSize: 0,
                                            height: 0,
                                          ),
                                        ),
                                        // Auto scroll ketika keyboard muncul
                                        onTap: () {
                                          Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () {
                                              _scrollController.animateTo(
                                                _scrollController.position.maxScrollExtent,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeOut,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 8),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Color.fromRGBO(82, 140, 207, 1),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color.fromRGBO(
                                        82,
                                        140,
                                        207,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          ref
                                              .read(authNotifierProvider.notifier)
                                              .login(
                                                _emailController.text.trim(),
                                                _passwordController.text.trim(),
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text("Login"),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Register text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Register",
                                      style: TextStyle(
                                        color: Color.fromRGBO(82, 140, 207, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color.fromRGBO(
                                          82,
                                          140,
                                          207,
                                          1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Help section
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Need help?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Contact support logic
                          },
                          child: Text(
                            "Contact support",
                            style: TextStyle(
                              color: Color.fromRGBO(82, 140, 207, 1),
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Color.fromRGBO(82, 140, 207, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}