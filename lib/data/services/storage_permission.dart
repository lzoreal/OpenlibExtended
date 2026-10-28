// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:openlib/data/services/platform_utils.dart';

Future<void> requestStoragePermission() async {
  // Desktop platforms don't require runtime storage permissions
  if (PlatformUtils.isDesktop) return;

  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  AndroidDeviceInfo android = await plugin.androidInfo;
  // Android < 13
  if (android.version.sdkInt < 33) {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  // Android >= 13
  else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission granted
    } else if (await Permission.manageExternalStorage
        .request()
        .isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.manageExternalStorage.request().isDenied) {
      // Permission denied
    }
  }
}
