import 'package:flutter/material.dart';
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final message = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text('oi')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('${message.notification?.title}'),
            // Text('${message.notification?.body}'),
            // Text('${message.data}'),
          ],
        ),
      ),
    );
  }
}