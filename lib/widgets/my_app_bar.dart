
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/my_button.dart';

/// 自定义AppBar
/// PreferredSizeWidget 是 Flutter 中的一个抽象类，用于表示可以定义自己的 PreferredSize 的 Widget。它是一个在 AppBar、Scaffold 等 Flutter 控件中常用的抽象类，用于自定义 AppBar 的高度
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  const MyAppBar({
    super.key,
    this.backgroundColor,
    this.title = '',
    this.centerTitle = '',
    this.actionName = '',
    this.backImg = 'assets/images/ic_back_black.png',
    this.backImgColor,
    this.onPressed,
    this.isBack = true
  });

  final Color? backgroundColor;
  final String title;
  final String centerTitle;
  final String backImg;
  final Color? backImgColor;
  final String actionName;
  final VoidCallback? onPressed;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? context.backgroundColor;

    final SystemUiOverlayStyle overlayStyle = ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
        ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    //Positioned是Flutter中用于定位子组件的widget之一，通常用于Stack中。Positioned可以让你根据Stack的四个角或中心点来定位子组件，通过设置top、right、bottom、left等属性来指定相对于Stack的位置
    final Widget action = actionName.isNotEmpty ? Positioned(
      right: 0.0,
      child: Theme(
        //通过context获取当前Theme的方法。Theme是应用程序的整体视觉样式的主题
        //copyWith方法创建并返回一个新的ThemeData对象，该对象是当前主题的一个副本。它接受一个或多个属性，这些属性将在新的主题中被覆盖或修改
        data: Theme.of(context).copyWith(
          //将新的ButtonThemeData对象添加到主题的buttonTheme属性中。这意味着在新的主题中，所有使用ButtonTheme的组件将采用这里定义的ButtonThemeData
          buttonTheme: const ButtonThemeData(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            minWidth: 60.0,//设置按钮的最小宽度，这里被设置为60.0像素
          ),
        ),
        child: MyButton(
          key: const Key('actionName'),
          fontSize: Dimens.font_sp14,
          minWidth: null,
          text: actionName,
          textColor: context.isDark ? Colours.dark_text : Colours.text,
          backgroundColor: Colors.transparent,
          onPressed: onPressed,
        ),
      ),
    ) : Gaps.empty;

    final Widget back = isBack ? IconButton(
      onPressed: () async {
        /**
         * 这一行代码的作用是确保在执行它时，任何当前具有焦点的FocusNode都会失去焦点。
         * 这通常用于隐藏键盘或取消输入字段的焦点，以确保用户完成输入操作后，不再有任何不必要的焦点保持在屏幕上
         * 
         * FocusManager.instance: 这是FocusManager的一个静态实例，用于管理应用程序中的焦点状态
         * primaryFocus: 这是FocusManager的一个属性，表示当前具有焦点的FocusNode。这是应用程序中所有焦点节点中的一个主要节点
         * unfocus(): 这是 FocusNode 的方法，用于取消该节点的焦点。在这里，它被调用来取消当前具有焦点的节点的焦点
        */
        FocusManager.instance.primaryFocus?.unfocus();

        //这是 Flutter 中的一个导航工具方法，尝试弹出当前路由并返回一个布尔值。
        //如果导航栈中有上一个页面（即可以弹出），则返回 true；否则，返回 false。这里使用 await 表示异步等待
        final isBack = await Navigator.maybePop(context);
        if (!isBack) {//表示当前页面无法通过 Navigator.maybePop 返回上一页（可能是因为当前是第一页），那么通过 SystemNavigator.pop() 来关闭整个应用程序。
          await SystemNavigator.pop();
        }
      },
      tooltip: 'Back',
      padding: const EdgeInsets.all(12.0),
      icon: Image.asset(
        backImg,
        color: backImgColor ?? ThemeUtils.getIconColor(context),
      ),
    ) : Gaps.empty;

    //Semantics是用于提供语义信息的widget。
    //它主要用于辅助技术，如屏幕阅读器，以提高应用程序的可访问性。通过使用Semantics，你可以为用户提供关于界面元素的语义信息，以便他们能够更好地理解应用程序
    final Widget titleWidget = Semantics(
      namesRoute: true,
      header: true,
      child: Container(
        alignment: centerTitle.isEmpty ? Alignment.centerLeft : Alignment.center,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Text(
          title.isEmpty ? centerTitle : title,
          style: const TextStyle(fontSize: Dimens.font_sp18,),
        ),
      ),
    );
    
    ///这段代码的目的是创建一个自定义的应用栏布局，其中包含了一个带有自定义系统 UI 风格的 Material 容器，内部使用 SafeArea 处理刘海屏的情况，然后使用 Stack 将标题、返回按钮和其他操作按钮层叠在一起
    ///AnnotatedRegion<SystemUiOverlayStyle>： 这是一个用于设置系统 UI 风格的 widget。
    /// SystemUiOverlayStyle 是一个用于定义状态栏和导航栏样式的类。
    /// value: overlayStyle 将自定义的 overlayStyle 应用于系统 UI
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      //这是一个基础的 Material 设计风格容器，通常用于包裹整个页面。
      //color: bgColor 用于设置 Material 的背景颜色。
      child: Material(
        color: bgColor,
        //这是一个用于确保子组件在屏幕边缘留有安全边距的 widget。
        //在 iPhone X 等具有刘海屏或底部间隙的设备上，SafeArea 会自动调整子组件的布局，以避免被遮挡
        child: SafeArea(
          // 这是一个堆叠布局，允许子组件重叠在一起。
          //alignment: Alignment.centerLeft 设置了子组件的对齐方式，让它们在左上角对齐
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              titleWidget,
              back,
              action,
            ],
          ),
        ),
      ),
    );
  }

  @override
  //如果你的 Widget 实现了 PreferredSizeWidget 接口，然后在需要使用 Widget 的地方，可以通过 preferredSize 获取 Widget 的优选尺寸。
  //在这里，preferredSize 返回的是一个高度为 48.0 的尺寸，可能用于定义一个具有优选高度的 AppBar 或其他顶部栏
  Size get preferredSize => const Size.fromHeight(48.0);
}
