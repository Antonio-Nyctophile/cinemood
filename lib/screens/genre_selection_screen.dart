import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // Adjust if needed

class GenreSelectionScreen extends StatefulWidget {
  final String userId;

  const GenreSelectionScreen({required this.userId, super.key});

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  List<String> selectedGenres = [];

  final List<String> genres = [
    'Action', 'Drama', 'Mystery', 'Musicals',
    'Fantasy', 'Thriller', 'Comedy', 'Sci-Fi',
    'Adventure', 'Romance', 'Horror', 'Docu-series',
  ];

  Future<void> _submitGenres() async {
    if (selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one genre.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'favourite_genres': selectedGenres,
        'liked_movies': [],
        'watched_movies': [],
        'mood': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preferences saved!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: widget.userId)),
      );


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
        title: const Text("Your Genres"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your favourite genres",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: genres.map((genre) {
                  final isSelected = selectedGenres.contains(genre);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selectedGenres.remove(genre)
                            : selectedGenres.add(genre);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          genre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: selectedGenres.isEmpty ? null : _submitGenres,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("NEXT >>"),
            ),
          ],
        ),
      ),
    );
  }
}
