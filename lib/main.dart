import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/demo/demo_page.dart';
import 'package:flutter_deer/home/splash_page.dart';
import 'package:flutter_deer/net/dio_utils.dart';
import 'package:flutter_deer/net/intercept.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/routers/not_found_page.dart';
import 'package:flutter_deer/routers/routers.dart';
import 'package:flutter_deer/setting/provider/locale_provider.dart';
import 'package:flutter_deer/setting/provider/theme_provider.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/util/handle_error_utils.dart';
import 'package:flutter_deer/util/log_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_gen/gen_l10n/deer_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sp_util/sp_util.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
//  debugProfileBuildsEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugProfilePaintsEnabled = true;
//  debugRepaintRainbowEnabled = true;

  /// 异常处理
  handleError(() async {
    /// 确保初始化完成,原因:https://juejin.cn/post/7176043208265662523
    /// 通过 ensureInitialized() 方法我们可以得到一个全局单例 WidgetsFlutterBinding:https://juejin.cn/post/7031196891358429220
    /// 有时候我们会在发现有的app 在在运行应用程序之前先与 Flutter Engine 进行通信，所以要先将WidgetsFlutterBinding.ensureInitialized()提前。
    /// WidgetsFlutterBinding 负责在应用程序启动时初始化Flutter框架的核心部分，包括渲染引擎、事件处理、布局等。这确保了Flutter应用程序在运行之前已经准备好执行相关操作
    /// WidgetsFlutterBinding.ensureInitialized() 方法进行初始化的。这个方法会在 main() 函数开始执行时被调用，确保在应用程序的其他部分开始执行之前，Flutter框架已经完成了必要的初始化工作
    WidgetsFlutterBinding.ensureInitialized();

    if (Device.isDesktop) {
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        /// 隐藏标题栏及操作按钮
        // await windowManager.setTitleBarStyle(
        //   TitleBarStyle.hidden,
        //   windowButtonVisibility: false,
        // );
        /// 设置桌面端窗口大小
        await windowManager.setSize(const Size(400, 800));
        await windowManager.setMinimumSize(const Size(400, 800));
        /// 居中显示
        await windowManager.center();
        await windowManager.show();
        await windowManager.setPreventClose(false);
        await windowManager.setSkipTaskbar(false);
      });
    }

    /// 去除URL中的“#”(hash)，仅针对Web。默认为setHashUrlStrategy
    /// 注意本地部署和远程部署时`web/index.html`中的base标签，https://github.com/flutter/flutter/issues/69760
    /// Flutter Web 应用程序的 URL 中删除前导`#`: https://blog.csdn.net/qq_39132095/article/details/123321815
    ///设置URL策略为路径
    ///setPathUrlStrategy 方法是 package:flutter_web_plugins 包中的一个方法，它的作用是设置URL策略，以在浏览器中启用路径而不是哈希（hash）的路由。在使用这个方法之前，通常需要在应用程序的入口处调用 WidgetsFlutterBinding.ensureInitialized()
    setPathUrlStrategy();

    /// SpUtil 用于方便地进行SharedPreferences（持久化存储）操作的一个工具类,本地数据存储:https://blog.csdn.net/qq_42795723/article/details/127065348
    await SpUtil.getInstance();

    /// 1.22 预览功能: 在输入频率与显示刷新率不匹配情况下提供平滑的滚动效果
    // GestureBinding.instance?.resamplingEnabled = true;
    runApp(MyApp());
  });

  /// 隐藏状态栏。为启动页、引导页设置。
  /// 去除底部虚拟操作按钮,是为了全屏展示
  ///setEnabledSystemUIMode 设置全屏显示,用 manual 的方式可以指定显下面或下面的 overlay，或都不显示
  /// SystemUiOverlay.bottom 显示下面
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  // TODO(weilu): 启动体验不佳。状态栏、导航栏在冷启动开始的一瞬间为黑色，且无法通过隐藏、修改颜色等方式进行处理。。。
  // 相关问题跟踪：https://github.com/flutter/flutter/issues/73351
}

class MyApp extends StatelessWidget {
  /* MyApp 类的构造函数
   *  super.key: 这是构造函数的命名参数，表示调用父类构造函数时使用的键。super 关键字表示调用父类的构造函数。在这里，key 是 Widget 类的构造函数的一个可选参数，用于标识和查找 Widget
   *  this.home: 这是构造函数的命名参数，表示 MyApp 类的 home 属性。home 是一个 Widget，通常表示应用程序的主页
   *  this.theme: 这是构造函数的命名参数，表示 MyApp 类的 theme 属性。theme 是一个 ThemeData 类型的对象，用于定义应用程序的整体主题样式
  */
  MyApp({super.key, this.home, this.theme}) {
    Log.init();
    initDio();
    Routes.initRoutes();
    initQuickActions();
  }

