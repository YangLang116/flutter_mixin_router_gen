import 'dart:collection';

import 'package:flutter_mixin_router_ann/flutter_mixin_router_ann.dart';
import 'package:flutter_mixin_router_gen/resource/route_info_resource.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com

String path2Variant(String path) {
  String variantName = path.toUpperCase();
  if (variantName.startsWith('/')) variantName = variantName.substring(1);
  return variantName;
}

Set<String> getImportList(
  List<RouterTable> tableList,
  Map<String, List<PureRouteInfo>> pureRouteMap,
  Map<String, List<InterceptorRouteInfo>> interceptorRouteMap,
) {
  Set<String> importStatementList = HashSet();
  //import base package
  importStatementList.add("import 'package:flutter/widgets.dart';");
  importStatementList.add("import 'package:flutter_mixin_router/flutter_mixin_router.dart';");
  //import business import package
  for (RouterTable routeTable in tableList) {
    String tableName = routeTable.tName;
    List<PureRouteInfo> pureRouteList = pureRouteMap[tableName] ?? [];
    List<InterceptorRouteInfo> interceptorRouteList = interceptorRouteMap[tableName] ?? [];
    for (PureRouteInfo routeInfo in pureRouteList) {
      importStatementList.add("import '${routeInfo.uri}';");
    }
    for (InterceptorRouteInfo routeInfo in interceptorRouteList) {
      importStatementList.add("import '${routeInfo.uri}';");
    }
  }
  return importStatementList;
}

Set<String> getStaticFieldList(
  List<PureRouteInfo> pureRouteList,
  List<InterceptorRouteInfo> interceptorRouteList,
) {
  String buildLine(String path) {
    String variantName = path2Variant(path);
    return "static const String $variantName = '$path';";
  }

  Set<String> content = HashSet();
  for (PureRouteInfo route in pureRouteList) {
    content.add(buildLine(route.path));
  }
  for (InterceptorRouteInfo route in interceptorRouteList) {
    content.add(buildLine(route.path));
  }
  return content;
}

Set<String> getInterceptorRouteRegister(List<InterceptorRouteInfo> interceptorRouteList) {
  Set<String> content = HashSet();
  for (InterceptorRouteInfo route in interceptorRouteList) {
    String variantName = path2Variant(route.path);
    content.add('registerRouteInterceptor($variantName, ${route.methodName});');
  }
  return content;
}

List<String> getPureRouteInstall(List<PureRouteInfo> pureRouteList) {
  List<String> content = [];
  content.add('Map<String, WidgetBuilder> superRouterList = super.installRouters();');
  content.add('Map<String, WidgetBuilder> routers = {');
  Set<String> routeList = HashSet();
  for (PureRouteInfo route in pureRouteList) {
    String variantName = path2Variant(route.path);
    String arg = route.arg ? 'ModalRoute.of(context)!.settings.arguments' : '';
    routeList.add('$variantName : (context) => ${route.pageName}($arg),');
  }
  content.addAll(routeList);
  content.add('};');
  content.add('routers.addAll(superRouterList);');
  content.add('return routers;');
  return content;
}
