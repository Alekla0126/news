part of 'notifications_bloc.dart';

abstract class NotificationsState {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<Notification> notifications;
  final bool loadMorePressed;
  final bool hasMore;

  NotificationsSuccess({required this.notifications, this.loadMorePressed = false, this.hasMore = false});
}

class NotificationsFailure extends NotificationsState {}