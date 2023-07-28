part of '../bloc/notifications_bloc.dart';

abstract class NotificationsState {
  const NotificationsState();

  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsFailure extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<Notification> notifications;

  const NotificationsSuccess({required this.notifications});

  @override
  List<Object> get props => [notifications];
}