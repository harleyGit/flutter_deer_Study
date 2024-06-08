import 'package:azlistview/azlistview.dart';
import 'package:flutter_deer/generated/json/bank_entity.g.dart';
import 'package:flutter_deer/generated/json/base/json_field.dart';

/**
 * bank_entity.dart 和 bank_entity.g.dart 通常是在使用代码生成库（code generation）时出现的文件。
 * 这两个文件之间的关系涉及到 Dart 中的序列化、反序列化以及其他一些与代码生成相关的操作
 * 
 * 代码生成库是一种工具，用于在 Dart 编程语言中生成代码。这些工具可以帮助开发者自动生成重复性高、模板性质的代码，从而提高开发效率。
 * 在 Dart 生态系统中，有一些常见的代码生成库，其中包括但不限于以下几种：
 * 
 *    1.json_serializable： 用于生成 JSON 序列化和反序列化相关的代码。通过在 Dart 类上添加注解，该库能够自动生成 toJson 和 fromJson 方法
 *    2.moor： 用于生成 SQLite 数据库相关的代码。该库允许你使用 Dart 代码定义数据库表和查询，然后通过代码生成生成相应的数据库操作代码
 *    3.uilt_value： 用于生成不可变（immutable）数据模型的代码。通过添加注解，该库可以自动生成实现不可变模型的类，包括比较、哈希等方法
*/

//在使用json_serializable库时，它通过分析Dart类中的注解（@JsonSerializable()）和成员变量，生成了一些帮助序列化和反序列化的代码。其中 $BankEntityFromJson 函数就是一个由 json_serializable 生成的函数，用于将一个 JSON 对象转换为 BankEntity 类的实例
@JsonSerializable()
class BankEntity with ISuspensionBean {
  //构造函数,自动赋值; 这些参数都是可选的
  BankEntity({this.id, this.bankName, this.firstLetter});

  //使用了json_serializable库中生成的代码。
  //  通过调用由 json_serializable 自动生成的函数 $BankEntityFromJson，利用传入的 JSON 数据来创建一个 BankEntity 类的实例。
  //  这通常在进行网络请求时，接收到 JSON 响应数据后使用，以方便地将 JSON 转换为 Dart 对象
  //具体来说，它是使用Dart的factory constructor，用于从JSON数据创建BankEntity类的实例
  //  factory 关键字： 表示这是一个工厂构造函数。工厂构造函数是一种特殊的构造函数，它并不一定要创建一个新的实例，而是可以返回一个已存在的实例或者创建一个不同类型的实例
  //  BankEntity.fromJson： 这是工厂构造函数的名称。通常，fromJson 表示这个构造函数用于从 JSON 数据中创建对象
  //  => $BankEntityFromJson(json)： 这是构造函数的函数体，箭头(=>)后面的表达式调用了由 json_serializable 生成的 $BankEntityFromJson 函数，该函数用于将JSON数据映射到 BankEntity 类的实例
  factory BankEntity.fromJson(Map<String, dynamic> json) =>
      $BankEntityFromJson(json);

  Map<String, dynamic> toJson() => $BankEntityToJson(this);

  int? id;
  String? bankName;
  String? firstLetter;

  @override
  String getSuspensionTag() {
    return firstLetter ?? '';
  }
}
