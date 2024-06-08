import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/util/log_utils.dart';
import 'base_entity.dart';
import 'error_handle.dart';

/// 默认dio配置
Duration _connectTimeout = const Duration(seconds: 15);
Duration _receiveTimeout = const Duration(seconds: 15);
Duration _sendTimeout = const Duration(seconds: 10);
String _baseUrl = '';
List<Interceptor> _interceptors = [];

/// 初始化Dio配置
void configDio({
  Duration? connectTimeout,
  Duration? receiveTimeout,
  Duration? sendTimeout,
  String? baseUrl,
  List<Interceptor>? interceptors,
}) {
  _connectTimeout = connectTimeout ?? _connectTimeout;
  _receiveTimeout = receiveTimeout ?? _receiveTimeout;
  _sendTimeout = sendTimeout ?? _sendTimeout;
  _baseUrl = baseUrl ?? _baseUrl;
  _interceptors = interceptors ?? _interceptors;
}

/**
 * 定义回调函数，特别是在异步操作完成后的回调中
 *  NetSuccessCallback<T>： 这是类型别名的名称。NetSuccessCallback 是一个泛型类型，它接受一个类型参数 T
 *  = Function(T data)： 这是类型别名的具体定义。它表示 NetSuccessCallback 是一个接受一个泛型类型为 T 的参数，并返回 void 的函数类型
*/
typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

/// @weilu https://github.com/simplezhli
class DioUtils {
  
  // 公共的获取单例对象的方法
  factory DioUtils() => _singleton;

  // 私有构造函数，防止直接实例化
  DioUtils._() {
    //BaseOptions通常是用于配置HTTP请求的基本选项的类。
    //这个类通常是在使用Dio库进行网络请求时使用的，Dio是一个强大的、可扩展的Flutter和Dart的HTTP请求库
    final BaseOptions options = BaseOptions(
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      /// dio默认json解析，这里指定返回UTF8字符串，自己处理解析。（可也以自定义Transformer实现）
      responseType: ResponseType.plain,
      validateStatus: (_) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: _baseUrl,
      //contentType: Headers.formUrlEncodedContentType, // 适用于post form表单提交
    );
    _dio = Dio(options);
    /// Fiddler抓包代理配置 https://www.jianshu.com/p/d831b1f7c45b
   // _dio.httpClientAdapter = IOHttpClientAdapter()..onHttpClientCreate = (HttpClient client) {
   //   client.findProxy = (uri) {
   //     //proxy all request to localhost:8888
   //     return 'PROXY 10.41.0.132:8888';
   //   };
   //   return client;
   // };

    /// 添加拦截器
    void addInterceptor(Interceptor interceptor) {
      //通过添加拦截器（interceptor），你可以在HTTP请求的不同阶段插入自定义的逻辑。
      //在你的代码中，_dio.interceptors.add(interceptor); 表示将一个拦截器添加到Dio实例 _dio 中
      //每次使用 _dio 进行网络请求时，都会经过你添加的拦截器，执行你在拦截器中定义的逻辑
      _dio.interceptors.add(interceptor);
    }

    //_interceptors是一个拦截器列表，用于存储所有已添加的拦截器。这里的 forEach 方法遍历 _interceptors 列表中的每个拦截器，并对每个拦截器调用 addInterceptor 方法

    _interceptors.forEach(addInterceptor);
  }

  /**
   * 定义了一个私有的静态成员 _singleton，并初始化了一个 DioUtils 的单例对象
  */
  static final DioUtils _singleton = DioUtils._();

  static DioUtils get instance => DioUtils();

  static late Dio _dio;

  Dio get dio => _dio;

