import 'package:build/build.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
class BaseRouteInfo {
  final String path;
  final String uri;

  BaseRouteInfo(this.path, this.uri);
}

class PureRouteInfo extends BaseRouteInfo {
  final String pageName;

  PureRouteInfo(String path, String uri, this.pageName) : super(path, uri);
}

class InterceptorRouteInfo extends BaseRouteInfo {
  final String methodName;

  InterceptorRouteInfo(String path, String uri, this.methodName)
      : super(path, uri);
}

class RouteInfoCollector {
  final Map<String, List<PureRouteInfo>> pureRouteMap = {};
  final Map<String, List<InterceptorRouteInfo>> interceptorRouteMap = {};

  RouteInfoCollector._();

  void _dispose() {
    pureRouteMap.clear();
    interceptorRouteMap.clear();
  }
}

final Resource<RouteInfoCollector> routeResource = Resource<RouteInfoCollector>(
  () => RouteInfoCollector._(),
  dispose: (collector) => collector._dispose(),
);
