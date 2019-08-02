import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class LoginAppBrowser extends InAppBrowser {
  Function codeCallback;
  Function errorCallback;
  String state;

  @override
  Future onLoadStart(String url) async {
    if(url.toString().contains(this.state)) {
      if(url.toString().contains('code=')) {
        this.close();
        String code = url.toString().replaceAll('https://thatseliyt.de/?state=' + this.state + '&code=', '');
        this.codeCallback(code);
      } else if(url.toString().contains('error')) {
        this.close();
        String url = await this.webViewController.getUrl();
        String error = url.replaceAll('https://thatseliyt.de/?state=' + this.state + '&error=', '');
        this.errorCallback(error);
      }
    } else {
      this.close();
      this.errorCallback('There was a state mismatch.');
    }
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  void setCallbacks({ Function codeCallback, Function errorCallback, String state }) {
    this.codeCallback = codeCallback ?? () {};
    this.errorCallback = errorCallback ?? () {};
    this.state = state;
  }

}