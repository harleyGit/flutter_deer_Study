import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/order/page/order_list_page.dart';
import 'package:flutter_deer/order/provider/order_page_provider.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/routers/fluro_navigator.dart';
import 'package:flutter_deer/util/image_utils.dart';
import 'package:flutter_deer/util/screen_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/load_image.dart';
import 'package:flutter_deer/widgets/my_card.dart';
import 'package:flutter_deer/widgets/my_flexible_space_bar.dart';
import 'package:provider/provider.dart';

import '../order_router.dart';

/// design/3订单/index.html
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

/**
 * SingleTickerProviderStateMixin 是 Flutter 框架提供的一个 mixin，
 * 用于在一个 State 对象中管理单个 Ticker 对象。Ticker 通常用于创建动画。
 * 
 * AutomaticKeepAliveClientMixin 是 Flutter 提供的一个 mixin，用于在使用 PageView 或 TabBarView 等滑动切换页面的场景中，
 * 保持页面状态不被销毁。它通常与 SingleTickerProviderStateMixin 一同使用，
 * 以实现在页面切换时保持页面状态。
 * 
 * 当使用 AutomaticKeepAliveClientMixin 时，Flutter 会调用一个特定的回调函数 wantKeepAlive，
 * 你需要在该回调中返回 true，以指示是否要保持页面状态。
 * 如果返回 true，Flutter 将会缓存并保持页面状态；如果返回 false，则会在页面切换时销毁状态。
*/
class _OrderPageState extends State<OrderPage>
    with
        AutomaticKeepAliveClientMixin<OrderPage>,
        SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  TabController? _tabController;
  OrderPageProvider provider = OrderPageProvider();

  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 预先缓存剩余切换图片
      _preCacheImage();
    });
  }

  void _preCacheImage() {
    //用于预加载图片到内存中，以提前加载图片资源，减少在实际显示时的加载延迟。
    //这个函数通常用于提高用户体验，特别是在需要显示大量图片或需要较长时间加载的图片时。
    precacheImage(ImageUtils.getAssetImage('order/xdd_n'), context);
    precacheImage(ImageUtils.getAssetImage('order/dps_s'), context);
    precacheImage(ImageUtils.getAssetImage('order/dwc_s'), context);
    precacheImage(ImageUtils.getAssetImage('order/ywc_s'), context);
    precacheImage(ImageUtils.getAssetImage('order/yqx_s'), context);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  /// https://github.com/simplezhli/flutter_deer/issues/194
  @override
  // ignore: must_call_super
  void didChangeDependencies() {}

  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = context.isDark;
    return ChangeNotifierProvider<OrderPageProvider>(
      create: (_) => provider,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            /// 像素对齐问题的临时解决方法
            SafeArea(
              child: SizedBox(
                height: 105,
                width: double.infinity,
                child: isDark
                    ? null
                    : const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colours.orange, Color(0xFF4647FA)]),
                        ),
                      ),
              ),
            ),
            /**
             * NestedScrollView: 嵌套滚动视图的组件，它可以实现在一个主滚动视图中包含多个子滚动视图，并且这些滚动视图之间可以联动，
             * 例如在滑动顶部的滚动区域时，底部的滚动区域也会相应地跟随滑动。
            */
            NestedScrollView(
              key: const Key('order_list'),
              //ClampingScrollPhysics 是 Flutter 中的一个滚动物理模型，它的作用是在滚动到边界时将滚动效果进行限制（clamp），防止继续滚动超过边界
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(
                      context), //构建那些会在滚动视图顶部展示并且具有特殊滚动行为的 Sliver 子组件集合
              body: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  //onNotification 参数是一个回调函数，每当有匹配的通知发出时，此函数会被调用，并传入相应的通知对象
                  /// PageView的onPageChanged是监听ScrollUpdateNotification，会造成滑动中卡顿。这里修改为监听滚动结束再更新、
                  /**
                   * notification.depth == 0: 在回调函数内部，首先检查了通知的深度（depth）是否为0。
                   * 深度为0意味着我们正在处理最外层的滚动视图。
                   * 这是因为嵌套滚动视图中可能存在多个层级的滚动通知，深度为0代表是最外层的滚动事件
                   * 
                   * notification is ScrollEndNotification: 判断当前的滚动通知是否为 ScrollEndNotification 类型，这表示滚动已结束
                   */
                  if (notification.depth == 0 &&
                      notification is ScrollEndNotification) {
                    //这里将notification.metrics强制转换为PageMetrics类型，PageMetrics包含了有关页面的度量信息，比如当前页数。
                    final PageMetrics metrics =
                        notification.metrics as PageMetrics;
                    //这里获取当前页面的页数，如果metrics.page为null，则默认为0，然后调用round()方法将其四舍五入为整数。
                    final int currentPage = (metrics.page ?? 0).round();
                    //用于检查当前页面是否与上次报告的页面不同。如果不同，则表示页面发生了变化，需要执行相应的操作
                    if (currentPage != _lastReportedPage) {
                      _lastReportedPage = currentPage;
                      _onPageChange(currentPage);
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  //PageView是Flutter中用于显示可滚动页面视图的小部件
                  key: const Key('pageView'),
                  itemCount: 5,
                  controller: _pageController,
                  itemBuilder: (_, index) => OrderListPage(index: index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context) {
    return <Widget>[
      //SliverOverlapAbsorber 的主要作用是在可滚动视图中吸收额外的滚动空间，以便让内容正常显示，而不会被覆盖。
      //这在一些需要自定义滚动效果的场景中很有用，特别是在具有折叠标题栏或伸缩视图的布局中
      SliverOverlapAbsorber(
        //确保在滚动时，各个 Sliver 能够正确协同工作，以实现预期的滑动效果。
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                NavigatorUtils.push(context, OrderRouter.orderSearchPage);
              },
              tooltip: '搜索',
              icon: LoadAssetImage(
                'order/icon_search',
                width: 22.0,
                height: 22.0,
                color: ThemeUtils.getIconColor(context),
              ),
            )
          ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          expandedHeight: 100.0, // 不随着滑动隐藏标题
          pinned: true, // 固定在顶部
          /**
           * FlexibleSpaceBar是Flutter中SliverAppBar的一个关键组成部分，它用于创建灵活的应用栏空间，允许在应用栏收缩和展开时显示不同的内容。
           * FlexibleSpaceBar通常用于创建可伸缩的应用栏，例如在滚动时隐藏应用栏或显示不同的背景内容
          */
          flexibleSpace: MyFlexibleSpaceBar(
            background: isDark
                ? Container(
                    height: 113.0,
                    color: Colours.dark_bg_color,
                  )
                : LoadAssetImage(
                    'order/order_bg',
                    width: context.width,
                    height: 113.0,
                    fit: BoxFit.fill,
                  ),
            centerTitle: true,
            titlePadding:
                const EdgeInsetsDirectional.only(start: 16.0, bottom: 14.0),
            collapseMode: CollapseMode.pin,
            title: Text(
              '订单12345',
              style: TextStyle(color: ThemeUtils.getIconColor(context)),
            ),
          ),
        ),
      ),
      /**
       * SliverPersistentHeader是用于创建可持续的可滚动头部部件的组件。
       * 它通常与CustomScrollView一起使用，用于创建具有可滚动内容的自定义滚动视图。
      */
      SliverPersistentHeader(
        pinned: true, //用于指定头部部件是否应该在滚动时保持固定位置
        delegate: SliverAppBarDelegate(
          DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? Colours.dark_bg_color : null,
              image: isDark
                  ? null
                  : DecorationImage(
                      image: ImageUtils.getAssetImage('order/order_bg1'),
                      fit: BoxFit.fill,
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MyCard(
                child: Container(
                  height: 80.0,
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TabBar(
                    labelPadding: EdgeInsets.zero,
                    controller: _tabController,
                    labelColor:
                        context.isDark ? Colours.dark_text : Colours.text,
                    unselectedLabelColor:
                        context.isDark ? Colours.dark_text_gray : Colours.text,
                    labelStyle: TextStyles.textBold14,
                    unselectedLabelStyle: const TextStyle(
                      fontSize: Dimens.font_sp14,
                    ),
                    indicatorColor: Colors.transparent,
                    tabs: const <Widget>[
                      _TabView(0, '新订单'),
                      _TabView(1, '待配送'),
                      _TabView(2, '待完成'),
                      _TabView(3, '已完成'),
                      _TabView(4, '已取消'),
                    ],
                    onTap: (index) {
                      if (!mounted) {
                        return;
                      }
                      //将页面跳转到指定的索引位置。jumpToPage方法接受一个整数参数index，表示要跳转到的页面索引，索引从0开始计数
                      _pageController.jumpToPage(index);
                    },
                  ),
                ),
              ),
            ),
          ),
          80.0,
        ),
      ),
    ];
  }

  /**
   * 创建了一个PageController对象，用于控制PageView的滚动和页面跳转
   * 
   * PageController是一个可用于控制PageView小部件的控制器，可以用于手动地控制页面滚动、跳转到特定页面等操作。
   * 在这里，使用final关键字声明了一个名为_pageController的PageController对象，并初始化为默认构造函数创建的实例。
  */
  final PageController _pageController = PageController();
  Future<void> _onPageChange(int index) async {
    provider.setIndex(index);

    /// 这里没有指示器，所以缩短过渡动画时间，减少不必要的刷新
    _tabController?.animateTo(index, duration: Duration.zero);
  }
}

