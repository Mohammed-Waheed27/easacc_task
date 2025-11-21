import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/network_device_entity.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateWebUrl>(_onUpdateWebUrl);
    on<LoadAvailableDevices>(_onLoadAvailableDevices);
    on<SelectDevice>(_onSelectDevice);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateWebUrl(
    UpdateWebUrl event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await settingsRepository.saveWebUrl(event.url);
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          currentState.settings.copyWith(webUrl: event.url),
        ));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onLoadAvailableDevices(
    LoadAvailableDevices event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final devices = await settingsRepository.getAvailableDevices(
        event.deviceType,
      );
      emit(SettingsDevicesLoaded(devices));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onSelectDevice(
    SelectDevice event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await settingsRepository.saveSelectedDevice(
        event.device,
        event.deviceType,
      );
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          currentState.settings.copyWith(
            selectedDevice: event.device,
            deviceType: event.deviceType,
          ),
        ));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsDeviceConnecting(event.deviceId));
    try {
      final device = NetworkDeviceEntity(
        id: event.deviceId,
        name: event.deviceName,
        type: event.deviceType,
        address: event.deviceAddress,
        isConnected: false,
      );
      
      final success = await settingsRepository.connectToDevice(device);
      
      if (success) {
        emit(SettingsDeviceConnected(
          deviceId: event.deviceId,
          deviceName: event.deviceName,
        ));
        // Reload devices to update connection status
        add(LoadAvailableDevices(event.deviceType));
      } else {
        emit(SettingsError('Failed to connect to device'));
      }
    } catch (e) {
      emit(SettingsError('Connection error: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectFromDevice(
    DisconnectFromDevice event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      // Get device from current state if available
      NetworkDeviceEntity? device;
      if (state is SettingsDevicesLoaded) {
        final devicesState = state as SettingsDevicesLoaded;
        device = devicesState.devices.firstWhere(
          (d) => d.id == event.deviceId,
          orElse: () => NetworkDeviceEntity(
            id: event.deviceId,
            name: '',
            type: 'wifi',
          ),
        );
      }
      
      if (device != null) {
        final success = await settingsRepository.disconnectFromDevice(device);
        if (success) {
          emit(SettingsDeviceDisconnected(event.deviceId));
          // Reload devices to update connection status
          final deviceType = device.type;
          add(LoadAvailableDevices(deviceType));
        } else {
          emit(SettingsError('Failed to disconnect from device'));
        }
      }
    } catch (e) {
      emit(SettingsError('Disconnection error: ${e.toString()}'));
    }
  }
}

