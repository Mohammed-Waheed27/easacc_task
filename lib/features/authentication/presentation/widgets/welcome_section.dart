import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomeSection extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  const WelcomeSection({
    super.key,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 60.h),
        // Title
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGray,
            ),
            children: [
              const TextSpan(text: 'Welcome to '),
              TextSpan(
                text: 'Easacc',
                style: GoogleFonts.inter(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Description
        Text(
          'Get access to the tools you need to invest, spend, and put your money in motion',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppColors.textGray,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        // Swipe to learn more
        GestureDetector(
          onTap: () {
            // Navigate to next screen or show more info
          },
          child: Text(
            'Swipe to learn more →',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.primaryRed,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryRed,
            ),
          ),
        ),
        SizedBox(height: 40.h),
        // Illustration placeholder (you can add an actual image here)
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.business_center,
            size: 80.sp,
            color: AppColors.textLightGray,
          ),
        ),
        SizedBox(height: 40.h),
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onLoginTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Log in',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: onSignUpTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Sign up',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

