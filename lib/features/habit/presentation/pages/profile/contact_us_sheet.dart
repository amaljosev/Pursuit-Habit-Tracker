import 'package:flutter/material.dart';
import 'package:pursuit/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsSheet extends StatelessWidget {
  const ContactUsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            _buildOptionTile(
              context,
              icon: Icons.rate_review_outlined,
              title: "Feedback",
              subtitle: "Share your experience with us",
              onTap: () {
                Navigator.pop(context);
                _launchEmail(
                  context,
                  subject: 'Pursuit App - General Feedback',
                );
              },
            ),

            _buildOptionTile(
              context,
              icon: Icons.support_agent_outlined,
              title: "Support",
              subtitle: "Need help? Contact support",
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context, subject: 'Pursuit App - Support Request');
              },
            ),

            _buildOptionTile(
              context,
              icon: Icons.bug_report_outlined,
              title: "Bug Report",
              subtitle: "Found a problem? Let us know",
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context, subject: 'Pursuit App - Bug Report');
              },
            ),

            _buildOptionTile(
              context,
              icon: Icons.lightbulb_outline,
              title: "Feature Suggestion",
              subtitle: "Suggest a new feature",
              onTap: () {
                Navigator.pop(context);
                _launchEmail(
                  context,
                  subject: 'Pursuit App - Feature Suggestion',
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(
    BuildContext context, {
    required String subject,
  }) async {
    const String email = AppConstants.supportMail;

    final String encodedSubject = Uri.encodeComponent(subject);
    final Uri emailUri = Uri.parse('mailto:$email?subject=$encodedSubject');

    if (!await launchUrl(emailUri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open mail app')));
    }
  }
}
