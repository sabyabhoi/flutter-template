import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Center(
        child: Text(
          'Services',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
