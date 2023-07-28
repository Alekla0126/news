import 'package:news/repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'bloc/notifications_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final NotificationsRepository notificationsRepository = NotificationsRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationsRepository>(
          create: (context) => notificationsRepository,
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
            notificationsRepository: context.read<NotificationsRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Notifications',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NotificationsPage(),
      ),
    );
  }
}