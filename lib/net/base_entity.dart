import 'package:flutter_deer/generated/json/base/json_convert_content.dart';
import 'package:flutter_deer/res/constant.dart';

//BaseEntity<T> 是一个泛型类，使用了泛型参数 T，表示这个类可以接受不同类型的数据
class BaseEntity<T> {

  BaseEntity(this.code, this.message, this.data);

  //dynamic 是一个特殊的类型，表示一个动态类型。它是 Dart 中的一种类型注释，表示该变量可以接受任何类型的值。
  //使用 dynamic 声明的变量可以在运行时接受不同类型的值，而不会在编译时引发类型错误
  BaseEntity.fromJson(Map<String, dynamic> json) {
    code = json[Constant.code] as int?;
    message = json[Constant.message] as String;
    if (json.containsKey(Constant.data)) {
      //Object? 是一个表示任意对象的类型，并且允许其值为null的类型。这与iOS中的对象不完全相同
      //Object 是所有非空类型的基类，它是所有Dart对象的根。而在 Object? 中，? 表示可为空，即这个类型的变量可以接受 null 值
      data = _generateOBJ<T>(json[Constant.data] as Object?);
    }
  }

  int? code;
  late String message;
  // data 是一个泛型类型 T 的数据属性，用于存储实际的数据
  T? data;

  //一个私有方法，用于根据不同的泛型类型 T 来生成对象
  T? _generateOBJ<O>(Object? json) {
    if (json == null) {
      return null;
    }
    if (T.toString() == 'String') {//如果 T 的类型是 String，则将 json 转换为字符串
      return json.toString() as T;
    } else if (T.toString() == 'Map<dynamic, dynamic>') {//如果 T 的类型是 Map<dynamic, dynamic>，则直接返回 json
      return json as T;
    } else {
      /// List类型数据由fromJsonAsT判断处理
      /// 将 json 转换为泛型类型 T
      return JsonConvert.fromJsonAsT<T>(json);
    }
  }
}
