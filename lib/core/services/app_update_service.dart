import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {

  Future<void> checkForBackgroundUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability ==
              UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {

        // Start background download
        InAppUpdate.startFlexibleUpdate().then((_) {
          // Try to complete silently after download
          InAppUpdate.completeFlexibleUpdate();
        }).catchError((_) {
          // Ignore all errors
        });
      }
    } catch (_) {
      // Ignore all failures
    }
  }
}
