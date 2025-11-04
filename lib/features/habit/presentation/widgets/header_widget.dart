import 'package:flutter/material.dart';

SliverAppBar buildHeader(Size size, BuildContext context) {
  return SliverAppBar.large(
    expandedHeight: size.height * 0.2,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    flexibleSpace: FlexibleSpaceBar(
      background: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Goals',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                'for today',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: size.width * 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
      expandedTitleScale: 1.0,
      stretchModes: const [StretchMode.zoomBackground],
    ),
    title: Text(
      'Small steps, big results. Keep going!',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    elevation: 0,
    pinned: true,
  );
}