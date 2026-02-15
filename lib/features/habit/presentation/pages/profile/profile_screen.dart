import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/core/constants/app_constants.dart';
import 'package:pursuit/core/constants/app_version.dart';
import 'package:pursuit/core/utils/share_utils.dart';
import 'package:pursuit/features/habit/presentation/pages/profile/contact_us_sheet.dart';
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
        child: CustomScrollView(
          slivers: [
            /// Top Logo + Title
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/icon/pursuit_icon.png',
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pursuit',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            /// Main List Section
            SliverList(
              delegate: SliverChildListDelegate([
                /// APP INFORMATION
                CupertinoListSection.insetGrouped(
                  header: const Text('App'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: const Text('Help'),
                      titleTextStyle: Theme.of(context).textTheme.titleSmall,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: const Text('Privacy Policy'),
                      titleTextStyle: Theme.of(context).textTheme.titleSmall,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () async => await _lunchPrivacyPolicy(context),
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
                        title: Text(
                          'About this app',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        trailing: const CupertinoListTileChevron(),
                        childrenPadding: const EdgeInsets.all(12),
                        children: [_buildAboutContent(context)],
                      ),
                    ),
                  ],
                ),

                /// ENGAGEMENT
                CupertinoListSection.insetGrouped(
                  header: const Text('Engagement'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share'),
                      titleTextStyle: Theme.of(context).textTheme.titleSmall,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () async {
                        await ShareUtils.shareApp();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star_border),
                      title: const Text('Rate app'),
                      titleTextStyle: Theme.of(context).textTheme.titleSmall,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () async => await _rateApp(context),
                    ),
                  ],
                ),

                /// SUPPORT
                CupertinoListSection.insetGrouped(
                  header: const Text('Support'),
                  children: [
                    ListTile(
                      leading: const Icon(CupertinoIcons.mail),
                      title: const Text('Contact us'),
                      titleTextStyle: Theme.of(context).textTheme.titleSmall,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () async => showModernSupportSheet(context),
                    ),
                  ],
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Pursuit',
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Text(
          'Pursuit is a simple and focused habit-tracking application designed to help users build consistency, maintain streaks, and stay committed to their personal goals.',
          style: textTheme.bodyMedium,
        ),

        const SizedBox(height: 16),

        Text('Version: ${AppVersion.version}', style: textTheme.bodyMedium),

        const SizedBox(height: 12),

        Text('Developed by Amal Jose', style: textTheme.bodyMedium),
      ],
    );
  }

  Future<void> _lunchPrivacyPolicy(BuildContext context) async {
    final Uri _url = Uri.parse(
      'https://amaljosev.github.io/Pursuit-Privacy-Policy/',
    );
    if (!await launchUrl(_url, mode: LaunchMode.inAppBrowserView)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sorry we are facing an issue')));
    }
  }

  Future<void> _rateApp(BuildContext context) async {
    final Uri _url = Uri.parse(AppConstants.playStoreUrl);
    if (!await launchUrl(_url, mode: LaunchMode.platformDefault)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sorry we are facing an issue')));
    }
  }

  void showModernSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const ContactUsSheet();
      },
    );
  }
}
