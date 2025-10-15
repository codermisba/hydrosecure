import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components.dart';

class ProfilePage extends StatelessWidget {
 

  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user data found"));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600; // breakpoint

              return SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 700,
                    ), // ✅ prevent stretching on wide
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Header
                          isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildAvatar(context, user, data),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ??
                                                "Unknown",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            data['email'] ??
                                                "No Email",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildAvatar(context, user, data),
                                    const SizedBox(height: 16),
                                    Text(
                                      data['name'] ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data['email'] ?? "No Email",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 32),

                          // Settings Section
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: Icon(
                                Icons.settings,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text("Settings"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(height: 16),

                         
                          const SizedBox(height: 40),
                          customButton(
                            "Logout",
                            () => _logout(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildAvatar(
    BuildContext context,
    User user,
    Map<String, dynamic> data,
  ) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).primaryColor,
      backgroundImage:
          (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty)
          ? NetworkImage(data['photoUrl'])
          : (user.photoURL != null ? NetworkImage(user.photoURL!) : null),
      child:
          (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty) &&
              user.photoURL == null
          ? Text(
              (data['name'] != null && data['name'].toString().isNotEmpty)
                  ? data['name'][0].toUpperCase()
                  : (user.email != null && user.email!.isNotEmpty
                        ? user.email![0].toUpperCase()
                        : "?"),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

}