import 'package:permission_handler/permission_handler.dart' as permission_handler;

class PermissionService {

  Future<bool> requestSmsPermissions() async {
    final smsStatus = await permission_handler.Permission.sms.request();
    return smsStatus.isGranted;
  }

  Future<bool> checkSmsPermissions() async {
    return await permission_handler.Permission.sms.isGranted;
  }

  Future<bool> requestStoragePermissions() async {
    final storageStatus = await permission_handler.Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<bool> checkStoragePermissions() async {
    return await permission_handler.Permission.storage.isGranted;
  }

  Future<bool> requestAllPermissions() async {
    final statuses = await [
      permission_handler.Permission.sms,
      permission_handler.Permission.storage,
      permission_handler.Permission.notification,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<Map<permission_handler.Permission, permission_handler.PermissionStatus>> checkAllPermissions() async {
    return {
      permission_handler.Permission.sms: await permission_handler.Permission.sms.status,
      permission_handler.Permission.storage: await permission_handler.Permission.storage.status,
      permission_handler.Permission.notification: await permission_handler.Permission.notification.status,
    };
  }

  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }
}
