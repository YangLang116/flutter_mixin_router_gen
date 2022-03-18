import 'package:build/build.dart';
import 'package:flutter_mixin_router_gen/generator/route_annotation.dart';
import 'package:flutter_mixin_router_gen/generator/route_interceptor_annotation.dart';
import 'package:flutter_mixin_router_gen/generator/route_table_annotation.dart';
import 'package:source_gen/source_gen.dart';

///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
Builder generateRouteBuilder(BuilderOptions options) => LibraryBuilder(
      RouteAnnotationGenerator(),
      generatedExtension: '.route.dart',
    );

Builder generateInterceptorRouteBuilder(BuilderOptions options) =>
    LibraryBuilder(
      RouteInterceptorAnnotationGenerator(),
      generatedExtension: '.interceptor.dart',
    );

Builder generateTableListBuilder(BuilderOptions options) => LibraryBuilder(
      RouteTableAnnotationGenerator(),
      generatedExtension: '.table.dart',
    );
