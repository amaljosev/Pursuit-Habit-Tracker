import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/info/help_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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

                  // ListTile(
                  //   leading: const Icon(Icons.favorite_border),
                  //   title: Text('Rate us'),
                  //   trailing: const CupertinoListTileChevron(),
                  // ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacy Policy'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text('Terms and Conditions'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                    trailing: const CupertinoListTileChevron(),
                    // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen(),)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('About this app'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.share_outlined),
                  //   title: Text('Share this app'),
                  //   trailing: const CupertinoListTileChevron(),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
