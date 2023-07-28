import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'dart:convert';

class NotificationsRepository {
  List<Notification> notifications = []; // List of notifications
  List<Notification> readNotifications = []; // List of read notifications

  Future<List<Notification>> fetchNotifications() async {
    final response =
    await http.get(Uri.parse('https://run.mocky.io/v3/71a538e3-e154-4cb3-a38c-17077122fe23'));

    // print('Status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .asMap()
          .entries
          .map((entry) => Notification.fromJson(entry.key.toString(), entry.value))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Method to delete read notifications
  void deleteReadNotifications() {
    // Move read notifications to the list of read notifications
    readNotifications.addAll(notifications.where((notification) => notification.isRead));

    // Remove read notifications from the list of notifications
    notifications.removeWhere((notification) => notification.isRead);
  }
}