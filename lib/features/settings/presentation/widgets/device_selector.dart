import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/network_device_entity.dart';

class DeviceSelector extends StatelessWidget {
  final NetworkDeviceEntity? selectedDevice;
  final String deviceType;
  final List<NetworkDeviceEntity> availableDevices;
  final Function(NetworkDeviceEntity) onDeviceSelected;
  final Function(NetworkDeviceEntity)? onConnect;
  final Function(NetworkDeviceEntity)? onDisconnect;
  final VoidCallback onLoadDevices;
  final bool isScanning;
  final bool isConnecting;
  final String? connectingDeviceId;

  const DeviceSelector({
    super.key,
    this.selectedDevice,
    required this.deviceType,
    required this.availableDevices,
    required this.onDeviceSelected,
    this.onConnect,
    this.onDisconnect,
    required this.onLoadDevices,
    this.isScanning = false,
    this.isConnecting = false,
    this.connectingDeviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              deviceType == 'wifi' ? 'WiFi Devices' : 'Bluetooth Devices',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            TextButton.icon(
              onPressed: (isScanning || isConnecting) ? null : onLoadDevices,
              icon: isScanning
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed,
                        ),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                isScanning
                    ? 'Scanning...'
                    : (deviceType == 'wifi' ? 'WiFi' : 'Bluetooth'),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NetworkDeviceEntity>(
              value: selectedDevice,
              isExpanded: true,
              hint: isScanning
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryRed,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Scanning for devices...',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textLightGray,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select Device',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textLightGray,
                      ),
                    ),
              items: isScanning
                  ? null
                  : (availableDevices.isEmpty
                      ? [
                          DropdownMenuItem<NetworkDeviceEntity>(
                            value: null,
                            child: Text(
                              'No devices found',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppColors.textLightGray,
                              ),
                            ),
                          ),
                        ]
                      : availableDevices.map((device) {
                          return DropdownMenuItem<NetworkDeviceEntity>(
                            value: device,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    device.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ),
                                if (device.isConnected)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.w),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16.sp,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList()),
              onChanged: (isScanning || isConnecting)
                  ? null
                  : (value) {
                      if (value != null) {
                        onDeviceSelected(value);
                      }
                    },
              icon: isScanning
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed,
                        ),
                      ),
                    )
                  : const Icon(Icons.arrow_drop_down, color: AppColors.textGray),
            ),
          ),
        ),
        if (selectedDevice != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedDevice!.name,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          if (selectedDevice!.address != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              selectedDevice!.address!,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.textLightGray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (selectedDevice!.isConnected)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Connected',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (onConnect != null && !selectedDevice!.isConnected)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isConnecting &&
                                  connectingDeviceId == selectedDevice!.id
                              ? null
                              : () => onConnect!(selectedDevice!),
                          icon: isConnecting &&
                                  connectingDeviceId == selectedDevice!.id
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.link, size: 18),
                          label: Text(
                            isConnecting &&
                                    connectingDeviceId == selectedDevice!.id
                                ? 'Connecting...'
                                : 'Connect',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: AppColors.backgroundWhite,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    if (onDisconnect != null && selectedDevice!.isConnected) ...[
                      if (onConnect != null && !selectedDevice!.isConnected)
                        SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isConnecting &&
                                  connectingDeviceId == selectedDevice!.id
                              ? null
                              : () => onDisconnect!(selectedDevice!),
                          icon: const Icon(Icons.link_off, size: 18),
                          label: Text(
                            'Disconnect',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textBlack,
                            side: BorderSide(color: AppColors.borderGray),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
