import 'package:flutter/material.dart';
import 'package:flutter_deer/goods/page/goods_page.dart';
import 'package:flutter_deer/home/provider/home_provider.dart';
import 'package:flutter_deer/order/page/order_page.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/shop/page/shop_page.dart';
import 'package:flutter_deer/statistics/page/statistics_page.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/double_tap_back_exit_app.dart';
import 'package:flutter_deer/widgets/load_image.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  /**
   * 构造函数： 构造函数通过const Home({Key? key})定义。
   * 这里使用了命名参数key，并通过super(key: key)将其传递给父类的构造函数。
   * Key参数通常用于标识小部件，以便在重建小部件时识别它们。
   * 
   *  const: 这表示构造函数是一个常量构造函数。
   *  在Dart中，通过const关键字创建的对象是编译时常量，这有助于提高性能和减少内存使用
  */
  const Home({super.key});


  /**
   * _HomeState类： 这是Home类的私有状态类，负责管理Home类的可变状态
   * 
   * createState方法： 这个方法是StatefulWidget的一个抽象方法，需要返回一个状态对象。
   * 在这里，createState方法返回_HomeState类的实例，以便管理Home类的状态
  */
  @override
  _HomeState createState() => _HomeState();
}

/**
 * 通过将 RestorationMixin 添加到 _HomeState，你可以利用 Flutter 的状态保存和恢复功能，以便在应用程序重新启动时恢复 widget 的状态。
 * 这对于保留用户界面的滚动位置、文本字段内容等非常有用
 * 
 *  with RestorationMixin： 这表示 _HomeState 类使用了 RestorationMixin mixin。with 关键字用于在 Dart 中混合 mixin，它允许一个类获取另一个类的功能，而不需要继承整个类层次结构。
*/
class _HomeState extends State<Home> with RestorationMixin{

  static const double _imageSize = 25.0;

  //late关键字是Dart语言中的一个特性，它用于标记一个变量的延迟初始化。
  //当你使用late关键字修饰一个变量时，Dart编译器会允许你推迟该变量的初始化，直到该变量首次被访问。
  //如是在未初始化时就访问它,会报错的
  late List<Widget> _pageList;
  final List<String> _appBarTitles = ['订单', '商品', '统计', '店铺'];
  final PageController _pageController = PageController();

  HomeProvider provider = HomeProvider();

  //BottomNavigationBarItem是Flutter中用于定义底部导航栏条目的类。它通常与BottomNavigationBar一起使用，用于创建底部导航栏的单个条目
  List<BottomNavigationBarItem>? _list;
  List<BottomNavigationBarItem>? _listDark;

