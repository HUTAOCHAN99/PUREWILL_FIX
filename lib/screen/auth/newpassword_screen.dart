import 'package:flutter/material.dart';
import 'package:purewill/screen/auth/login_screen.dart';
import 'package:purewill/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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
                      child: Column(
                        children: [
                          // Container form
                          Container(
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
                                // Title section
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromARGB(
                                              255,
                                              0,
                                              0,
                                              0,
                                            ).withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.lock_reset,
                                          color: Colors.white,
                                          size: screenWidth * 0.06,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Text
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "New",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          "Password",
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

                                // Description text
                                Center(
                                  child: Text(
                                    "Create your new password",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // New Password TextField
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "New Password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          254,
                                          254,
                                          254,
                                        ),
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
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _newPasswordController,
                                              validator:
                                                  _authService.validatePassword,
                                              obscureText: _obscureNewPassword,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                hintText: "Enter new password",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 16,
                                                ),
                                                errorStyle: const TextStyle(
                                                  fontSize: 0,
                                                  height: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscureNewPassword =
                                                    !_obscureNewPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscureNewPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Confirm Password TextField
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Confirm Password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          254,
                                          254,
                                          254,
                                        ),
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
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              validator: (value) => _authService
                                                  .validateConfirmPassword(
                                                    _newPasswordController.text,
                                                    value,
                                                  ),
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                hintText:
                                                    "Confirm new password",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 16,
                                                ),
                                                errorStyle: const TextStyle(
                                                  fontSize: 0,
                                                  height: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Reset Password button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: _isLoading
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
                                        : const Text("Reset Password"),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Langsung update password karena OTP sudah diverifikasi di screen sebelumnya
      final response = await _authService.updatePassword(
        _newPasswordController.text,
      );

      if (response.user != null) {
        _showSnackBar("Password has been reset successfully");

        // Navigate back to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      _showSnackBar("Failed to reset password: ${error.message}");
    } catch (error) {
      _showSnackBar("An error occurred while resetting password");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
