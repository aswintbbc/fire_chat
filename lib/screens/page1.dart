import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key, this.data});
  final dynamic data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 1'),
      ),
      body: Center(
        child: Text(
          'This is Page 1.$data',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when button is pressed
          Navigator.pop(context); // Navigate back to the previous page
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
