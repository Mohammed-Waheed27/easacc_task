import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../../../core/utils/pretty_logger.dart';
import '../models/network_device_model.dart';

abstract class SettingsRemoteDataSource {
  Future<List<NetworkDeviceModel>> scanWiFiDevices();
  Future<List<NetworkDeviceModel>> scanBluetoothDevices();
  Future<bool> connectToDevice(NetworkDeviceModel device);
  Future<bool> disconnectFromDevice(NetworkDeviceModel device);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  Future<List<NetworkDeviceModel>> scanWiFiDevices() async {
    PrettyLogger.info(
      'Starting WiFi device scan',
      tag: 'SettingsRemoteDataSource',
    );

    try {
      // Get current WiFi network info
      final wifiName = await _networkInfo.getWifiName();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiBSSID = await _networkInfo.getWifiBSSID();

      PrettyLogger.debug(
        'WiFi network info',
        data: {'name': wifiName, 'ip': wifiIP, 'bssid': wifiBSSID},
        tag: 'SettingsRemoteDataSource',
      );

      // For WiFi, we'll scan the local network for common printer ports and network devices
      // This is a simplified approach - in production, you'd use proper network scanning
      final devices = <NetworkDeviceModel>[];

      if (wifiIP != null) {
        // Extract network base (e.g., 192.168.1.x)
        final ipParts = wifiIP.split('.');
        if (ipParts.length == 4) {
          final baseIP = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';

          // Common printer ports
          final printerPorts = [9100, 515, 631]; // Raw, LPR, IPP
          // Common device ports
          final devicePorts = [80, 443, 8080, 5000]; // HTTP, HTTPS, Web servers

          // Scan common IPs in the network (scan first 20 IPs for better coverage)
          for (int i = 1; i <= 20; i++) {
            final testIP = '$baseIP.$i';

            // Skip scanning the device's own IP
            if (testIP == wifiIP) continue;

            // Check printer ports
            for (final port in printerPorts) {
              try {
                final socket = await Socket.connect(
                  testIP,
                  port,
                  timeout: const Duration(milliseconds: 300),
                );
                socket.destroy();

                String deviceName = 'Network Printer';
                if (port == 9100) {
                  deviceName = 'Raw Printer';
                } else if (port == 515) {
                  deviceName = 'LPR Printer';
                } else if (port == 631) {
                  deviceName = 'IPP Printer';
                }

                devices.add(
                  NetworkDeviceModel(
                    id: 'wifi_$testIP:$port',
                    name: '$deviceName ($testIP:$port)',
                    type: 'wifi',
                    address: '$testIP:$port',
                    isConnected: false,
                    additionalInfo: {
                      'port': port,
                      'ip': testIP,
                      'deviceType': 'printer',
                    },
                  ),
                );

                PrettyLogger.debug(
                  'Found WiFi printer device',
                  data: {'ip': testIP, 'port': port, 'name': deviceName},
                  tag: 'SettingsRemoteDataSource',
                );
              } catch (e) {
                // Device not reachable on this port, continue
              }
            }

            // Check common device ports (web servers, IoT devices)
            for (final port in devicePorts) {
              try {
                final socket = await Socket.connect(
                  testIP,
                  port,
                  timeout: const Duration(milliseconds: 300),
                );
                socket.destroy();

                String deviceName = 'Network Device';
                if (port == 80 || port == 443) {
                  deviceName = 'Web Server';
                } else if (port == 8080) {
                  deviceName = 'Web Service';
                } else if (port == 5000) {
                  deviceName = 'Network Device';
                }

                devices.add(
                  NetworkDeviceModel(
                    id: 'wifi_$testIP:$port',
                    name: '$deviceName ($testIP:$port)',
                    type: 'wifi',
                    address: '$testIP:$port',
                    isConnected: false,
                    additionalInfo: {
                      'port': port,
                      'ip': testIP,
                      'deviceType': 'network',
                    },
                  ),
                );

                PrettyLogger.debug(
                  'Found WiFi network device',
                  data: {'ip': testIP, 'port': port, 'name': deviceName},
                  tag: 'SettingsRemoteDataSource',
                );
              } catch (e) {
                // Device not reachable on this port, continue
              }
            }
          }
        }
      }

      // Add current network as a device option
      if (wifiName != null && wifiName.isNotEmpty) {
        devices.insert(
          0,
          NetworkDeviceModel(
            id: 'wifi_network',
            name: 'WiFi Network: ${wifiName.replaceAll('"', '')}',
            type: 'wifi',
            address: wifiIP,
            isConnected: true,
            additionalInfo: {'bssid': wifiBSSID, 'ip': wifiIP},
          ),
        );
      }

      PrettyLogger.success(
        'WiFi device scan completed',
        data: {'deviceCount': devices.length},
        tag: 'SettingsRemoteDataSource',
      );

      return devices;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Error scanning WiFi devices',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsRemoteDataSource',
      );
      return [];
    }
  }

  @override
  Future<List<NetworkDeviceModel>> scanBluetoothDevices() async {
    PrettyLogger.info(
      'Starting Bluetooth device scan',
      tag: 'SettingsRemoteDataSource',
    );

    try {
      // Check if Bluetooth is available
      if (await FlutterBluePlus.isSupported == false) {
        PrettyLogger.warning(
          'Bluetooth is not supported on this device',
          tag: 'SettingsRemoteDataSource',
        );
        return [];
      }

      // Check if Bluetooth is on
      if (await FlutterBluePlus.isOn == false) {
        PrettyLogger.warning(
          'Bluetooth is turned off. Please enable Bluetooth in settings.',
          tag: 'SettingsRemoteDataSource',
        );
        return [];
      }

      // Use a Completer to wait for scan results
      final devices = <NetworkDeviceModel>[];
      final deviceMap = <String, NetworkDeviceModel>{};

      // Start scanning with longer timeout for better discovery
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true, // Required for Android 6.0+
      );

      // Listen to scan results with a stream subscription
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final device = result.device;

          // Get device name - prefer platform name, fallback to advertisement name, then ID
          String deviceName = device.platformName.isNotEmpty
              ? device.platformName
              : (result.advertisementData.advName.isNotEmpty
                    ? result.advertisementData.advName
                    : device.remoteId.toString());

          // Skip if device name is empty or just the ID
          if (deviceName.isEmpty || deviceName == device.remoteId.toString()) {
            deviceName =
                'Unknown Device (${device.remoteId.toString().substring(0, 8)}...)';
          }

          final deviceId = device.remoteId.toString();

          // Update or add device (update if RSSI is stronger)
          if (!deviceMap.containsKey(deviceId) ||
              (deviceMap[deviceId]?.additionalInfo?['rssi'] as int? ?? -200) <
                  result.rssi) {
            deviceMap[deviceId] = NetworkDeviceModel(
              id: deviceId,
              name: deviceName,
              type: 'bluetooth',
              address: deviceId,
              isConnected: false,
              additionalInfo: {
                'rssi': result.rssi,
                'platformName': device.platformName,
                'advName': result.advertisementData.advName,
                'txPowerLevel': result.advertisementData.txPowerLevel,
                'connectable': result.advertisementData.connectable,
                'manufacturerData': result.advertisementData.manufacturerData
                    .toString(),
              },
            );

            PrettyLogger.debug(
              'Found Bluetooth device',
              data: {
                'name': deviceName,
                'id': deviceId,
                'rssi': result.rssi,
                'connectable': result.advertisementData.connectable,
              },
              tag: 'SettingsRemoteDataSource',
            );
          }
        }
      });

      // Wait for scan to complete (15 seconds)
      await Future.delayed(const Duration(seconds: 15));

      // Convert map to list and sort by RSSI (strongest signal first)
      devices.addAll(deviceMap.values);
      devices.sort((a, b) {
        final rssiA = a.additionalInfo?['rssi'] as int? ?? -200;
        final rssiB = b.additionalInfo?['rssi'] as int? ?? -200;
        return rssiB.compareTo(rssiA); // Higher RSSI (closer) first
      });

      await subscription.cancel();
      await FlutterBluePlus.stopScan();

      PrettyLogger.success(
        'Bluetooth device scan completed',
        data: {
          'deviceCount': devices.length,
          'devices': devices.map((d) => d.name).toList(),
        },
        tag: 'SettingsRemoteDataSource',
      );

      return devices;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Error scanning Bluetooth devices',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsRemoteDataSource',
      );
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {
        // Ignore errors when stopping scan
      }
      return [];
    }
  }

  @override
  Future<bool> connectToDevice(NetworkDeviceModel device) async {
    PrettyLogger.info(
      'Connecting to device',
      data: {'deviceId': device.id, 'deviceName': device.name},
      tag: 'SettingsRemoteDataSource',
    );

    try {
      if (device.type == 'bluetooth') {
        // Connect to Bluetooth device
        final bluetoothDevice = BluetoothDevice.fromId(device.id);
        await bluetoothDevice.connect(timeout: const Duration(seconds: 15));

        PrettyLogger.success(
          'Connected to Bluetooth device',
          data: {'deviceName': device.name},
          tag: 'SettingsRemoteDataSource',
        );
        return true;
      } else if (device.type == 'wifi') {
        // For WiFi, test connection by attempting to connect to the address
        if (device.address != null) {
          final parts = device.address!.split(':');
          if (parts.length == 2) {
            final ip = parts[0];
            final port = int.tryParse(parts[1]);
            if (port != null) {
              try {
                final socket = await Socket.connect(
                  ip,
                  port,
                  timeout: const Duration(seconds: 5),
                );
                socket.destroy();

                PrettyLogger.success(
                  'Connected to WiFi device',
                  data: {'address': device.address},
                  tag: 'SettingsRemoteDataSource',
                );
                return true;
              } catch (e) {
                PrettyLogger.warning(
                  'Failed to connect to WiFi device',
                  data: {'error': e.toString()},
                  tag: 'SettingsRemoteDataSource',
                );
                return false;
              }
            }
          }
        }
      }

      return false;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Error connecting to device',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsRemoteDataSource',
      );
      return false;
    }
  }

  @override
  Future<bool> disconnectFromDevice(NetworkDeviceModel device) async {
    PrettyLogger.info(
      'Disconnecting from device',
      data: {'deviceId': device.id},
      tag: 'SettingsRemoteDataSource',
    );

    try {
      if (device.type == 'bluetooth') {
        final bluetoothDevice = BluetoothDevice.fromId(device.id);
        await bluetoothDevice.disconnect();

        PrettyLogger.success(
          'Disconnected from Bluetooth device',
          data: {'deviceName': device.name},
          tag: 'SettingsRemoteDataSource',
        );
        return true;
      }

      // WiFi devices don't need explicit disconnection
      return true;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Error disconnecting from device',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsRemoteDataSource',
      );
      return false;
    }
  }
}
