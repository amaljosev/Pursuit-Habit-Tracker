import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

class InputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final GlobalKey<FormState> formKey;

  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.color,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,

      cursorColor: color,
      decoration: InputDecoration.collapsed(
        hintText: 'New Goal',
        hintStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.black38,
        ),
      ),
      keyboardType: TextInputType.name,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium!.copyWith(color: Colors.black),
      maxLength: 40,
      maxLines: null,
      cursorWidth: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a habit name';
        }
        return null;
      },
      onFieldSubmitted: (value) => formKey.currentState!.validate()
          ? context.read<HabitBloc>().add(HabitNameEvent(name: value))
          : null,
      errorBuilder: (context, errorText) {
        return Center(
          child: Text(
            errorText,
            style: Theme.of(
              context,
            ).textTheme.titleSmall,
          ),
        );
      },
    );
  }
}
