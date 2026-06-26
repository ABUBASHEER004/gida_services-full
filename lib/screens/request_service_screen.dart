import 'package:flutter/material.dart';

class RequestServiceScreen extends StatefulWidget {
  final String providerName;

  const RequestServiceScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<RequestServiceScreen> createState() =>
      _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final messageController = TextEditingController();

  void submitRequest() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request Sent ✅"),
        content: Text(
          "Your request to ${widget.providerName} has been sent successfully.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Service"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Request to ${widget.providerName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Your Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitRequest,
                child: const Text("Send Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

