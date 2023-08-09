import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_mixin_router_ann/flutter_mixin_router_ann.dart';
import 'package:flutter_mixin_router_gen/resource/route_info_resource.dart';
import 'package:source_gen/source_gen.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
class RouteAnnotationGenerator extends GeneratorForAnnotation<MixinRoute> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element.kind != ElementKind.CLASS) return null;
    String pageName = element.name!;
    String uri = buildStep.inputId.uri.toString();
    String? tName = annotation.peek('tName')?.stringValue;
    if (tName == null || tName.isEmpty) return null;
    String? path = annotation.peek('path')?.stringValue;
    if (path == null || path.isEmpty) return null;
    bool? arg = annotation.peek('arg')?.boolValue;
    if (arg == null) return null;
    RouteInfoCollector collector = await buildStep.fetchResource(routeResource);
    Map<String, List<PureRouteInfo>> pureRouteMap = collector.pureRouteMap;
    if (!pureRouteMap.containsKey(tName)) {
      pureRouteMap[tName] = <PureRouteInfo>[];
    }
    PureRouteInfo routeInfo = PureRouteInfo(path, uri, pageName, arg);
    pureRouteMap[tName]!.add(routeInfo);
    return null;
  }
}
