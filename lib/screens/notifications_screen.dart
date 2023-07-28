import '../repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification.dart' as model;
import '../bloc/notifications_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _showFeaturedItemAsNormal = false;

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _showFeaturedItemAsNormal = true;
      });
      context.read<NotificationsBloc>().add(FetchNotifications());
      _refreshController.refreshCompleted();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        // Scrolling down
        if (_scrollController.offset > 200.0 && !_showFeaturedItemAsNormal) {
          setState(() {
            _showFeaturedItemAsNormal = true;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        // Scrolling up
        if (_scrollController.position.extentBefore == 0 && _showFeaturedItemAsNormal) {
          setState(() {
            _showFeaturedItemAsNormal = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsRepository = Provider.of<NotificationsRepository>(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          previousPageTitle: 'Back',
          onPressed: () {
            // Navigator.of(context).pop();
          },
        ),
        middle: const Text('Notifications'),
        trailing: GestureDetector(
          onTap: () {
            context.read<NotificationsBloc>().add(DeleteReadNotifications());
          },
          child: const Text('Mark all read'),
        ),
      ),
      child: BlocProvider(
        create: (context) => NotificationsBloc(notificationsRepository: notificationsRepository)..add(FetchNotifications()),
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsInitial) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state is NotificationsFailure) {
              return const Center(child: Text('Failed to load notifications'));
            } else if (state is NotificationsSuccess) {
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                header: const MaterialClassicHeader(),  // for material design feel
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _showFeaturedItemAsNormal ? state.notifications.length + 3 : state.notifications.length + 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _showFeaturedItemAsNormal ? Container() : _buildFeaturedText();
                    } else if (index == 1 && !_showFeaturedItemAsNormal) {
                      return _buildFeaturedNotification(context, state.notifications[0]);
                    } else if (index == (_showFeaturedItemAsNormal ? 1 : 3)) {
                      return _buildLatestNewsText();
                    } else if (index == (_showFeaturedItemAsNormal ? 0 : 2)) {
                      return const SizedBox(height: 16);
                    } else {
                      return (state.notifications.length > index - (_showFeaturedItemAsNormal ? 3 : 4))
                          ? _buildNotificationItem(context, state.notifications[index - (_showFeaturedItemAsNormal ? 3 : 4)])
                          : Container();  // return empty container when index is out of range
                    }
                  },
                ),
              );
            }
            // fallback widget in case the state doesn't match any of the above
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedText() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        'Featured',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w300,
          letterSpacing: 0.40,
          decoration: TextDecoration.none, // Remove underline
          backgroundColor: Colors.transparent, // Remove background color
        ),
      ),
    );
  }

  Widget _buildFeaturedNotification(BuildContext context, model.Notification notification) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              imagePath: notification.imageUrl,
              title: notification.title,
              htmlBody: notification.body,
            ),
          ),
        );
      },
      child: Card(
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          AspectRatio(
            aspectRatio: 25/9, // Set the aspect ratio of the picture
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(notification.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              notification.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                backgroundColor: Colors.black.withOpacity(0),
              ),
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildLatestNewsText() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        'Latest news',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w300,
          letterSpacing: 0.40,
          decoration: TextDecoration.none, // Remove underline
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, model.Notification notification) {
    // Parse the ISO 8601 date string
    DateTime notificationDate = DateTime.parse(notification.timestamp);

    // Calculate the difference in days from the notification date to the current date
    DateTime currentDate = DateTime.now();
    int daysDifference = currentDate.difference(notificationDate).inDays;

    // Only show the card if the notification is not marked as read
    if (!notification.isRead) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                imagePath: notification.imageUrl,
                title: notification.title,
                htmlBody: notification.body,
              ),
            ),
          );
        },
        child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(notification.imageUrl),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8.0), // Add space between the image and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.32,
                    ),
                  ),
                  Text(
                    // Display the number of days since the notification was made
                    '$daysDifference ${daysDifference == 1 ? 'day ago' : 'days ago'}',
                    style: const TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 12,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),);
    } else {
      // If the notification is marked as read, return an empty container to hide it
      return Container();
    }
  }
}