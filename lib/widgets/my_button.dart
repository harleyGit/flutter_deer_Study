import 'package:flutter/material.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';

/// 默认字号18，白字蓝底，高度48
class MyButton extends StatelessWidget {

  const MyButton({
    super.key,
    this.text = '',
    this.fontSize = Dimens.font_sp18,
    this.textColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.minHeight = 48.0,
    this.minWidth = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.radius = 2.0,
    this.side = BorderSide.none,
    required this.onPressed,
  });

  final String text;
  final double fontSize;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double? minHeight;
  final double? minWidth;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // 文字颜色, 使用resolveWith为不同状态提供不同的文本颜色
        foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {//确定组件是否被禁用
              return disabledTextColor ?? (isDark ? Colours.dark_text_disabled : Colours.text_disabled);
            }
            return textColor ?? (isDark ? Colours.dark_button_text : Colors.white);
          },
        ),
        // 背景颜色
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledBackgroundColor ?? (isDark ? Colours.dark_button_disabled : Colours.button_disabled);
          }
          return backgroundColor ?? (isDark ? Colours.dark_app_main : Colours.app_main);
        }),
        // 水波纹
        overlayColor: MaterialStateProperty.resolveWith((states) {
          return (textColor ?? (isDark ? Colours.dark_button_text : Colors.white)).withOpacity(0.12);
        }),
        // 按钮最小大小
        //MaterialStateProperty.all 是 Flutter 中用于在所有状态下设置相同值的方法。在你提供的例子中，MaterialStateProperty.all<Size>(Size(minWidth!, minHeight!)) 用于设置在所有状态下都使用相同的 Size 值
        //<Size>: 这是指定泛型类型的语法，指示 MaterialStateProperty.all 将返回一个 MaterialStateProperty<Size> 类型的对象
        minimumSize: (minWidth == null || minHeight == null) ? null : MaterialStateProperty.all<Size>(Size(minWidth!, minHeight!)),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        side: MaterialStateProperty.all<BorderSide>(side),
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize),)
    );
  }
}
