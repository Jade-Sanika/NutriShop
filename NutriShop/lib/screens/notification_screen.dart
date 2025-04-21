import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Meal Plan Reminder",
      "subtitle": "Don't forget to check your 2000-calorie meal plan today!"
    },
    {
      "title": "New Nutrient Tip",
      "subtitle":
          "Vitamin D is crucial for bone health. Check out rich sources!"
    },
    {
      "title": "Hydration Alert",
      "subtitle": "Stay hydrated! Aim for 8 glasses of water today."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xff4caf50),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: const Icon(
              Icons.notifications,
              color: Color(0xff4caf50),
            ),
            title: Text(
              notification['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(notification['subtitle']!),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Optionally handle tap (e.g., open full detail)
            },
          );
        },
      ),
    );
  }
}
