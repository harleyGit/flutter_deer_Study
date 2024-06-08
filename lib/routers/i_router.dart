
import 'package:fluro/fluro.dart';

abstract class IRouterProvider {
  //FluroRouter 是 Flutter 中的一个路由管理工具，它提供了一种方便的方式来定义和管理应用程序中的路由，使得路由的管理更加灵活和可扩展
  void initRouter(FluroRouter router);
}