  // 数据返回格式统一，统一处理异常
  Future<BaseEntity<T>> _request<T>(String method, String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    /**
     * 这段代码是在使用 Dio 库进行网络请求，通过 await 等待异步操作的完成，并将响应数据的类型指定为 String。
     * 在请求完成后，将得到的响应数据存储在 response 变量中
     *    
     *  _dio.request<String>： 这是 Dio 库中的一个方法，用于发起网络请求。
     *  它可能是一个 GET、POST 或其他 HTTP 方法的请求，取决于 method 参数的值。<String> 指定了预期的响应类型，即希望接收的响应数据的类型是 String
     * 
     *  Response<String>： 表示 Dio 库中请求的响应类型。在这里，指定了响应数据的类型是 String
    */
    final Response<String> response = await _dio.request<String>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: _checkOptions(method, options),
      cancelToken: cancelToken,
    );
    try {
      final String data = response.data.toString();
      /// 集成测试无法使用 isolate https://github.com/flutter/flutter/issues/24703
      /// 使用compute条件：数据大于10KB（粗略使用10 * 1024）且当前不是集成测试（后面可能会根据Web环境进行调整）
      /// 主要目的减少不必要的性能开销
      final bool isCompute = !Constant.isDriverTest && data.length > 10 * 1024;
      debugPrint('isCompute:$isCompute');

      /**
       * 这段代码的目的是将 parseData 函数在隔离中执行，以提高性能并避免阻塞主线程。如果 compute 函数执行失败或无法在隔离中运行，则回退到在主线程中直接调用 parseData 函数。
       * 这种方式是为了更好地利用 Dart 的隔离特性，提高应用程序的性能。
       * 
       *  compute 函数： 这是 Dart 的计算函数，用于在隔离中执行计算密集型的操作。
       *  它接受两个参数：第一个参数是要执行的函数（这里是 parseData），第二个参数是该函数所需的参数（这里是 data）
      */
      final Map<String, dynamic> map = isCompute ? await compute(parseData, data) : parseData(data);

      //解析数据为指定范型模型
      return BaseEntity<T>.fromJson(map);
    } catch(e) {
      debugPrint(e.toString());
      return BaseEntity<T>(ExceptionHandle.parse_error, '数据解析错误！', null);
    }
  }

  Options _checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }

  Future<dynamic> requestNetwork<T>(Method method, String url, {
    NetSuccessCallback<T?>? onSuccess,
    NetErrorCallback? onError,
    Object? params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _request<T>(method.value, url,
      data: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ).then<void>((BaseEntity<T> result) {
      if (result.code == 0) {
        //call 方法是一种特殊的方法，允许你将对象当作函数一样调用。
        //具体地说，如果一个类实现了 call 方法，那么它的实例就可以像函数一样被调用
        // 直接调用，类似于 onSuccess(result.data);
        onSuccess?.call(result.data);
      } else {
        _onError(result.code, result.message, onError);
      }
    }, onError: (dynamic e) {
      _cancelLogPrint(e, url);
      final NetError error = ExceptionHandle.handleException(e);
      _onError(error.code, error.msg, onError);
    });
  }

  /// 统一处理(onSuccess返回T对象，onSuccessList返回 List<T>)
  void asyncRequestNetwork<T>(Method method, String url, {
    NetSuccessCallback<T?>? onSuccess,
    NetErrorCallback? onError,
    Object? params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    //Stream.fromFuture 是一个用于创建 Stream 对象的方法，该方法从一个 Future 对象中生成一个单一事件的 Stream。
    //它允许你将一个异步操作（Future）转换为一个可以监听的事件流（Stream）
    Stream.fromFuture(_request<T>(method.value, url,
      data: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    )).asBroadcastStream()
        .listen((result) {//.asBroadcastStream() 方法用于将一个单订阅（single-subscription）的 Stream 转换为广播（broadcast）的 Stream。广播流可以被多个监听器（listeners）订阅，而不是单个订阅
      if (result.code == 0) {
        if (onSuccess != null) {
          onSuccess(result.data);
        }
      } else {
        _onError(result.code, result.message, onError);
      }
    }, onError: (dynamic e) {
      _cancelLogPrint(e, url);
      final NetError error = ExceptionHandle.handleException(e);
      _onError(error.code, error.msg, onError);
    });
  }

  void _cancelLogPrint(dynamic e, String url) {
    /**
     * isCancel 是 CancelToken 类中的一个方法。它用于检查当前的令牌是否已经被取消
    *   isCancel 方法接受一个参数 e，通常是捕获到的异常对象。
        它会检查该异常对象是否与取消相关，如果是取消异常，则返回 true；否则返回 false。
        这是用于在处理异步任务时检查是否应该取消任务的便捷方法
    */
    if (e is DioError && CancelToken.isCancel(e)) {
      Log.e('取消请求接口： $url');
    }
  }

  void _onError(int? code, String msg, NetErrorCallback? onError) {
    if (code == null) {
      code = ExceptionHandle.unknown_error;
      msg = '未知异常';
    }
    Log.e('接口请求异常： code: $code, mag: $msg');
    onError?.call(code, msg);
  }
}

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

enum Method {
  get,
  post,
  put,
  patch,
  delete,
  head
}

/// 使用拓展枚举替代 switch判断取值
/// https://zhuanlan.zhihu.com/p/98545689
/// 使用了 Dart 中的扩展语法，通过 extension 关键字将一个新的属性 value 添加到 Method 枚举上。这个属性是一个字符串，表示对应的 HTTP 方法。
/// MethodExtension 是扩展的名称
/// on Method 表示这个扩展是对 Method 枚举类型进行的
/// String get value 定义了一个名为 value 的属性，类型是字符串
extension MethodExtension on Method {
  String get value => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'][index];
}


/**
 * 使用扩展
 * 
 * Method httpMethod = Method.post;
 * print(httpMethod.value);  // 输出: POST
*/