  final Widget? home;
  final ThemeData? theme;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  //初始化请求Dio(设置拦截器)
  void initDio() {
    /* 在 Dart 和 Flutter 中，拦截器（Interceptor）通常与网络请求库一起使用，用于在请求发出和响应返回之间插入一些逻辑。
    *  这些逻辑可能包括添加请求头、记录日志、处理错误等。一个常见的 Dart 网络请求库是 Dio，下面我会通过 Dio 中的拦截器来说明。
    *  Dio拦截简介:https://juejin.cn/post/6985150499637067812
    
    *   <Interceptor>: 这是一个泛型（generic）参数，指定了 List 中存储的对象类型。
    
    *   Dio 中的拦截器是通过实现 Interceptor 接口来创建的。这个接口包含了两个方法：onRequest 和 onResponse，分别用于在发出请求和收到响应时执行相关逻辑。
    
    *   在这里，Interceptor 是一种类型，可能是某个库或框架中定义的拦截器类型。
    *   拦截器通常用于在网络请求或其他操作中插入一些逻辑，例如添加请求头、处理错误等
    */
    final List<Interceptor> interceptors = <Interceptor>[];

    /// 统一添加身份验证请求头
    interceptors.add(AuthInterceptor());

    /// 刷新Token
    interceptors.add(TokenInterceptor());

    /// 打印Log(生产模式去除)
    if (!Constant.inProduction) {
      interceptors.add(LoggingInterceptor());
    }

    /// 适配数据(根据自己的数据结构，可自行选择添加)
    interceptors.add(AdapterInterceptor());
    configDio(
      baseUrl: 'https://api.github.com/',
      interceptors: interceptors,
    );
  }

  void initQuickActions() {
    if (Device.isMobile) {
      //QuickActions 允许用户直接从他们的设备主屏幕与应用程序交互
      const QuickActions quickActions = QuickActions();
      if (Device.isIOS) {
        // Android每次是重新启动activity，所以放在了splash_page处理。
        // 总体来说使用不方便，这种动态的方式在安卓中局限性高。这里仅做练习使用。
        quickActions.initialize((String shortcutType) async {
          if (shortcutType == 'demo') {
            navigatorKey.currentState?.push<dynamic>(MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const DemoPage(),
            ));
          }
        });
      }

      quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
          type: 'demo',
          localizedTitle: 'Demo',
          icon: 'flutter_dash_black'
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    //MultiProvider 专门为了解决多状态共存的情况而设计: https://juejin.cn/post/6994958494642388999
    final Widget app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider())
      ],
      //Consumer2: https://juejin.cn/post/6844904182676209677
      //Consumer大家族，一共六位成员，Consumer后面的数字代表了Consumer可接收的数据类数量。
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (_, ThemeProvider provider, LocaleProvider localeProvider, __) {
          return _buildMaterialApp(provider, localeProvider);
        },
      ),
    );

    /// Toast 配置
    /// OKToast 是一款 在 flutter 上 使用的 toast 插件,使用简单, 可定制性强, 纯 flutter, 调用不用 context.
    return OKToast(
      backgroundColor: Colors.black54,
      textPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      radius: 20.0,
      position: ToastPosition.bottom,
      child: app
    );
  }

  Widget _buildMaterialApp(ThemeProvider provider, LocaleProvider localeProvider) {
    return MaterialApp(
      title: 'Flutter Deer',
      // showPerformanceOverlay: true, //显示性能标签
      // debugShowCheckedModeBanner: false, // 去除右上角debug的标签
      // checkerboardRasterCacheImages: true,
      // showSemanticsDebugger: true, // 显示语义视图
      // checkerboardOffscreenLayers: true, // 检查离屏渲染

      theme: theme ?? provider.getTheme(),
      darkTheme: provider.getTheme(isDarkMode: true),
      themeMode: provider.getThemeMode(),
      home: home ?? const SplashPage(),
      onGenerateRoute: Routes.router.generator,
      localizationsDelegates: DeerLocalizations.localizationsDelegates,
      supportedLocales: DeerLocalizations.supportedLocales,
      locale: localeProvider.locale,
      navigatorKey: navigatorKey,
      builder: (BuildContext context, Widget? child) {
        /// 仅针对安卓
        if (Device.isAndroid) {
          /// 切换深色模式会触发此方法，这里设置导航栏颜色
          ThemeUtils.setSystemNavigationBar(provider.getThemeMode());
        }

        /// 保证文字大小不受手机系统设置影响 https://www.kikt.top/posts/flutter/layout/dynamic-text/
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      /// 因为使用了fluro，这里设置主要针对Web
      onUnknownRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => const NotFoundPage(),
        );
      },
      restorationScopeId: 'app',
    );
  }
}
