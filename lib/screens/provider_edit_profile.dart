import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderEditProfile extends StatefulWidget {
  final String providerId;

  const ProviderEditProfile({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderEditProfile> createState() => _ProviderEditProfileState();
}

class _ProviderEditProfileState extends State<ProviderEditProfile> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final serviceController = TextEditingController();

  bool loading = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(widget.providerId)
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    setState(() {
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      serviceController.text = data['service'] ?? '';
      initialized = true;
    });
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('providers')
        .doc(widget.providerId)
        .set({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'service': serviceController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => loading = false);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully ✅")),
    );
  }

  // =========================
  // BOTTOM SHEET EDIT (NEW)
  // =========================
  void openEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: serviceController,
                decoration: const InputDecoration(
                  labelText: "Service Type",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        child: const Text("Save Changes"),
                      ),
                    ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: openEditBottomSheet, // ✅ BUTTON ADDED HERE
          )
        ],
      ),

      body: initialized
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Name: ${nameController.text}"),
                  const SizedBox(height: 10),

                  Text("Phone: ${phoneController.text}"),
                  const SizedBox(height: 10),

                  Text("Service: ${serviceController.text}"),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      onPressed: openEditBottomSheet, // ✅ MAIN BUTTON
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
