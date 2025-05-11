import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String? profileImageUrl;
  String userName = "User";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File imageFile = File(picked.path);
      setState(() {
        _profileImage = imageFile;
      });

      try {
        // Upload to Firebase Storage
        String fileName = "${widget.userId}_profile.jpg";
        final storageRef = FirebaseStorage.instance.ref().child('profiles/$fileName');
        await storageRef.putFile(imageFile);
        final downloadUrl = await storageRef.getDownloadURL();

        // Save URL to Firestore
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'profile_pic': downloadUrl,
        });

        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed")));
      }
    }
  }

  Future<void> _loadProfileData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        profileImageUrl = doc.data()?['profile_pic'];
        userName = doc.data()?['full_name'] ?? 'User';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Widget _buildOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.purple,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (profileImageUrl != null
                    ? NetworkImage(profileImageUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png')),
              ),
            ),
            const SizedBox(height: 10),
            Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
              child: const Text("Edit Profiles", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),

            // Options
            _buildOption("Watchlist", () {
              Navigator.pushNamed(context, '/watchlist');
            }),
            _buildOption("App Settings", () {}),
            _buildOption("Account", () {}),
            _buildOption("Legal", () {}),
            _buildOption("Help", () {}),
            _buildOption("Log Out", () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            }),

            const Spacer(),
            const Text("Version 0.0.1", style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
