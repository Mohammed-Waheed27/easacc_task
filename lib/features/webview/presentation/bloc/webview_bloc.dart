import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'webview_event.dart';
part 'webview_state.dart';

class WebViewBloc extends Bloc<WebViewEvent, WebViewState> {
  WebViewBloc() : super(WebViewInitial()) {
    on<LoadUrl>(_onLoadUrl);
    on<NotifyWebViewLoading>(_onNotifyWebViewLoading);
    on<NotifyWebViewLoaded>(_onNotifyWebViewLoaded);
    on<NotifyWebViewError>(_onNotifyWebViewError);
  }

  void _onLoadUrl(
    LoadUrl event,
    Emitter<WebViewState> emit,
  ) {
    emit(WebViewLoading(event.url));
  }

  void _onNotifyWebViewLoading(
    NotifyWebViewLoading event,
    Emitter<WebViewState> emit,
  ) {
    emit(WebViewLoading(event.url));
  }

  void _onNotifyWebViewLoaded(
    NotifyWebViewLoaded event,
    Emitter<WebViewState> emit,
  ) {
    emit(WebViewLoaded(event.url));
  }

  void _onNotifyWebViewError(
    NotifyWebViewError event,
    Emitter<WebViewState> emit,
  ) {
    emit(WebViewErrorState(event.url, event.error));
  }
}

