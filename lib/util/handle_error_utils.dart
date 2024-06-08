import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_deer/res/constant.dart';

/// 捕获全局异常，进行统一处理。
/// 最后就是页面的 Body 部分了，Scaffold 有一个 body 属性，接收一个 Widget，我们可以传任意的 Widget 
void handleError(void Function() body) {
  /// 重写Flutter异常回调 FlutterError.onError
  /// 如果我们想自己上报异常，只需要提供一个自定义的错误处理回调即可:https://book.flutterchina.club/chapter2/thread_model_and_error_report.html#_2-8-2-flutter异常捕获
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!Constant.inProduction) {
      // debug时，直接将异常信息打印。
      //onError是FlutterError的一个静态属性，它有一个默认的处理方法 dumpErrorToConsole
      FlutterError.dumpErrorToConsole(details);
    } else {
      // release时，将异常交由zone统一处理。
      //Zone像一个沙盒，是我们代码执行的一个环境。我们的main函数默认就运行在Root Zone当中。
      //zone表示跨异步调用保持稳定的环境。代码总是在zone的上下文中执行，使用Zone.current查看当前zone，初始化主函数在Zone.root中运行的。
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };

  /// 使用runZonedGuarded捕获Flutter未捕获的异常
  runZonedGuarded(body, (Object error, StackTrace stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

Future<void> _reportError(Object error, StackTrace stackTrace) async {
  if (!Constant.inProduction) {
    //使用services库中的debugPrintStack()方法按需打印堆栈痕迹。
    debugPrintStack(
      stackTrace: stackTrace,
      label: error.toString(),
      maxFrames: 100,
    );
  } else {
    /// 将异常信息收集并上传到服务器。可以直接使用类似`flutter_bugly`插件处理异常上报。
  }
}
