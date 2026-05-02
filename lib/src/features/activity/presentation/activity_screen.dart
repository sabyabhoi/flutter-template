import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: Center(
        child: Text(
          'Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
