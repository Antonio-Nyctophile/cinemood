import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinemood/screens/search_screen.dart';
import 'package:cinemood/screens/watchlist_screen.dart';
import 'package:cinemood/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _homeContent(),
      Container(), // Placeholder for search
      Center(child: Text("Notifications", style: TextStyle(color: Colors.white))),
      WatchlistScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _showMoodSelector() {
    final TextEditingController _moodController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2B33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Type your current mood",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _moodController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "e.g., Excited, Calm, Anxious",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF3A3B47),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: () async {
                  final mood = _moodController.text.trim();
                  if (mood.isNotEmpty) {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .update({'mood': mood, 'mood_updated_at': Timestamp.now()});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Mood set to $mood")),
                    );
                    setState(() {}); // Refresh mood-based section
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moviesBasedOnMood(String mood) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('movies')
          .where('moodTags', arrayContains: mood)
          .limit(10)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No recommendations for this mood.", style: TextStyle(color: Colors.white70)),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return movieCard(data['posterUrl'] ?? 'assets/default.jpg');
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B22),
      body: SafeArea(
        child: _selectedIndex == 1
            ? FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final userName = snapshot.data!['full_name'] ?? 'User';
            return SearchScreen(userName: userName);
          },
        )
            : _screens[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _showMoodSelector,
        child: Icon(Icons.mood),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1B22),
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "CINEMOOD",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/hero.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 20,
                left: 20,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text("Watch Now"),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text("Details"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("For You", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              movieCard('assets/poster1.jpg'),
              movieCard('assets/poster2.jpg'),
              movieCard('assets/poster3.jpg'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Based on your MOOD", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
            }
            final userMood = snapshot.data!['mood'] ?? '';
            if (userMood.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Set your mood to get recommendations!", style: TextStyle(color: Colors.white70)),
              );
            }
            return _moviesBasedOnMood(userMood);
          },
        ),
      ],
    );
  }

  Widget movieCard(String assetPath) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
    );
  }
}
