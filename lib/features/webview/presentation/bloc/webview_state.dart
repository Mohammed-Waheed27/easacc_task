part of 'webview_bloc.dart';

abstract class WebViewState extends Equatable {
  const WebViewState();

  @override
  List<Object?> get props => [];
}

class WebViewInitial extends WebViewState {}

class WebViewLoading extends WebViewState {
  final String url;

  const WebViewLoading(this.url);

  @override
  List<Object?> get props => [url];
}

class WebViewLoaded extends WebViewState {
  final String url;

  const WebViewLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class WebViewErrorState extends WebViewState {
  final String url;
  final String error;

  const WebViewErrorState(this.url, this.error);

  @override
  List<Object?> get props => [url, error];
}

