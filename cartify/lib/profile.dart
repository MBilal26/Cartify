import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'reset_password.dart';
import 'database_functions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? userAddress;
  String? userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userData = await DatabaseService.instance.getUser(userId!);
      if (userData != null) {
        setState(() {
          userName = userData['name'] ?? 'User';
          userEmail = userData['email'] ?? '';
          userAddress = userData['address'];
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
    } else {
      setState(() {
        userName = "Guest";
        userEmail = "Not logged in";
        _isLoading = false;
      });
    }
  }

  // ===================== ACTIONS (UNCHANGED) =====================

  void _addNewAddress() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please login first'),
        ),
      );
      return;
    }

    final controller = TextEditingController(text: userAddress ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Add Address",
          style: TextStyle(fontFamily: 'IrishGrover'),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () async {
              final newAddress = controller.text.trim();
              if (newAddress.isEmpty) return;

              final success = await DatabaseService.instance.updateUser(
                uid: userId!,
                address: newAddress,
              );

              if (success) {
                setState(() => userAddress = newAddress);
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editProfileDetails() async {
    if (userId == null) return;

    final nameController = TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontFamily: 'IrishGrover'),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () async {
              final success = await DatabaseService.instance.updateUser(
                uid: userId!,
                name: nameController.text.trim(),
              );
              if (success) {
                setState(() => userName = nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    if (userId == null) return;

    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Change Password",
          style: TextStyle(fontFamily: 'IrishGrover'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                "Forgot password?",
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  color: AppColors.textaccent,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () async {
              if (newController.text != confirmController.text) return;

              final user = FirebaseAuth.instance.currentUser;
              final credential = EmailAuthProvider.credential(
                email: userEmail,
                password: currentController.text,
              );

              await user!.reauthenticateWithCredential(credential);
              await user.updatePassword(newController.text);
              await DatabaseService.instance.updateUser(
                uid: userId!,
                password: newController.text,
              );

              Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppGradients.splashBackground,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.background,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          userName,
                          style: TextStyle(
                            fontFamily: 'IrishGrover',
                            fontSize: 26,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontFamily: 'ADLaMDisplay',
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ADDRESS CARD
                  _infoCard(
                    icon: Icons.location_on,
                    title: "Delivery Address",
                    subtitle: userAddress ?? "No address added yet",
                  ),

                  const SizedBox(height: 30),

                  // ACTIONS
                  _actionTile(
                    Icons.add_location_alt,
                    "Add New Address",
                    _addNewAddress,
                  ),
                  _actionTile(
                    Icons.edit,
                    "Edit Profile Details",
                    _editProfileDetails,
                  ),
                  _actionTile(Icons.lock, "Change Password", _changePassword),

                  const SizedBox(height: 40),

                  _authPillButton(
                    text: "Logout",
                    icon: Icons.logout,
                    backgroundColor: AppColors.error,
                    textColor: Colors.white,
                    onTap: _logout,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontFamily: 'ADLaMDisplay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== BUTTON =====================

Widget _authPillButton({
  required String text,
  required IconData icon,
  required Color backgroundColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: 170,
    height: 46,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: textColor),
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'ADLaMDisplay',
          fontSize: 16,
          color: textColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    ),
  );
}
