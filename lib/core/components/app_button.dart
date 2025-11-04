import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.style,
    this.icon,
    this.borderRadius,
    this.backgroundColor,
  });
  final String title;
  final void Function()? onPressed;
  final TextStyle? style;
  final IconData? icon;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(
        title,
        style:
            style ??
            Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 20)),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
