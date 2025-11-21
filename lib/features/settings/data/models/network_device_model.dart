import '../../domain/entities/network_device_entity.dart';

class NetworkDeviceModel extends NetworkDeviceEntity {
  const NetworkDeviceModel({
    required super.id,
    required super.name,
    required super.type,
    super.address,
    super.isConnected,
    super.additionalInfo,
  });

  factory NetworkDeviceModel.fromJson(Map<String, dynamic> json) {
    return NetworkDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String?,
      isConnected: json['isConnected'] as bool? ?? false,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'isConnected': isConnected,
      'additionalInfo': additionalInfo,
    };
  }

  NetworkDeviceEntity toEntity() {
    return NetworkDeviceEntity(
      id: id,
      name: name,
      type: type,
      address: address,
      isConnected: isConnected,
      additionalInfo: additionalInfo,
    );
  }
}
