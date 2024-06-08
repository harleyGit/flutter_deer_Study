import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/util/toast_utils.dart';

/// 双击返回退出
class DoubleTapBackExitApp extends StatefulWidget {

  const DoubleTapBackExitApp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
  });

  final Widget child;
  /// 两次点击返回按钮的时间间隔
  final Duration duration;

  @override
  _DoubleTapBackExitAppState createState() => _DoubleTapBackExitAppState();
}

class _DoubleTapBackExitAppState extends State<DoubleTapBackExitApp> {

  DateTime? _lastTime;

  @override
  Widget build(BuildContext context) {
    //WillPopScope 是一个用于处理返回按钮按下事件的 Flutter 小部件。
    //在用户点击返回按钮时，WillPopScope 将会调用 onWillPop 回调函数，然后根据该回调函数的返回值决定是否允许当前页面被弹出
    return WillPopScope(
      //这是一个回调函数，它接收一个 Future<bool> 类型的返回值。
      //WillPopScope 将在用户点击返回按钮时调用此回调。如果 onWillPop 返回 true，则允许页面被弹出；如果返回 false，则页面不会被弹出。
      onWillPop: _isExit,
      //这是 WillPopScope 包裹的小部件。
      //在这个例子中，它是 widget.child，表示 WillPopScope 只会影响这个子部件的返回按钮行为
      child: widget.child,
    );
  }

  Future<bool> _isExit() async {
    //DateTime.now().difference(_lastTime!) 是计算当前时间与 _lastTime 之间的时间差，返回的是一个 Duration 对象
    if (_lastTime == null || DateTime.now().difference(_lastTime!) > widget.duration) {
      _lastTime = DateTime.now();
      Toast.show('再次点击退出应用');
      return Future.value(false);
    }
    Toast.cancelToast();
    /// 不推荐使用 `dart:io` 的 exit(0)
    await SystemNavigator.pop();
    return Future.value(true);
  }
}
