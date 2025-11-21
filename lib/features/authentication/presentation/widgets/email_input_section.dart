import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class EmailInputSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController? passwordController;
  final VoidCallback onContinue;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onFacebookSignIn;
  final bool isSignUp;
  final bool showPassword;

  const EmailInputSection({
    super.key,
    required this.emailController,
    this.passwordController,
    required this.onContinue,
    required this.onGoogleSignIn,
    required this.onFacebookSignIn,
    this.isSignUp = false,
    this.showPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40.h),
        // Title - Different for Sign In vs Sign Up
        Text(
          isSignUp
              ? "Create your account"
              : "Welcome back!",
          style: GoogleFonts.inter(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 8.h),
        // Subtitle
        Text(
          isSignUp
              ? "Sign up to get started"
              : "Sign in to continue",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppColors.textLightGray,
          ),
        ),
        SizedBox(height: 32.h),
        // Email Input Field
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email Address',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textLightGray,
            ),
            filled: true,
            fillColor: AppColors.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.borderGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          validator: Validators.validateEmail,
        ),
        if (showPassword && passwordController != null) ...[
          SizedBox(height: 16.h),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textLightGray,
              ),
              filled: true,
              fillColor: AppColors.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
            validator: Validators.validateRequired,
          ),
        ],
        SizedBox(height: 24.h),
        // Continue Button - Different color for Sign Up
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSignUp ? AppColors.primaryRed : AppColors.buttonGray,
              foregroundColor: isSignUp ? AppColors.backgroundWhite : AppColors.textBlack,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              isSignUp ? 'Create Account' : 'Sign In',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Separator
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderGray)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                isSignUp ? 'or sign up with' : 'or sign in with',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textLightGray,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderGray)),
          ],
        ),
        SizedBox(height: 24.h),
        // Google Sign In Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGray),
              backgroundColor: AppColors.backgroundWhite,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Icon (G)
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  isSignUp ? 'Sign up with Google' : 'Sign in with Google',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Facebook Sign In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onFacebookSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonFacebookBlue,
              foregroundColor: AppColors.backgroundWhite,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Facebook Icon (f)
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonFacebookBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'f',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.backgroundWhite,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  isSignUp ? 'Sign up with Facebook' : 'Sign in with Facebook',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

