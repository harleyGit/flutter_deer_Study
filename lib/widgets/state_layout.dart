import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/load_image.dart';

/// design/9暂无状态页面/index.html#artboard3
class StateLayout extends StatelessWidget {
  
  const StateLayout({
    super.key,
    required this.type,
    this.hintText
  });
  
  final StateType type;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (type == StateType.loading)
          /**
           * 该活动指示器通常用于在数据加载、网络请求或其他耗时操作期间向用户显示进度。
           * 你可以根据需要调整 radius 参数以满足设计需求
           * 
           *  CupertinoActivityIndicator： 这是 Cupertino 风格的活动指示器小部件，用于在 iOS 风格的应用中显示加载或操作进行中的状态
           *  radius: 16.0： 这是 CupertinoActivityIndicator 的一个参数，表示活动指示器的半径。在这里，半径被设置为 16.0。  
           * */
          const CupertinoActivityIndicator(radius: 16.0)
        else
          if (type != StateType.empty)
            Opacity(
              opacity: context.isDark ? 0.5 : 1,
              child: LoadAssetImage(
                'state/${type.img}',
                width: 120,
              ),
            ),
        //Container 的宽度被设置为 double.infinity，这意味着它可以在宽度上无限扩展，占据可用的所有水平空间
        //Dimens.gap_dp16 被用作边距（margin）的值，确保在不同设备上都有一致的边距
        const SizedBox(width: double.infinity, height: Dimens.gap_dp16,),
        Text(
          hintText ?? type.hintText,
          /**
           * 获取当前主题中的某个标题样式（可能是小标题），并创建一个新的样式，将字体大小设置为 14 像素。
           * 最终的样式将用于在 UI 中渲染文本
           * 
           *  Theme.of(context)： 这是用于获取当前主题的方法。context 参数表示构建 widget 树的当前位置
           *  .textTheme： 这是 Theme 类的一个属性，它包含了主题相关的文本样式，例如标题、正文等
           *  titleSmall： 这可能是一个主题中的某个文本样式的一部分，可能是标题样式的一个变体，例如小标题
           *  copyWith 方法，该方法创建一个新的文本样式副本，并将 fontSize 设置为 Dimens.font_sp14
           *    copyWith： 这是 TextStyle 类的一个方法，用于创建一个新的文本样式对象，该对象是当前文本样式的副本，并可以修改其中的一些属性
           *  
          */
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: Dimens.font_sp14),
        ),
        Gaps.vGap50,
      ],
    );
  }
}

enum StateType {
  /// 订单
  order,
  /// 商品
  goods,
  /// 无网络
  network,
  /// 消息
  message,
  /// 无提现账号
  account,
  /// 加载中
  loading,
  /// 空
  empty
}

extension StateTypeExtension on StateType {
  String get img => <String>[
    'zwdd', 'zwsp', 
    'zwwl', 'zwxx', 
    'zwzh', '', '']
  [index];
  
  String get hintText => <String>[
    '暂无订单', '暂无商品', 
    '无网络连接', '暂无消息', 
    '马上添加提现账号吧', '', ''
  ][index];
}
