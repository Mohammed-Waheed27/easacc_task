import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/welcome_section.dart';
import '../widgets/email_input_section.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatefulWidget {
  const _LoginPageView();

  @override
  State<_LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<_LoginPageView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showEmailInput = false;
  bool _isSignUp = false;
  bool _showPassword = false;
  late AnimationController _switchAnimationController;

  @override
  void initState() {
    super.initState();
    _switchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _switchAnimationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_showPassword) {
        // Show password field
        setState(() {
          _showPassword = true;
        });
      } else {
        // Perform login or signup
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        if (_isSignUp) {
          context.read<AuthBloc>().add(
            SignUpWithEmailAndPassword(email: email, password: password),
          );
        } else {
          context.read<AuthBloc>().add(
            SignInWithEmailAndPassword(email: email, password: password),
          );
        }
      }
    }
  }

  void _handleGoogleSignIn() {
    if (_isSignUp) {
      context.read<AuthBloc>().add(const SignUpWithGoogle());
    } else {
      context.read<AuthBloc>().add(const SignInWithGoogle());
    }
  }

  void _handleFacebookSignIn() async {
    if (_isSignUp) {
      context.read<AuthBloc>().add(const SignUpWithFacebook());
    } else {
      context.read<AuthBloc>().add(const SignInWithFacebook());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to profile page to show user information
          // Use Future.microtask to ensure navigation happens after build
          Future.microtask(() {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
            }
          });
        } else if (state is AuthError) {
          // Show error message - handle multi-line messages for MissingPluginException
          final errorMessage = state.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage.contains('\n')
                    ? errorMessage
                          .split('\n')
                          .first // Show first line in snackbar
                    : errorMessage,
                style: const TextStyle(color: AppColors.backgroundWhite),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(
                seconds: 5,
              ), // Longer duration for important messages
              action:
                  errorMessage.contains('rebuild') ||
                      errorMessage.contains('restart')
                  ? SnackBarAction(
                      label: 'OK',
                      textColor: AppColors.backgroundWhite,
                      onPressed: () {},
                    )
                  : null,
            ),
          );

          // If it's a MissingPluginException, also show a dialog with full instructions
          if (errorMessage.contains('MissingPluginException') ||
              errorMessage.contains('No implementation found') ||
              errorMessage.contains('rebuild') ||
              errorMessage.contains('restart')) {
            Future.delayed(const Duration(milliseconds: 500), () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Facebook Sign-In Not Available'),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLightPink,
        appBar: _showEmailInput
            ? AppBar(
                backgroundColor: AppColors.backgroundLightPink,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textBlack,
                  ),
                  onPressed: () {
                    setState(() {
                      _showEmailInput = false;
                      _showPassword = false;
                      _emailController.clear();
                      _passwordController.clear();
                    });
                  },
                ),
                title: Text(
                  _isSignUp ? 'Sign Up' : 'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (_showEmailInput) {
                    return Column(
                      children: [
                        EmailInputSection(
                          emailController: _emailController,
                          passwordController: _showPassword
                              ? _passwordController
                              : null,
                          onContinue: _handleContinue,
                          onGoogleSignIn: _handleGoogleSignIn,
                          onFacebookSignIn: _handleFacebookSignIn,
                          isSignUp: _isSignUp,
                          showPassword: _showPassword,
                        )
                            .animate(key: ValueKey('email_$_isSignUp'))
                            .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            ),
                        SizedBox(height: 24.h),
                        // Switch between Sign In and Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    )),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                _isSignUp
                                    ? 'Already have an account? '
                                    : "Don't have an account? ",
                                key: ValueKey('text_$_isSignUp'),
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: AppColors.textLightGray,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _switchAnimationController.forward(from: 0.0);
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _showPassword = false;
                                  _emailController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.2),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  _isSignUp ? 'Sign In' : 'Sign Up',
                                  key: ValueKey('link_$_isSignUp'),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryRed,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate(key: ValueKey('switch_$_isSignUp'))
                            .fadeIn(duration: 300.ms, delay: 100.ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              delay: 100.ms,
                              curve: Curves.easeOut,
                            ),
                      ],
                    );
                  }

                  return WelcomeSection(
                    onLoginTap: () {
                      setState(() {
                        _showEmailInput = true;
                        _isSignUp = false;
                        _showPassword = false;
                      });
                    },
                    onSignUpTap: () {
                      setState(() {
                        _showEmailInput = true;
                        _isSignUp = true;
                        _showPassword = false;
                      });
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
