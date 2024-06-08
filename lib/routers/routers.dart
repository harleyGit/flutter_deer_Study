import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/account/account_router.dart';
import 'package:flutter_deer/goods/goods_router.dart';
import 'package:flutter_deer/home/home_page.dart';
import 'package:flutter_deer/home/webview_page.dart';
import 'package:flutter_deer/login/login_router.dart';
import 'package:flutter_deer/order/order_router.dart';
import 'package:flutter_deer/routers/i_router.dart';
import 'package:flutter_deer/routers/not_found_page.dart';
import 'package:flutter_deer/setting/setting_router.dart';
import 'package:flutter_deer/shop/shop_router.dart';
import 'package:flutter_deer/statistics/statistics_router.dart';
import 'package:flutter_deer/store/store_router.dart';

class Routes {

  static String home = '/home';
  static String webViewPage = '/webView';

  static final List<IRouterProvider> _listRouter = [];

  //路由框架:https://juejin.cn/post/6953066803576700964
  //初始化
  //FluroRouter 是 fluro 库中的一个类，用于定义和管理路由。
  //FluroRouter 主要用于实现 Flutter 应用程序中页面跳转和路由管理的功能
  static final FluroRouter router = FluroRouter();

  static void initRoutes() {
    /// 指定路由跳转错误返回页
    /// 被用来设置一个处理器，以处理在 FluroRouter 中未找到匹配路由的情况。这通常被称为“404 处理器”或“未找到处理器”
    /// 设置未找到处理器是一个很好的做法，因为它允许你有更多的控制权来处理用户访问不存在页面的情况，而不是直接抛出异常或者默默失败。
    /// 这可以提高用户体验，并为用户提供有关错误的友好提示。
    router.notFoundHandler = Handler(/// Handler 类： 这是 fluro 库中的一个类，用于包装路由的处理函数。在这里，通过 Handler 构造函数创建一个处理函数。
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {//handlerFunc 参数： 这是 Handler 类中的一个参数，用于指定一个处理函数，该函数在未找到匹配路由时被调用。在这个处理函数中，你可以执行一些特定的操作，比如打印调试信息或者显示一个特殊的页面。
        debugPrint('未找到目标页');
        //返回一个 NotFoundPage 的实例。这意味着应用程序可以显示一个自定义的“未找到页面”给用户
        return const NotFoundPage();
      });

    /**
     * 配置 Fluro 路由，以便在导航到特定路径时执行相应的处理逻辑。
     * 在实际使用中，可能会有其他路由规则和处理函数，以构建应用程序的整体导航结构
     * 
     *  handler: Handler(...)： 指定了当路由被触发时执行的处理函数。在这里，使用了 Handler，并提供了一个包含处理逻辑的匿名函数。
     *    handlerFunc:这是处理函数，它接收两个参数，BuildContext? context 表示构建上下文，Map<String, List<String>> params 表示路由中传递的参数。在这个例子中，构建上下文未被使用，而 params 可能包含从路由中提取的参数
     *    const Home()： 这是处理函数的返回值，表示当路由被触发时要显示的页面或执行的操作。在这里，返回了一个类型为 Home 的实例，可能是一个 Flutter widget，表示首页或某种界面
    */
    router.define(home, handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) => const Home()));
    
    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      final String title = params['title']?.first ?? '';
      final String url = params['url']?.first ?? '';
      return WebViewPage(title: title, url: url);
    }));

    _listRouter.clear();
    /// 各自路由由各自模块管理，统一在此添加初始化
    _listRouter.add(ShopRouter());
    _listRouter.add(LoginRouter());
    _listRouter.add(GoodsRouter());
    _listRouter.add(OrderRouter());
    _listRouter.add(StoreRouter());
    _listRouter.add(AccountRouter());
    _listRouter.add(SettingRouter());
    _listRouter.add(StatisticsRouter());
  
    /// 初始化路由
    void initRouter(IRouterProvider routerProvider) {
      routerProvider.initRouter(router);
    }
    _listRouter.forEach(initRouter);
  }
}
