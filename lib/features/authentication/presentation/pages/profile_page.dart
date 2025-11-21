import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/routes/route_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'login_page.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
      child: const _ProfilePageView(),
    );
  }
}

class _ProfilePageView extends StatelessWidget {
  const _ProfilePageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightPink,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLightPink,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textBlack),
            onPressed: () {
              Navigator.push(
                context,
                SlideFromRightRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to login page after sign out with slide to right animation
            Navigator.pushReplacement(
              context,
              SlideToRightRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            );
          }

          if (state is AuthError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.backgroundWhite,
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 32.h),
                  // Profile Picture
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryRed,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? Image.network(
                              user.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(user.name ?? user.email);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primaryRed,
                                  ),
                                );
                              },
                            )
                          : _buildDefaultAvatar(user.name ?? user.email),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // User Name
                  if (user.name != null && user.name!.isNotEmpty)
                    Text(
                      user.name!,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  // Email
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.textLightGray,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Auth Provider Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getProviderColor(user.authProvider),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _getProviderLabel(user.authProvider),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.backgroundWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  // User Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoRow('User ID', user.id),
                        SizedBox(height: 16.h),
                        _buildInfoRow('Email', user.email),
                        SizedBox(height: 16.h),
                        _buildInfoRow('Auth Provider', _getProviderLabel(user.authProvider)),
                        if (user.createdAt != null) ...[
                          SizedBox(height: 16.h),
                          _buildInfoRow(
                            'Member Since',
                            _formatDate(user.createdAt!),
                          ),
                        ],
                        if (user.lastLoginAt != null) ...[
                          SizedBox(height: 16.h),
                          _buildInfoRow(
                            'Last Login',
                            _formatDate(user.lastLoginAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const SignOut());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.backgroundWhite,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Unauthenticated state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not authenticated',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: AppColors.textLightGray,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.backgroundWhite,
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
        : 'U';
    
    return Container(
      color: AppColors.primaryRed,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.backgroundWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textLightGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Color(0xFF4285F4);
      case 'facebook':
        return AppColors.buttonFacebookBlue;
      case 'email':
        return AppColors.primaryRed;
      default:
        return AppColors.buttonGray;
    }
  }

  String _getProviderLabel(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'facebook':
        return 'Facebook';
      case 'email':
        return 'Email';
      default:
        return provider;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

