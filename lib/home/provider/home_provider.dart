
import 'package:flutter/material.dart';

//HomeProvider类继承了RestorableInt，这表示它是一个可以保存和还原状态的整数。
class HomeProvider extends RestorableInt {
  //HomeProvider的构造函数通过super(0)调用了父类RestorableInt的构造函数，将初始值设置为0。这是RestorableInt的一种使用方式，它可以用于保存和还原整数类型的状态。
  HomeProvider() : super(0);
}
