import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hydrosecure/theme.dart';
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
     appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 3,
      ),
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
      Icons.admin_panel_settings,
      color: Theme.of(context).primaryColor,
    ),
    title: const Text("User Role"),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () {
      // Show a dialog to select role
      showDialog(
        context: context,
        builder: (context) {
          String selectedRole = data['role'] ?? 'Public';
          return AlertDialog(
            title: const Text("Select User Role"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text("Supervisor"),
                  value: "Supervisor",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.data!.docs.first.id)
                          .update({'role': value});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role updated to $value')),
                      );
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Officer"),
                  value: "Officer",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.data!.docs.first.id)
                          .update({'role': value});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role updated to $value')),
                      );
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Public/Individual"),
                  value: "Public",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.data!.docs.first.id)
                          .update({'role': value});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role updated to $value')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
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