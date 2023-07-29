import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'dart:convert';

class NotificationsRepository {
  List<Notification> notifications = [];
  List<Notification> readNotifications = []; // Assuming this is defined somewhere

  Future<List<Notification>> fetchNotifications() async {
    final response = await http.get(Uri.parse('https://run.mocky.io/v3/71a538e3-e154-4cb3-a38c-17077122fe23'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      notifications = jsonResponse
          .asMap()
          .entries
          .map((entry) => Notification.fromJson(entry.key.toString(), entry.value))
          .toList();
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<Notification>> fetchMoreNotifications() async {
    // Simulating fetch more by reusing the same endpoint
    final response = await http.get(Uri.parse('https://run.mocky.io/v3/71a538e3-e154-4cb3-a38c-17077122fe23'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Notification> moreNotifications = jsonResponse
          .asMap()
          .entries
          .map((entry) => Notification.fromJson(entry.key.toString(), entry.value))
          .toList();
      notifications.addAll(moreNotifications);
      return notifications;
    } else {
      throw Exception('Failed to load more notifications');
    }
  }

  void deleteReadNotifications() {
    // Move read notifications to the list of read notifications
    readNotifications.addAll(notifications.where((notification) => notification.isRead));

    // Remove read notifications from the list of notifications
    notifications.removeWhere((notification) => notification.isRead);
  }
}