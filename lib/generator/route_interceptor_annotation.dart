import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_mixin_router_ann/flutter_mixin_router_ann.dart';
import 'package:flutter_mixin_router_gen/resource/route_info_resource.dart';
import 'package:source_gen/source_gen.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
class RouteInterceptorAnnotationGenerator
    extends GeneratorForAnnotation<MixinInterceptRoute> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element.kind != ElementKind.FUNCTION) return null;
    String methodName = element.name!;
    String uri = buildStep.inputId.uri.toString();
    String? tName = annotation.peek('tName')?.stringValue;
    if (tName == null || tName.isEmpty) return null;
    String? path = annotation.peek('path')?.stringValue;
    if (path == null || path.isEmpty) return null;
    RouteInfoCollector collector = await buildStep.fetchResource(routeResource);
    Map<String, List<InterceptorRouteInfo>> interceptorRouteMap =
        collector.interceptorRouteMap;
    if (!interceptorRouteMap.containsKey(tName)) {
      interceptorRouteMap[tName] = <InterceptorRouteInfo>[];
    }
    InterceptorRouteInfo routeInfo =
        InterceptorRouteInfo(path, uri, methodName);
    interceptorRouteMap[tName]!.add(routeInfo);
    return null;
  }
}
