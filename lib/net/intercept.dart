
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/util/log_utils.dart';
import 'package:flutter_deer/util/other_utils.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sprintf/sprintf.dart';

import 'dio_utils.dart';
import 'error_handle.dart';

//扩展拦截器类:https://juejin.cn/post/6844903940056694798#heading-4
class AuthInterceptor extends Interceptor {

  // 自定义请求拦截器
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //工具类介绍:https://www.jianshu.com/p/02907d4ae438
    //SpUtil.getString(key):读取持久化中的数据, 单例"同步"SharedPreferences工具类
    //使用了某个 .nullSafe 的包，可以确保你的代码也是空安全的，以获得 Dart 空安全特性的优势
    final String accessToken = SpUtil.getString(Constant.accessToken).nullSafe;
    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'token $accessToken';
    }
    if (!Device.isWeb) {//检测是否在 Web 环境中的标志
      // https://developer.github.com/v3/#user-agent-required
      //将其值设置为 'Mozilla/5.0'，这是一个通用的用户代理字符串，模拟了一个基本的网页浏览器
      options.headers['User-Agent'] = 'Mozilla/5.0';
    }
    super.onRequest(options, handler);
  }
}

class TokenInterceptor extends QueuedInterceptor {

  Dio? _tokenDio;

  Future<String?> getToken() async {

    final Map<String, String> params = <String, String>{};
    params['refresh_token'] = SpUtil.getString(Constant.refreshToken).nullSafe;
    try {
      _tokenDio ??= Dio();
      //获取这个 Dio 实例的配置选项
      _tokenDio!.options = DioUtils.instance.dio.options;
      final Response<dynamic> response = await _tokenDio!.post<dynamic>('lgn/refreshToken', data: params);
      if (response.statusCode == ExceptionHandle.success) {
        return (json.decode(response.data.toString()) as Map<String, dynamic>)['access_token'] as String;
      }
    } catch(e) {
      Log.e('刷新Token失败！');
    }
    return null;
  }

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    //401代表token过期
    if (response.statusCode == ExceptionHandle.unauthorized) {
      Log.d('-----------自动刷新Token------------');
      final String? accessToken = await getToken(); // 获取新的accessToken
      Log.e('-----------NewToken: $accessToken ------------');
      SpUtil.putString(Constant.accessToken, accessToken.nullSafe);

      if (accessToken != null) {
        // 重新请求失败接口
        final RequestOptions request = response.requestOptions;
        request.headers['Authorization'] = 'Bearer $accessToken';

        final Options options = Options(
          headers: request.headers,
          method: request.method,
        );

        try {
          Log.e('----------- 重新请求接口 ------------');
          /// 避免重复执行拦截器，使用tokenDio
          final Response<dynamic> response = await _tokenDio!.request<dynamic>(request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: options,
            onReceiveProgress: request.onReceiveProgress,
          );
          return handler.next(response);
        } on DioError catch (e) {
          return handler.reject(e);
        }
      }
    }
    super.onResponse(response, handler);
  }
}


//打印请求内容:https://juejin.cn/post/6844903940056694798#heading-5
//通过控制台打印所有的请求信息以及相应信息，以方便我们调试请求中的问题
class LoggingInterceptor extends Interceptor{

  late DateTime _startTime;
  late DateTime _endTime;
  
  // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    Log.d('----------Start----------');
    if (options.queryParameters.isEmpty) {
      Log.d('RequestUrl: ${options.baseUrl}${options.path}');
    } else {
      Log.d('RequestUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}');
    }
    Log.d('RequestMethod: ${options.method}');
    Log.d('RequestHeaders:${options.headers}');
    Log.d('RequestContentType: ${options.contentType}');
    Log.d('RequestData: ${options.data}');
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      Log.d('ResponseCode: ${response.statusCode}');
    } else {
      Log.e('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    Log.json(response.data.toString());
    Log.d('----------End: $duration 毫秒----------');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Log.d('----------Error-----------');
    super.onError(err, handler);
  }
}

/// 适配器拦截
class AdapterInterceptor extends Interceptor{

  static const String _kMsg = 'msg';
  static const String _kSlash = "'";
  static const String _kMessage = 'message';

  static const String _kDefaultText = '无返回信息';
  static const String _kNotFound = '未找到查询信息';

  static const String _kFailureFormat = '{"code":%d,"message":"%s"}';
  static const String _kSuccessFormat = '{"code":0,"data":%s,"message":""}';
  
  @override
  //dynamic告诉变异器代码变量不用做类型检测,并且写代码的人知道自己在做什么:https://blog.51cto.com/liyuanjinglyj/5016333
  //dynamic 可以表示任何类型:https://juejin.cn/post/6932012405702524941
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final Response<dynamic> r = adapterData(response);
    super.onResponse(r, handler);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      adapterData(err.response!);
    }
    super.onError(err, handler);
  }

  //对响应数据的处理,进行各种适配,然后返回结果
  Response<dynamic> adapterData(Response<dynamic> response) {
    String result;
    String content = response.data?.toString() ?? '';
    /// 成功时，直接格式化返回
    if (response.statusCode == ExceptionHandle.success || response.statusCode == ExceptionHandle.success_not_content) {
      if (content.isEmpty) {
        content = _kDefaultText;
      }
      result = sprintf(_kSuccessFormat, [content]);
      response.statusCode = ExceptionHandle.success;
    } else {
      if (response.statusCode == ExceptionHandle.not_found) {
        /// 错误数据格式化后，按照成功数据返回
        result = sprintf(_kFailureFormat, [response.statusCode, _kNotFound]);
        response.statusCode = ExceptionHandle.success;
      } else {
        if (content.isEmpty) {
          // 一般为网络断开等异常
          result = content;
        } else {
          String msg;
          try {
            content = content.replaceAll(r'\', '');
            if (_kSlash == content.substring(0, 1)) {
              content = content.substring(1, content.length - 1);
            }
            final Map<String, dynamic> map = json.decode(content) as Map<String, dynamic>;
            if (map.containsKey(_kMessage)) {
              msg = map[_kMessage] as String;
            } else if (map.containsKey(_kMsg)) {
              msg = map[_kMsg] as String;
            } else {
              msg = '未知异常';
            }
            result = sprintf(_kFailureFormat, [response.statusCode, msg]);
            // 401 token失效时，单独处理，其他一律为成功
            if (response.statusCode == ExceptionHandle.unauthorized) {
              response.statusCode = ExceptionHandle.unauthorized;
            } else {
              response.statusCode = ExceptionHandle.success;
            }
          } catch (e) {
//            Log.d('异常信息：$e');
            // 解析异常直接按照返回原数据处理（一般为返回500,503 HTML页面代码）
            result = sprintf(_kFailureFormat, [response.statusCode, '服务器异常(${response.statusCode})']);
          }
        }
      }
    }
    response.data = result;
    return response;
  }
}
