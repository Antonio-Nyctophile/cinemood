import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool agreeToTerms = false;

  // Form Fields
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final List<String> genders = ['Male', 'Female', 'Other'];


  String? selectedCountry;
  String? selectedLanguage;
  String? selectedGender;

  final List<String> countries = ['Jamaica', 'USA', 'Canada', 'UK', 'Trinidad', 'India', 'Nigeria', 'Kenya', 'Brazil', 'Germany'];
  final List<String> languages = ['English', 'Spanish', 'French', 'Hindi', 'Mandarin', 'Swahili', 'Arabic', 'Portuguese'];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.dispose();
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        agreeToTerms &&
        selectedGender != null &&
        selectedCountry != null &&
        selectedLanguage != null) {
      try {
        // Auth signup
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'full_name': fullNameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'dob': dobController.text.trim(),
          'country': selectedCountry,
          'language': selectedLanguage,
          'gender': selectedGender,
          'agreedToTerms': agreeToTerms,
          'created_at': Timestamp.now(),
        });




        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Successful!")),
        );

        // TODO: Navigate to login or home screen

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Signup failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all required fields")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Full Name", controller: fullNameController),
              buildTextField("Username", controller: usernameController),
              buildTextField("Email", controller: emailController, keyboardType: TextInputType.emailAddress),
              buildTextField("Password", controller: passwordController, obscureText: true),
              buildTextField("Date of Birth", controller: dobController, hint: "YYYY-MM-DD"),

              dropdownField("Country/Region", selectedCountry, countries, (value) => setState(() => selectedCountry = value)),
              dropdownField("Preferred Language", selectedLanguage, languages, (value) => setState(() => selectedLanguage = value)),

              const SizedBox(height: 16),
              genderSelector(),

              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    activeColor: Colors.purple,
                    onChanged: (value) {
                      setState(() {
                        agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "I agree to have my data securely stored in a database to receive personalized suggestions.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Create Account"),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back to Login", style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label,
      {TextEditingController? controller,
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
        String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
      ),
    );
  }

  Widget dropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Color(0xFF2A2B33),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      ),
    );
  }

  Widget genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dropdownField(
          "Gender",
          selectedGender,
          genders,
              (value) => setState(() => selectedGender = value),
        ),
      ],
    );
  }

}
