import 'package:flutter/material.dart';

//ChangeNotifier 是 Flutter 中实现状态管理的基础类之一，当状态发生变化时，它会通知侦听器（通常是 Consumer 或 Provider.of），以便更新 UI。
class GoodsPageProvider extends ChangeNotifier {

  /// Tab的下标
  int _index = 0;
  int get index => _index;
  /// 商品数量
  final List<int> _goodsCountList = [0, 0, 0];
  List<int> get goodsCountList => _goodsCountList;

  /// 选中商品分类下标
  int _sortIndex = 0;
  int get sortIndex => _sortIndex;

  void setSortIndex(int sortIndex) {
    _sortIndex = sortIndex;
    notifyListeners();
  }
 
  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

  void setGoodsCount(int count) {
    _goodsCountList[index] = count;
    notifyListeners();
  }
}
