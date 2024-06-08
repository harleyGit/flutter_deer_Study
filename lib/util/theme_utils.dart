import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:rxdart/rxdart.dart';

class ThemeUtils {

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color? getDarkColor(BuildContext context, Color darkColor) {
    return isDark(context) ? darkColor : null;
  }

  static Color? getIconColor(BuildContext context) {
    return isDark(context) ? Colours.dark_text : null;
  }
  
  static Color getStickyHeaderColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_gray_ : Colours.bg_gray_;
  }

  static Color getDialogTextFieldColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_gray_ : Colours.bg_gray;
  }

  static Color? getKeyboardActionsColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_color : Colors.grey[200];
  }

  static StreamSubscription<dynamic>? _subscription;

  /// 设置NavigationBar样式，使得导航栏颜色与深色模式的设置相符。
  static void setSystemNavigationBar(ThemeMode mode) {
    /// 主题切换动画（AnimatedTheme）时间为200毫秒，延时设置导航栏颜色，这样过渡相对自然。
    _subscription?.cancel();
    _subscription = Stream.value(1).delay(const Duration(milliseconds: 200)).listen((_) {
      bool isDark = false;
      if (mode == ThemeMode.dark || (mode == ThemeMode.system && PlatformDispatcher.instance.platformBrightness == Brightness.dark)) {
        isDark = true;
      }
      setSystemBarStyle(isDark: isDark);
    });
  }

  /// 设置StatusBar、NavigationBar样式。(仅针对安卓)
  /// 本项目在android MainActivity中已设置，不需要覆盖设置。
  static void setSystemBarStyle({bool? isDark}) {
    if (Device.isAndroid) {

      final bool isDarkMode = isDark ?? PlatformDispatcher.instance.platformBrightness == Brightness.dark;
      debugPrint('isDark: $isDarkMode');
      //设置暗色调状态栏图标: https://juejin.cn/post/6917154110525407239 
      final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        /// 透明状态栏
        statusBarColor: Colors.transparent,// 状态栏颜色为白色
        systemNavigationBarColor: isDarkMode ? Colours.dark_bg_color : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,// 状态栏图标为暗色调
      );
      //设置生效,设置状态栏
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}

extension ThemeExtension on BuildContext {
  //在Flutter中使用的一种方式来检查当前主题是否为暗黑模式（Dark Mode）
  bool get isDark => ThemeUtils.isDark(this);
  //Theme 主题: https://flutter.cn/docs/cookbook/design/themes
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  //返回当前主题下Scaffold的背景颜色
  //Scaffold是一个用于定义应用程序基本结构的基本布局元素。它提供了一个标准的应用程序框架，包括应用栏（AppBar）、底部导航栏（BottomNavigationBar）、侧边栏（Drawer）、浮动操作按钮（FloatingActionButton）等等
  Color get dialogBackgroundColor => Theme.of(this).canvasColor;
}