  @override
  void initState() {
    super.initState();
    initData();
  }
 

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void initData() {
    _pageList = [
      const OrderPage(),
      const GoodsPage(),
      const StatisticsPage(),
      const ShopPage(),
    ];
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItem() {
    if (_list == null) {
      const tabImages = [
        [
          LoadAssetImage('home/icon_order', width: _imageSize, color: Colours.unselected_item_color,),
          LoadAssetImage('home/icon_order', width: _imageSize, color: Colours.app_main,),
        ],
        [
          LoadAssetImage('home/icon_commodity', width: _imageSize, color: Colours.unselected_item_color,),
          LoadAssetImage('home/icon_commodity', width: _imageSize, color: Colours.app_main,),
        ],
        [
          LoadAssetImage('home/icon_statistics', width: _imageSize, color: Colours.unselected_item_color,),
          LoadAssetImage('home/icon_statistics', width: _imageSize, color: Colours.app_main,),
        ],
        [
          LoadAssetImage('home/icon_shop', width: _imageSize, color: Colours.unselected_item_color,),
          LoadAssetImage('home/icon_shop', width: _imageSize, color: Colours.app_main,),
        ]
      ];
      _list = List.generate(tabImages.length, (i) {
        return BottomNavigationBarItem(
          icon: tabImages[i][0],
          activeIcon: tabImages[i][1],
          label: _appBarTitles[i],
          tooltip: _appBarTitles[i],
        );
      });
    }
    return _list!;
  }

  List<BottomNavigationBarItem> _buildDarkBottomNavigationBarItem() {
    if (_listDark == null) {
      const tabImagesDark = [
        [
          LoadAssetImage('home/icon_order', width: _imageSize),
          LoadAssetImage('home/icon_order', width: _imageSize, color: Colours.dark_app_main,),
        ],
        [
          LoadAssetImage('home/icon_commodity', width: _imageSize),
          LoadAssetImage('home/icon_commodity', width: _imageSize, color: Colours.dark_app_main,),
        ],
        [
          LoadAssetImage('home/icon_statistics', width: _imageSize),
          LoadAssetImage('home/icon_statistics', width: _imageSize, color: Colours.dark_app_main,),
        ],
        [
          LoadAssetImage('home/icon_shop', width: _imageSize),
          LoadAssetImage('home/icon_shop', width: _imageSize, color: Colours.dark_app_main,),
        ]
      ];

      _listDark = List.generate(tabImagesDark.length, (i) {
        return BottomNavigationBarItem(
          icon: tabImagesDark[i][0],
          activeIcon: tabImagesDark[i][1],
          label: _appBarTitles[i],
          tooltip: _appBarTitles[i],
        );
      });
    }
    return _listDark!;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;

    /**
     * ChangeNotifierProvider： 这是 Provider 包提供的一个特殊的提供器，用于管理 ChangeNotifier 的状态。
     * 
     * ChangeNotifierProvider 是 Provider 包提供的一个类，用于将 ChangeNotifier 引入到 Flutter 的 Provider 架构中。
     * 在这里，通过 ChangeNotifierProvider<HomeProvider> 来提供 HomeProvider 的实例
     * 
     * ChangeNotifierProvider 是 Provider 包提供的一个类，用于将 ChangeNotifier 引入到 Flutter 的 Provider 架构中什么意思? 
     *  回答:
     *      1.Provider 架构： 在 Flutter 中，"Provider 架构" 是一种用于在应用程序中共享状态的设计模式。
     *        它允许状态被提供（provided）到整个小部件树中，以便在需要的地方访问该状态。provider 包是一个用于实现 Provider 架构的 Dart 包，提供了一些类和工具来简化状态管理的过程。
     * 
     *      2.ChangeNotifier： ChangeNotifier 是 Flutter 提供的一个轻量级的状态管理类。它实现了发布-订阅模式，允许监听者（订阅者）注册对模型变化的关注，并在模型状态发生变化时得到通知。
     *        当 ChangeNotifier 的状态发生变化时，它会通知所有注册的监听者进行更新
     * 
     *      3.ChangeNotifierProvider 类： ChangeNotifierProvider 是 provider 包中的一个类，它用于将 ChangeNotifier 的实例引入到 Flutter 的 Provider 架构中。
     *        通过 ChangeNotifierProvider，你可以方便地在小部件树中提供和监听 ChangeNotifier 类型的状态。
     *        3.1 通过 create 参数，你可以提供一个回调函数，用于创建和返回 ChangeNotifier 的实例。
     *        3.2 通过 child 参数，你可以将提供的状态引入到子部件中
     * 
    */
    return ChangeNotifierProvider<HomeProvider>(
      //通过 create 参数提供一个回调函数，该回调函数负责创建和返回要提供的 ChangeNotifier 的实例。
      //在这里，使用匿名函数 _（代表不使用传入的 BuildContext）来返回之前创建的 HomeProvider 实例
      create: (_) => provider,
      child: DoubleTapBackExitApp(
        child: Scaffold(
          //Consumer 是 Provider 包提供的一个小部件，用于监听 ChangeNotifier 的变化，并在变化时重新构建子树。
          //在这里，Consumer<HomeProvider> 用于监听 HomeProvider 的变化，并根据变化来更新 BottomNavigationBar。
          bottomNavigationBar: Consumer<HomeProvider>(
            /**
             * builder 参数是 Consumer 的一个回调函数，该函数接收三个参数：
             *  _: 代表 BuildContext，但在这里没有被使用，因此用下划线表示不使用它。
             *  
             * provider: 是 ChangeNotifierProvider 提供的 HomeProvider 实例。
             *    这是由 Consumer 自动订阅并提供的，表示该小部件在 HomeProvider 发生变化时会被重新构建。
             * 
             * __: 代表 Widget child，但在这里也没有被使用。
             */
            builder: (_, provider, __) {
              //BottomNavigationBar 是一个用于在底部导航栏中显示多个选项的 Flutter 小部件。它通常用于提供应用程序的主要导航选项。
              return BottomNavigationBar(
                backgroundColor: context.backgroundColor,
                items: isDark ? _buildDarkBottomNavigationBarItem() : _buildBottomNavigationBarItem(),
                type: BottomNavigationBarType.fixed,
                currentIndex: provider.value,
                elevation: 5.0,
                iconSize: 21.0,
                selectedFontSize: Dimens.font_sp10,
                unselectedFontSize: Dimens.font_sp10,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: isDark ? Colours.dark_unselected_item_color : Colours.unselected_item_color,
                //onTap 是一个回调函数，它在用户点击底部导航栏项时被调用。该回调函数接收用户点击的项的索引作为参数。在回调函数中，你可以执行相应的操作，例如切换页面或更新状态。
                onTap: (index) => _pageController.jumpToPage(index),
              );
            },
          ),
          // 使用PageView的原因参看 https://zhuanlan.zhihu.com/p/58582876
          body: PageView(
            physics: const NeverScrollableScrollPhysics(), // 禁止滑动
            controller: _pageController,
            onPageChanged: (int index) => provider.value = index,
            children: _pageList,
          )
        ),
      ),
    );
  }

  @override
  String? get restorationId => 'home';

  //RestorationBucket 是用于存储和恢复状态的容器，而状态的每个部分都需要一个唯一的键来标识。这个键是一个字符串，用于区分不同的状态片段
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    //BottomNavigationBarCurrentIndex 确实是一个字符串，它被用作RestorationBucket中存储和恢复状态时的键（key）。
    //  在 registerForRestoration 方法中，这个字符串标识了要保存和恢复的状态的一部分。
    //BottomNavigationBarCurrentIndex 作为键，用于标识 provider（可能是一个 ChangeNotifier 或其他类型的状态管理类）在 RestorationBucket 中保存和恢复的状态。
    //你可以根据需要选择有意义的、描述性的字符串作为键，以确保在整个应用程序中不发生冲突。在多个状态需要保存时，每个状态都应使用独特的键。
    registerForRestoration(provider, 'BottomNavigationBarCurrentIndex');
  }

}
