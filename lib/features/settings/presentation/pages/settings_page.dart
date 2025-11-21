import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/routes/route_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../webview/presentation/pages/webview_page.dart';
import '../../domain/entities/network_device_entity.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/web_url_input.dart';
import '../widgets/device_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(const LoadSettings()),
      child: const _SettingsPageView(),
    );
  }
}

class _SettingsPageView extends StatefulWidget {
  const _SettingsPageView();

  @override
  State<_SettingsPageView> createState() => _SettingsPageViewState();
}

class _SettingsPageViewState extends State<_SettingsPageView> {
  final _urlController = TextEditingController();
  String _selectedDeviceType = 'wifi';
  NetworkDeviceEntity? _selectedDevice;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectingDeviceId;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleSaveUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      context.read<SettingsBloc>().add(UpdateWebUrl(url));
    }
  }

  void _handleLoadDevices() {
    setState(() {
      _isScanning = true;
    });
    context.read<SettingsBloc>().add(LoadAvailableDevices(_selectedDeviceType));
  }

  void _handleDeviceSelected(NetworkDeviceEntity device) {
    context.read<SettingsBloc>().add(
      SelectDevice(device: device.id, deviceType: _selectedDeviceType),
    );
    setState(() {
      _selectedDevice = device;
    });
  }

  void _handleConnect(NetworkDeviceEntity device) {
    setState(() {
      _isConnecting = true;
      _connectingDeviceId = device.id;
    });
    context.read<SettingsBloc>().add(
      ConnectToDevice(
        deviceId: device.id,
        deviceName: device.name,
        deviceType: device.type,
        deviceAddress: device.address,
      ),
    );
  }

  void _handleDisconnect(NetworkDeviceEntity device) {
    setState(() {
      _isConnecting = true;
      _connectingDeviceId = device.id;
    });
    context.read<SettingsBloc>().add(
      DisconnectFromDevice(deviceId: device.id),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            _urlController.text = state.settings.webUrl;
            _selectedDeviceType = state.settings.deviceType ?? 'wifi';
          } else if (state is SettingsDeviceConnected) {
            setState(() {
              _isConnecting = false;
              _connectingDeviceId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected to ${state.deviceName}'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload devices to update connection status
            _handleLoadDevices();
          } else if (state is SettingsDeviceDisconnected) {
            setState(() {
              _isConnecting = false;
              _connectingDeviceId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Disconnected from device'),
                backgroundColor: Colors.orange,
              ),
            );
            // Reload devices to update connection status
            _handleLoadDevices();
          } else if (state is SettingsError) {
            setState(() {
              _isConnecting = false;
              _connectingDeviceId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            // Only show full-page loading for initial settings load, not for device scanning
            if (state is SettingsLoading && _selectedDevice == null && !_isScanning) {
              return const Center(child: CircularProgressIndicator());
            }

            // Update scanning state when devices are loaded
            if (state is SettingsDevicesLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isScanning = false;
                  });
                }
              });
            }

            // Update scanning state on error
            if (state is SettingsError && _isScanning) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isScanning = false;
                  });
                }
              });
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Web URL Input
                  WebUrlInput(
                    controller: _urlController,
                    onSave: _handleSaveUrl,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: -0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                  SizedBox(height: 24.h),
                  // Open Web View Button
                  ElevatedButton.icon(
                    onPressed: () {
                      final url = _urlController.text.trim();
                      if (url.isNotEmpty) {
                        Navigator.push(
                          context,
                          BottomSheetRoute(
                            builder: (_) => WebViewPage(url: url),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a valid URL first'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_browser, size: 20),
                    label: Text(
                      'Open Web View',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.backgroundWhite,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: -0.1,
                        end: 0,
                        duration: 400.ms,
                        delay: 100.ms,
                        curve: Curves.easeOut,
                      ),
                  SizedBox(height: 32.h),
                  // Device Type Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedDeviceType == 'wifi'
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDeviceType = 'wifi';
                                    _selectedDevice = null;
                                  });
                                  _handleLoadDevices();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDeviceType == 'wifi'
                                ? AppColors.primaryRed
                                : AppColors.buttonGray,
                            foregroundColor: _selectedDeviceType == 'wifi'
                                ? AppColors.backgroundWhite
                                : AppColors.textBlack,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text('WiFi'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedDeviceType == 'bluetooth'
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDeviceType = 'bluetooth';
                                    _selectedDevice = null;
                                  });
                                  _handleLoadDevices();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedDeviceType == 'bluetooth'
                                ? AppColors.primaryRed
                                : AppColors.buttonGray,
                            foregroundColor: _selectedDeviceType == 'bluetooth'
                                ? AppColors.backgroundWhite
                                : AppColors.textBlack,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text('Bluetooth'),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: -0.1,
                        end: 0,
                        duration: 400.ms,
                        delay: 200.ms,
                        curve: Curves.easeOut,
                      ),
                  SizedBox(height: 24.h),
                  // Device Selector
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      List<NetworkDeviceEntity> devices = [];
                      if (state is SettingsDevicesLoaded) {
                        devices = state.devices;
                        // Update selected device if it exists in the list
                        if (_selectedDevice != null) {
                          final updatedDevice = devices.firstWhere(
                            (d) => d.id == _selectedDevice!.id,
                            orElse: () => _selectedDevice!,
                          );
                          if (updatedDevice.id == _selectedDevice!.id) {
                            _selectedDevice = updatedDevice;
                          }
                        }
                      }

                      return DeviceSelector(
                        selectedDevice: _selectedDevice,
                        deviceType: _selectedDeviceType,
                        availableDevices: devices,
                        onDeviceSelected: _handleDeviceSelected,
                        onConnect: _handleConnect,
                        onDisconnect: _handleDisconnect,
                        onLoadDevices: _handleLoadDevices,
                        isScanning: _isScanning,
                        isConnecting: _isConnecting,
                        connectingDeviceId: _connectingDeviceId,
                      )
                          .animate(key: ValueKey('device_selector_$_selectedDeviceType'))
                          .fadeIn(duration: 400.ms, delay: 300.ms, curve: Curves.easeOut)
                          .slideY(
                            begin: -0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 300.ms,
                            curve: Curves.easeOut,
                          );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
