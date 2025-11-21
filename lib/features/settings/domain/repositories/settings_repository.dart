import '../entities/settings_entity.dart';
import '../entities/network_device_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveWebUrl(String url);
  Future<void> saveSelectedDevice(String device, String deviceType);
  Future<List<NetworkDeviceEntity>> getAvailableDevices(String deviceType);
  Future<bool> connectToDevice(NetworkDeviceEntity device);
  Future<bool> disconnectFromDevice(NetworkDeviceEntity device);
}
