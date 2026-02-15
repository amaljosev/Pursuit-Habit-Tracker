import 'package:pursuit/core/constants/app_constants.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  static Future<void> shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            "Track your habits with Pursuit!. Stay consistent and build streaks.\nDownload now:\n${AppConstants.playStoreUrl}",
      ),
    );
  }
}
