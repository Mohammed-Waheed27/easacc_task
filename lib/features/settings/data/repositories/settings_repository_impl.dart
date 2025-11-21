import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/network_device_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/network_device_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<SettingsEntity> getSettings() async {
    final webUrl = await localDataSource.getWebUrl();
    final selectedDevice = await localDataSource.getSelectedDevice();

    return SettingsEntity(webUrl: webUrl, selectedDevice: selectedDevice);
  }

  @override
  Future<void> saveWebUrl(String url) async {
    await localDataSource.saveWebUrl(url);
  }

  @override
  Future<void> saveSelectedDevice(String device, String deviceType) async {
    await localDataSource.saveSelectedDevice(device, deviceType);
  }

  @override
  Future<List<NetworkDeviceEntity>> getAvailableDevices(String deviceType) async {
    if (deviceType == 'wifi') {
      final devices = await remoteDataSource.scanWiFiDevices();
      return devices.map((d) => d.toEntity()).toList();
    } else if (deviceType == 'bluetooth') {
      final devices = await remoteDataSource.scanBluetoothDevices();
      return devices.map((d) => d.toEntity()).toList();
    }
    return [];
  }

  @override
  Future<bool> connectToDevice(NetworkDeviceEntity device) async {
    // Convert entity to model for data source
    final deviceModel = NetworkDeviceModel(
      id: device.id,
      name: device.name,
      type: device.type,
      address: device.address,
      isConnected: device.isConnected,
      additionalInfo: device.additionalInfo,
    );
    return await remoteDataSource.connectToDevice(deviceModel);
  }

  @override
  Future<bool> disconnectFromDevice(NetworkDeviceEntity device) async {
    // Convert entity to model for data source
    final deviceModel = NetworkDeviceModel(
      id: device.id,
      name: device.name,
      type: device.type,
      address: device.address,
      isConnected: device.isConnected,
      additionalInfo: device.additionalInfo,
    );
    return await remoteDataSource.disconnectFromDevice(deviceModel);
  }
}
