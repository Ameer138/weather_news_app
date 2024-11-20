import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> favoriteCities = []; // List of favorite cities

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to login screen
  }

  Future<void> _loadFavoriteCities() async {
    final user = _auth.currentUser;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['favoriteCities'] != null) {
          setState(() {
            favoriteCities = List<Map<String, dynamic>>.from(data['favoriteCities']);
          });
        }
      }
    }
  }

  Future<void> _deleteFavoriteCity(Map<String, dynamic> cityData) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Remove the city from Firestore
      await userDoc.update({
        'favoriteCities': FieldValue.arrayRemove([cityData]),
      });

      // Update the local state
      setState(() {
        favoriteCities.remove(cityData);
      });
    }
  }

  void _navigateToWeatherScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WeatherScreen()),
    );

    // Add city to favorites if "Favorite This City" is pressed
    if (result != null) {
      await _saveFavoriteCity(result);
    }
  }

  Future<void> _saveFavoriteCity(Map<String, dynamic> cityData) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.set({
        'favoriteCities': FieldValue.arrayUnion([cityData]),
      }, SetOptions(merge: true));

      setState(() {
        favoriteCities.add(cityData);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Your Favorite Cities",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: favoriteCities.isNotEmpty
                  ? ListView.builder(
                itemCount: favoriteCities.length,
                itemBuilder: (context, index) {
                  final cityData = favoriteCities[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      title: Text(
                        cityData['city'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Temperature: ${cityData['temperature']}°C\nCondition: ${cityData['condition']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteFavoriteCity(cityData);
                        },
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      "No favorite cities yet.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToWeatherScreen,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.blue, // Consistent button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Check Weather",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
