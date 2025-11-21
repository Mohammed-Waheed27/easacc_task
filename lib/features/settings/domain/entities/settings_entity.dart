import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String webUrl;
  final String? selectedDevice;
  final String? deviceType; // 'wifi' or 'bluetooth'

  const SettingsEntity({
    required this.webUrl,
    this.selectedDevice,
    this.deviceType,
  });

  SettingsEntity copyWith({
    String? webUrl,
    String? selectedDevice,
    String? deviceType,
  }) {
    return SettingsEntity(
      webUrl: webUrl ?? this.webUrl,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      deviceType: deviceType ?? this.deviceType,
    );
  }

  @override
  List<Object?> get props => [webUrl, selectedDevice, deviceType];
}

