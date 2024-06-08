import 'package:flutter/material.dart';

class OrderPageProvider extends ChangeNotifier {

  /// Tab的下标
  int _index = 0;
  int get index => _index;
  
  void refresh() {
    notifyListeners();// 通知所有监听器（观察者）状态已发生变化
  }
  
  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

}
