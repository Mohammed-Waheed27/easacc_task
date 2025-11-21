import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';

abstract class SettingsLocalDataSource {
  Future<String> getWebUrl();
  Future<void> saveWebUrl(String url);
  Future<String?> getSelectedDevice();
  Future<void> saveSelectedDevice(String device, String deviceType);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  @override
  Future<String> getWebUrl() async {
    final url = StorageService.getString(AppConstants.keyWebUrl);
    return url ?? AppConstants.defaultWebUrl;
  }

  @override
  Future<void> saveWebUrl(String url) async {
    await StorageService.setString(AppConstants.keyWebUrl, url);
  }

  @override
  Future<String?> getSelectedDevice() async {
    return StorageService.getString(AppConstants.keySelectedDevice);
  }

  @override
  Future<void> saveSelectedDevice(String device, String deviceType) async {
    await StorageService.setString(AppConstants.keySelectedDevice, device);
    await StorageService.setString(
      '${AppConstants.keySelectedDevice}_type',
      deviceType,
    );
  }

  Future<String?> getDeviceType() async {
    return StorageService.getString('${AppConstants.keySelectedDevice}_type');
  }
}
