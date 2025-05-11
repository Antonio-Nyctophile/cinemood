import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinemood/screens/home_screen.dart'; // Your actual HomeScreen file

class LoginFormScreen extends StatefulWidget {
  @override
  _LoginFormScreenState createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // ✅ Only this navigation is needed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userId: _auth.currentUser!.uid),
          ),
        );

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }

      setState(() => isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController(text: emailController.text);
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2A2B33),
          title: Text("Reset Password", style: TextStyle(color: Colors.white)),
          content: Form(
            key: _dialogFormKey,
            child: TextFormField(
              controller: emailResetController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                } else if (!value.contains('@')) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_dialogFormKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailResetController.text.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password reset email sent.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                }
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Email", emailController, TextInputType.emailAddress),
              buildTextField("Password", passwordController, TextInputType.text, true),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text("Forgot Password?", style: TextStyle(color: Colors.white70)),
                ),
              ),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, TextInputType type, [bool obscure = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
      ),
    );
  }
}
