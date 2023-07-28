import 'package:news/repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/models/notification.dart';
part 'notifications_states.dart';
part 'notifications_event.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository notificationsRepository;

  NotificationsBloc({required this.notificationsRepository})
      : super(NotificationsInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<DeleteReadNotifications>(_onDeleteReadNotifications);
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event,
      Emitter<NotificationsState> emit,
      ) async {
    try {
      final List<Notification> notifications = await notificationsRepository.fetchNotifications();
      emit(NotificationsSuccess(notifications: notifications));
    } catch (_) {
      emit(NotificationsFailure());
    }
  }

  Future<void> _onDeleteReadNotifications(
      DeleteReadNotifications event,
      Emitter<NotificationsState> emit,
      ) async {
    try {
      notificationsRepository.deleteReadNotifications();
      final List<Notification> notifications = [...notificationsRepository.notifications]; // make sure to create a new list
      emit(NotificationsSuccess(notifications: notifications));
    } catch (_) {
      emit(NotificationsFailure());
    }
  }
}