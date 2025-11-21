import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/webview_bloc.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebViewBloc()..add(LoadUrl(url)),
      child: _WebViewPageView(url: url),
    );
  }
}

class _WebViewPageView extends StatefulWidget {
  final String url;

  const _WebViewPageView({required this.url});

  @override
  State<_WebViewPageView> createState() => _WebViewPageViewState();
}

class _WebViewPageViewState extends State<_WebViewPageView> {
  late final WebViewController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _error = null;
            });
            context.read<WebViewBloc>().add(NotifyWebViewLoading(url));
          },
          onPageFinished: (String url) {
            context.read<WebViewBloc>().add(NotifyWebViewLoaded(url));
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = error.description;
            });
            context.read<WebViewBloc>().add(
                  NotifyWebViewError(widget.url, error.description),
                );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Web View',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textBlack),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: BlocListener<WebViewBloc, WebViewState>(
        listener: (context, state) {
          if (state is WebViewErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<WebViewBloc, WebViewState>(
          builder: (context, state) {
            final isLoading = state is WebViewLoading;
            
            return Stack(
              children: [
                if (_error != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading page',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            _controller.reload();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  WebViewWidget(controller: _controller),
                if (isLoading)
                  Container(
                    color: AppColors.backgroundWhite,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
