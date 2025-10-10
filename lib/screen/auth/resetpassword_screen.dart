import 'package:flutter/material.dart';
import 'package:purewill/screen/auth/verif_screen.dart';
import 'package:purewill/screen/auth/login_screen.dart';
import 'package:purewill/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
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
                                // Title section dengan icon message.png dan container kotak
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
                                        child: Container(
                                          width: screenWidth * 0.06,
                                          height: screenWidth * 0.06,
                                          child: Icon(
                                            Icons.email,
                                            color: Colors.white,
                                            size: screenWidth * 0.06,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    // Teks di samping icon
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Reset",
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
                                            "Password",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth * 0.038,
                                              fontWeight: FontWeight.bold,
                                              height: 1.1,
                                            ),
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
                                    "Enter your email to receive a reset code",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Email TextField
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Email",
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
                                              controller: _emailController,
                                              validator:
                                                  _authService.validateEmail,
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
                                                    "Enter your email address",
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/images/auth/mail.png",
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Send Reset Code button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _sendResetCode,
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
                                        : const Text("Send Reset Code"),
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Back to Login text
                                Container(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: Colors.black,
                                          size: 20,
                                          weight: 900,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Back To Login",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Teks dengan icon hint
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Colors.black,
                                      size: screenWidth * 0.06,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    SizedBox(
                                      width: screenWidth * 0.6,
                                      child: Text(
                                        "We'll send you a secure reset code to your email address. "
                                        "Check your inbox and follow the instructions to create a new password",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.032,
                                          fontWeight: FontWeight.normal,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Help section
                Container(
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
                            color: Colors.black,
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
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
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan method OTP untuk reset password
      await _authService.sendPasswordResetOtp(_emailController.text);

      // Navigate to verification screen dengan type reset password
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: _emailController.text,
            type: VerificationType.resetPassword, 
          ),
        ),
      );

      _showSnackBar("Reset code has been sent to your email");
    } on AuthException catch (error) {
      _showSnackBar("Failed to send reset code: ${error.message}");
    } catch (error) {
      _showSnackBar("An error occurred while sending reset code");
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
    _emailController.dispose();
    super.dispose();
  }
}
