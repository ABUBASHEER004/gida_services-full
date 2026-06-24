import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final Map<String, String> provider;

  const ProviderDetailsScreen({
    super.key,
    required this.provider,
  });

  // 📞 CALL FUNCTION
  Future<void> callProvider(String phone) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 💬 WHATSAPP FUNCTION (FIXED FORMAT)
  Future<void> openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    final Uri uri = Uri.parse(
      "https://wa.me/$cleanPhone",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = provider["name"] ?? "Unknown";
    final category = provider["category"] ?? "Unknown";
    final phone = provider["phone"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text("Category: $category"),

            const SizedBox(height: 10),

            Text("Phone: $phone"),

            const SizedBox(height: 20),

            // 📞 CALL BUTTON
            ElevatedButton.icon(
              onPressed: () => callProvider(phone),
              icon: const Icon(Icons.call),
              label: const Text("Call Provider"),
            ),

            const SizedBox(height: 10),

            // 💬 WHATSAPP BUTTON
            ElevatedButton.icon(
              onPressed: () => openWhatsApp(phone),
              icon: const Icon(Icons.chat),
              label: const Text("Chat on WhatsApp"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
