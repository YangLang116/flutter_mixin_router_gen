import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_mixin_router_ann/flutter_mixin_router_ann.dart';
import 'package:flutter_mixin_router_gen/resource/route_info_resource.dart';
import 'package:flutter_mixin_router_gen/utils/route_utils.dart';
import 'package:source_gen/source_gen.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
class RouteTableAnnotationGenerator extends GeneratorForAnnotation<RouterTableList> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    //fetch owner class name
    ConstantReader? constantReader = annotation.peek('tableList');
    if (constantReader == null) return null;
    //fetch sub router table
    List<RouterTable> tableList = [];
    List<DartObject> annotationList = constantReader.listValue;
    for (DartObject object in annotationList) {
      String tName = object.getField('tName')!.toStringValue()!;
      if (tName.isEmpty) continue;
      String tDescription = object.getField('tDescription')!.toStringValue()!;
      tableList.add(RouterTable(tName: tName, tDescription: tDescription));
    }
    RouteInfoCollector collector = await buildStep.fetchResource(routeResource);
    //fetch all pure route
    Map<String, List<PureRouteInfo>> pureRouteMap = collector.pureRouteMap;
    //fetch all intercept route
    Map<String, List<InterceptorRouteInfo>> interceptorRouteMap = collector.interceptorRouteMap;
    //route args
    return _generateClasses(tableList, pureRouteMap, interceptorRouteMap);
  }

  String? _generateClasses(
    List<RouterTable> tableList,
    Map<String, List<PureRouteInfo>> pureRouteMap,
    Map<String, List<InterceptorRouteInfo>> interceptorRouteMap,
  ) {
    List<String> content = [];
    //generate import
    content.addAll(getImportList(tableList, pureRouteMap, interceptorRouteMap));
    //generate route mixin
    for (RouterTable routeTable in tableList) {
      String tableName = routeTable.tName;
      List<PureRouteInfo> pureRouteList = pureRouteMap[tableName] ?? [];
      List<InterceptorRouteInfo> interceptorRouteList = interceptorRouteMap[tableName] ?? [];
      content.add(_generateClass(routeTable, pureRouteList, interceptorRouteList));
    }
    return content.join('\n');
  }

  String _generateClass(
    RouterTable routeTable,
    List<PureRouteInfo> pureRouteList,
    List<InterceptorRouteInfo> interceptorRouteList,
  ) {
    String extendsRouterName = interceptorRouteList.isEmpty ? 'MixinRouterContainer' : 'MixinRouterInterceptContainer';
    String staticFieldStr = getStaticFieldList(pureRouteList, interceptorRouteList).join('\n');
    String registerInterceptorRouteStr = getInterceptorRouteRegister(interceptorRouteList).join('\n');
    String installPureRouteStr = getPureRouteInstall(pureRouteList).join('\n');
    return '''
    /// ${routeTable.tDescription}
    mixin ${routeTable.tName} on $extendsRouterName {
        $staticFieldStr
        @override
        Map<String, WidgetBuilder> installRouters() {
          $registerInterceptorRouteStr
          $installPureRouteStr
        }
    }
    ''';
  }
}
