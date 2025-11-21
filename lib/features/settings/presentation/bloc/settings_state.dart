part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsDevicesLoaded extends SettingsState {
  final List<NetworkDeviceEntity> devices;

  const SettingsDevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class SettingsDeviceConnecting extends SettingsState {
  final String deviceId;

  const SettingsDeviceConnecting(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class SettingsDeviceConnected extends SettingsState {
  final String deviceId;
  final String deviceName;

  const SettingsDeviceConnected({
    required this.deviceId,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [deviceId, deviceName];
}

class SettingsDeviceDisconnected extends SettingsState {
  final String deviceId;

  const SettingsDeviceDisconnected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

