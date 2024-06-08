import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/util/toast_utils.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';
import 'package:sp_util/sp_util.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {

  /// 打开链接
  static Future<void> launchWebURL(String url) async {
    //从url中构造构造一个 Uri 对象,然后可以从这个对象中获取你想要的信息
    //https://juejin.cn/post/7135423120164257805
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {//是否可以打开这个网址
      await launchUrl(uri);//打开网址
    } else {
      Toast.show('打开链接失败！');
    }
  }

  /// 调起拨号页
  static Future<void> launchTelURL(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Toast.show('拨号失败！');
    }
  }

  //关于钱单位的工具类
  static String formatPrice(String price, {MoneyFormat format = MoneyFormat.END_INTEGER}){
    return MoneyUtil.changeYWithUnit(NumUtil.getDoubleByValueStr(price) ?? 0, MoneyUnit.YUAN, format: format);
  }

  //处理键盘事件
  static KeyboardActionsConfig getKeyboardActionsConfig(BuildContext context, List<FocusNode> list) {
    return KeyboardActionsConfig(
      keyboardBarColor: ThemeUtils.getKeyboardActionsColor(context),
      actions: List.generate(list.length, (i) => KeyboardActionsItem(
        focusNode: list[i],
        toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(getCurrLocale() == 'zh' ? '关闭' : 'Close'),
              ),
            );
          },
        ],
      )),
    );
  }

  static String? getCurrLocale() {
    final String locale = SpUtil.getString(Constant.locale)!;
    if (locale == '') {
      //PlatformDispatcher是FlutterView的核心，FlutterView是对它的一层封装，是真正向Flutter Engine发送消息和得到回调的类；
      //https://juejin.cn/post/6940478904071094279
      return PlatformDispatcher.instance.locale.languageCode;
    }
    return locale;
  }

}

//展示自定义提示框:https://blog.csdn.net/Calvin_zhou/article/details/115768013
Future<T?> showElasticDialog<T>({
  required BuildContext context,
  bool barrierDismissible = true,
  required WidgetBuilder builder,
}) {

  return showGeneralDialog(//系统方法 
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        child: pageChild,
      );
    },
    barrierDismissible: barrierDismissible,//是否点击背景可以关掉
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,//
    barrierColor: Colors.black54,//背景颜色
    transitionDuration: const Duration(milliseconds: 550),//动画时长
    transitionBuilder: _buildDialogTransitions,//构建进出动画
  );
}

Widget _buildDialogTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const ElasticOutCurve(0.85),
        reverseCurve: Curves.easeOutBack,
      )),
      child: child,
    ),
  );
}

/// String 空安全处理
/// minxins方法与on: https://zhuanlan.zhihu.com/p/352184736
extension StringExtension on String? {
  String get nullSafe => this ?? '';
}
