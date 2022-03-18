import 'dart:collection';

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
class RouteTableAnnotationGenerator
    extends GeneratorForAnnotation<RouterTableList> {
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
    Map<String, List<InterceptorRouteInfo>> interceptorRouteMap =
        collector.interceptorRouteMap;
    //route args
    return _generateClasses(
      tableList,
      pureRouteMap,
      interceptorRouteMap,
    );
  }

  String? _generateClasses(
    List<RouterTable> tableList,
    Map<String, List<PureRouteInfo>> pureRouteMap,
    Map<String, List<InterceptorRouteInfo>> interceptorRouteMap,
  ) {
    List<String> content = [];

    Set<String> importStatementList = HashSet();
    //import base package
    importStatementList.add("import 'package:flutter/widgets.dart';");
    importStatementList.add(
        "import 'package:flutter_mixin_router/flutter_mixin_router.dart';");
    //import business import package
    for (RouterTable routeTable in tableList) {
      String tableName = routeTable.tName;
      List<PureRouteInfo> pureRouteList = pureRouteMap[tableName] ?? [];
      List<InterceptorRouteInfo> interceptorRouteList =
          interceptorRouteMap[tableName] ?? [];
      importStatementList
          .addAll(_getImportStr(pureRouteList, interceptorRouteList));
    }
    content.addAll(importStatementList);
    //generate route mixin
    for (RouterTable routeTable in tableList) {
      String tableName = routeTable.tName;
      List<PureRouteInfo> pureRouteList = pureRouteMap[tableName] ?? [];
      List<InterceptorRouteInfo> interceptorRouteList =
          interceptorRouteMap[tableName] ?? [];
      content.add(
        _generateClass(
          routeTable,
          pureRouteList,
          interceptorRouteList,
        ),
      );
    }
    return content.join('\n');
  }

  String _generateClass(
    RouterTable routeTable,
    List<PureRouteInfo> pureRouteList,
    List<InterceptorRouteInfo> interceptorRouteList,
  ) {
    String extendsRouterName = interceptorRouteList.isEmpty
        ? 'MixinRouterContainer'
        : 'MixinRouterInterceptContainer';
    String staticFieldStr =
        _getStaticFieldList(pureRouteList, interceptorRouteList);
    String registerInterceptorRouteStr =
        _registerInterceptorRoute(interceptorRouteList);
    String installPureRouteStr = _installPureRoute(pureRouteList);
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

  String _getStaticFieldList(
    List<PureRouteInfo> pureRouteList,
    List<InterceptorRouteInfo> interceptorRouteList,
  ) {
    void fillContent(Set<String> content, String path) {
      String variantName = RouteUtils.path2Variant(path);
      content.add("static const String $variantName = '$path';");
    }

    Set<String> content = HashSet();
    for (PureRouteInfo route in pureRouteList) {
      fillContent(content, route.path);
    }
    for (InterceptorRouteInfo route in interceptorRouteList) {
      fillContent(content, route.path);
    }
    return content.join('\n');
  }

  String _installPureRoute(List<PureRouteInfo> pureRouteList) {
    List<String> content = [];
    content.add(
        'Map<String, WidgetBuilder> superRouterList = super.installRouters();');
    content.add('Map<String, WidgetBuilder> routers = {');
    for (PureRouteInfo route in pureRouteList) {
      String variantName = RouteUtils.path2Variant(route.path);
      content.add('$variantName : (context) => ${route.pageName}(),');
    }
    content.add('};');
    content.add('routers.addAll(superRouterList);');
    content.add('return routers;');

    return content.join('\n');
  }

  String _registerInterceptorRoute(
      List<InterceptorRouteInfo> interceptorRouteList) {
    List<String> content = [];
    for (InterceptorRouteInfo route in interceptorRouteList) {
      String variantName = RouteUtils.path2Variant(route.path);
      content.add(
        'registerRouteInterceptor($variantName, ${route.methodName});',
      );
    }
    return content.join('\n');
  }

  List<String> _getImportStr(
    List<PureRouteInfo> pureRouteList,
    List<InterceptorRouteInfo> interceptorRouteList,
  ) {
    List<String> content = [];
    for (var value in pureRouteList) {
      content.add("import '${value.uri}';");
    }
    for (var value in interceptorRouteList) {
      content.add("import '${value.uri}';");
    }
    return content;
  }
}
