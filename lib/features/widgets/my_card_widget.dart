import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  const MyCard({
    super.key,
    required this.backgroundColor,
    required this.value,
    this.onTap,
    this.textStyle,
  });

  final Color backgroundColor;
  final String value;
  final void Function()? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            value,
            style:
                textStyle ??
                Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

