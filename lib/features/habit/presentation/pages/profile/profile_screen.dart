import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/profile/help_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset(
                'assets/icon/pursuit_icon.png',
                height: 80,
                width: 80,
              ),
              Text(
                'Pursuit',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900),
              ),

              CupertinoListSection.insetGrouped(
                children: [
                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: Text('Help'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpScreen()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacy Policy'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () async => await _launchUrl(context),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text('About this app'),
                      trailing: const CupertinoListTileChevron(),
                      childrenPadding: const EdgeInsets.all(12),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About Pursuit',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            Text(
                              'Pursuit is a simple and focused habit-tracking application designed to help users build consistency, maintain streaks, and stay committed to their personal goals.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'The app works entirely offline using a local database. No internet connection is required, and no user data is shared or transmitted to third parties.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Key Features',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              '• Create and manage daily habits',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Track streaks and habit continuity',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• View insights such as most active days',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Visual progress tracking using charts',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Habit reminders through notifications',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Data & Privacy',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              '• All data is stored locally on your device',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• No third-party data sharing',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• No internet access required',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• No user data is collected or transmitted',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Technology',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              '• Built with Flutter',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Uses packages from pub.dev',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Progress visualization powered by fl_chart',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'App Information',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Version: 1.0.0',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Developer',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Developed by Amal Jose',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Contact: amaljosevofficial@gmail.com',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ListTile(
                  //   leading: const Icon(Icons.favorite_border),
                  //   title: Text('Rate us'),
                  //   trailing: const CupertinoListTileChevron(),
                  // ),
                ],
              ),

              // CupertinoListSection.insetGrouped(
              //   children: [
              //     ListTile(
              //       leading: const Icon(Icons.notifications_none),
              //       title: Text('Notification'),
              //       trailing: Switch.adaptive(
              //         value: isActive,
              //         onChanged: (value) => context.read<HabitBloc>().add(
              //           CancelAllHabitNotificationsEvent(!isActive),
              //         ),

              //       ),
              //     ),

              //     ListTile(
              //       leading: const Icon(Icons.share_outlined),
              //       title: Text('Share this app'),
              //       trailing: const CupertinoListTileChevron(),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final Uri _url = Uri.parse(
      'https://amaljosev.github.io/Pursuit-Privacy-Policy/',
    );
    if (!await launchUrl(_url, mode: LaunchMode.inAppBrowserView)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sorry we are facing an issue')));
    }
  }
}
