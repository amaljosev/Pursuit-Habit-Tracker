import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/profile/profile_screen.dart';

SliverAppBar buildHeader(BuildContext context) {
  return SliverAppBar.large(
    expandedHeight: 200,

    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Colors.transparent,
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
                  fontSize: MediaQuery.of(context).size.width >= 600
                      ? 32
                      : MediaQuery.of(context).size.width * 0.08,
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
    actionsPadding: const EdgeInsets.only(right: 10),
    actions: [
      GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProfileScreen())),
        child: Image.asset(
          'assets/icon/pursuit_icon.png',
          height: 50,
          width: 50,
        ),
      ),
    ],
  );
}
