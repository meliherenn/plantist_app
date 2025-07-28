import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantist_app/screens/TodoListPage.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  Flushbar? currentFlushbar;
  bool isFlushbarVisible = false;

  bool isEmailValid = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    emailController.addListener(_validateEmail);
    passwordController.addListener(_updateState);
  }

  void _validateEmail() {
    final email = emailController.text;
    setState(() {
      isEmailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
    });
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid => isEmailValid && passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    "Sign in with email",
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Enter your email and password",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 32.h),

                  // E-mail
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: const UnderlineInputBorder(),
                      suffixIcon: isEmailValid
                          ? const Icon(Icons.check_circle, color: Colors.black)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(fontSize: 13.sp, color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Sign In butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isFormValid
                          ? () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          if (!isFlushbarVisible) {
                            setState(() => isFlushbarVisible = true);

                            currentFlushbar = Flushbar(
                              title: "Login Successful",
                              message: "You are transferred to the to-do page",
                              backgroundColor: Colors.green,
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                              borderRadius: BorderRadius.circular(75.0),
                              duration: const Duration(seconds: 1),
                              margin: const EdgeInsets.all(50),
                              flushbarPosition: FlushbarPosition.BOTTOM,
                            );

                            await currentFlushbar!.show(context);

                            if (mounted) {
                              setState(() => isFlushbarVisible = false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TodoListPage()),
                              );
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          if (!isFlushbarVisible) {
                            setState(() => isFlushbarVisible = true);

                            currentFlushbar = Flushbar(
                              title: "Login Failed!",
                              message: e.message ?? "Unknown error",
                              backgroundColor: Colors.black,
                              icon: const Icon(Icons.error, color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(75.0),
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(75),
                              flushbarPosition: FlushbarPosition.BOTTOM,
                            );

                            await currentFlushbar!.show(context);
                            if (mounted) {
                              setState(() => isFlushbarVisible = false);
                            }
                          }
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid ? Colors.black : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                        children: const [
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Use.',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
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
