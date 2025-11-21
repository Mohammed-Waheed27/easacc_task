part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateWebUrl extends SettingsEvent {
  final String url;

  const UpdateWebUrl(this.url);

  @override
  List<Object?> get props => [url];
}

class LoadAvailableDevices extends SettingsEvent {
  final String deviceType; // 'wifi' or 'bluetooth'

  const LoadAvailableDevices(this.deviceType);

  @override
  List<Object?> get props => [deviceType];
}

class SelectDevice extends SettingsEvent {
  final String device;
  final String deviceType;

  const SelectDevice({
    required this.device,
    required this.deviceType,
  });

  @override
  List<Object?> get props => [device, deviceType];
}

class ConnectToDevice extends SettingsEvent {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? deviceAddress;

  const ConnectToDevice({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.deviceAddress,
  });

  @override
  List<Object?> get props => [deviceId, deviceName, deviceType, deviceAddress];
}

class DisconnectFromDevice extends SettingsEvent {
  final String deviceId;

  const DisconnectFromDevice({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

