part of 'webview_bloc.dart';

abstract class WebViewEvent extends Equatable {
  const WebViewEvent();

  @override
  List<Object?> get props => [];
}

class LoadUrl extends WebViewEvent {
  final String url;

  const LoadUrl(this.url);

  @override
  List<Object?> get props => [url];
}

class NotifyWebViewLoading extends WebViewEvent {
  final String url;

  const NotifyWebViewLoading(this.url);

  @override
  List<Object?> get props => [url];
}

class NotifyWebViewLoaded extends WebViewEvent {
  final String url;

  const NotifyWebViewLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class NotifyWebViewError extends WebViewEvent {
  final String url;
  final String error;

  const NotifyWebViewError(this.url, this.error);

  @override
  List<Object?> get props => [url, error];
}