List<List<String>> img = [
  ['order/xdd_s', 'order/xdd_n'],
  ['order/dps_s', 'order/dps_n'],
  ['order/dwc_s', 'order/dwc_n'],
  ['order/ywc_s', 'order/ywc_n'],
  ['order/yqx_s', 'order/yqx_n']
];

List<List<String>> darkImg = [
  ['order/dark/icon_xdd_s', 'order/dark/icon_xdd_n'],
  ['order/dark/icon_dps_s', 'order/dark/icon_dps_n'],
  ['order/dark/icon_dwc_s', 'order/dark/icon_dwc_n'],
  ['order/dark/icon_ywc_s', 'order/dark/icon_ywc_n'],
  ['order/dark/icon_yqx_s', 'order/dark/icon_yqx_n']
];

class _TabView extends StatelessWidget {
  const _TabView(this.index, this.text);

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> imgList = context.isDark ? darkImg : img;
    return Stack(
      children: <Widget>[
        Container(
          width: 46.0,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: <Widget>[
              /// 使用context.select替代Consumer
              LoadAssetImage(
                context.select<OrderPageProvider, int>(
                            (value) => value.index) ==
                        index
                    ? imgList[index][0]
                    : imgList[index][1],
                width: 24.0,
                height: 24.0,
              ),
              Gaps.vGap4,
              Text(text),
            ],
          ),
        ),
        Positioned(
          right: 0.0,
          child: index < 3
              ? DecoratedBox(//DecoratedBox 是 Flutter 中的一个小部件，用于在子部件周围绘制装饰（例如背景、边框等）。它是一个简单但功能强大的小部件，可以通过设置不同的装饰来改变子部件的外观和样式。
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.0),
                    child: Text(
                      '10',
                      style: TextStyle(
                          color: Colors.white, fontSize: Dimens.font_sp12),
                    ),
                  ),
                )
              : Gaps.empty,
        )
      ],
    );
  }
}

/**
 * SliverPersistentHeaderDelegate是Flutter中用于自定义可持久化头部的抽象类。
 * 它允许开发人员自定义SliverAppBar中展示的内容，并根据滚动行为动态更新。
*/
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this.widget, this.height);

  final Widget widget;
  final double height;

  // minHeight 和 maxHeight 的值设置为相同时，header就不会收缩了
  @override
  double get minExtent => height; // 最小高度

  @override
  double get maxExtent => height; // 最大高度

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 返回需要展示的头部内容
    return widget;
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    // 检查是否需要重新构建头部内容
    return true;
  }
}
