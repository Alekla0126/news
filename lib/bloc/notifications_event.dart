part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
  List<Object> get props => [];
}

class FetchNotifications extends NotificationsEvent {}

class DeleteReadNotifications extends NotificationsEvent {}

class LoadMorePressed extends NotificationsEvent {}

class MarkAllAsRead extends NotificationsEvent {}