import 'package:equatable/equatable.dart';

class NetworkDeviceEntity extends Equatable {
  final String id;
  final String name;
  final String type; // 'wifi' or 'bluetooth'
  final String? address; // IP address for WiFi, MAC address for Bluetooth
  final bool isConnected;
  final Map<String, dynamic>? additionalInfo;

  const NetworkDeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.isConnected = false,
    this.additionalInfo,
  });

  NetworkDeviceEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    bool? isConnected,
    Map<String, dynamic>? additionalInfo,
  }) {
    return NetworkDeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    address,
    isConnected,
    additionalInfo,
  ];
}
