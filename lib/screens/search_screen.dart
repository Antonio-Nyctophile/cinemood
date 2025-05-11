import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String userName;
  const SearchScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B22),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Hello ",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        TextSpan(
                          text: "$userName!",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: "\nCheck for latest addition.",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Field
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filters Label
              const Text("Filters", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),

              // Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _FilterIcon(label: "Genre", icon: Icons.category),
                  _FilterIcon(label: "Top IMDB", icon: Icons.star),
                  _FilterIcon(label: "Language", icon: Icons.language),
                  _FilterIcon(label: "Watched", icon: Icons.visibility),
                ],
              ),

              const SizedBox(height: 20),

              // Featured Section
              const Text(
                "Featured Series",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Featured Cards
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _PosterCard(imagePath: 'assets/moneyheist.jpg'),
                    const SizedBox(width: 10),
                    _PosterCard(imagePath: 'assets/sexeducation.jpg'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Filter icon widget
class _FilterIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2A2B33),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// Poster card widget
class _PosterCard extends StatelessWidget {
  final String imagePath;

  const _PosterCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(imagePath, width: 120, height: 180, fit: BoxFit.cover),
    );
  }
}
