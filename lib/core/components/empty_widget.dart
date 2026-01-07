import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.message});
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message ?? 'No files found'));
  }
}
