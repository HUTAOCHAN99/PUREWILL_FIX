import 'package:flutter/material.dart';
import 'package:purewill/screen/auth/login_screen.dart';
import 'package:purewill/screen/auth/verif_screen.dart';
import 'package:purewill/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/auth/bg2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Column(
              children: [
                // Logo section
                Container(
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
                            width: 1,
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

                SizedBox(height: screenHeight * 0.02),

                // Form section
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.12,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(82, 140, 207, 1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey[300]!, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      "assets/images/auth/sun_icon.png",
                                      width: screenWidth * 0.06,
                                      height: screenWidth * 0.06,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("New", style: TextStyle(fontSize: screenWidth * 0.038, fontWeight: FontWeight.bold)),
                                    Text("Journey", style: TextStyle(fontSize: screenWidth * 0.038, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Full Name
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 254, 254, 254),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color.fromARGB(217, 217, 217, 255), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      validator: _authService.validateFullName,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        hintText: "Enter full your name",
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset("assets/images/auth/persons.png", width: 24, height: 24, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Email
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 254, 254, 254),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color.fromARGB(217, 217, 217, 255), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      validator: _authService.validateEmail,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        hintText: "Enter your email address",
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset("assets/images/auth/mail.png", width: 20, height: 20),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Password
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 254, 254, 254),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color.fromARGB(217, 217, 217, 255), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      validator: _authService.validatePassword,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        hintText: "Create a Password",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),

                            // Register button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? ", style: TextStyle(color: Colors.black, fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                                  child: const Text("Login", style: TextStyle(color: Color.fromRGBO(82, 140, 207, 1), fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Terms & Help section
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(
                        "By registering, you agree to our Terms of Service and Privacy Policy",
                        style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.03),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Column(
                      children: [
                        Text("Need help?", style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.035)),
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {},
                          child: Text("Contact support", style: TextStyle(color: Color.fromRGBO(82, 140, 207, 1), fontSize: screenWidth * 0.038, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );

      if (response?.user != null) {
        // LANGSUNG KE VERIF SCREEN - TUNGGU OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: _emailController.text,
              type: VerificationType.registration,
            ),
          ),
        );
        
        _showSnackBar("Registration successful! Check your email for 6-digit OTP code.");
      }
    } on AuthException catch (error) {
      String errorMessage = "Registration failed: ${error.message}";
      if (error.message.contains('rate limit') || error.message.contains('security purposes')) {
        errorMessage = "Please wait 60 seconds before trying again";
      } else if (error.message.contains('User already registered')) {
        errorMessage = "Email already registered. Please login instead";
      }
      _showSnackBar(errorMessage);
    } catch (error) {
      _showSnackBar("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 4)));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}