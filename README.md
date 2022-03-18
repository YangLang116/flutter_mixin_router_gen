<!-- 
简化 [flutter_mixin_router](https://pub.dev/packages/flutter_mixin_router) 使用，生成大量模式化代码
-->

## 集成

```yaml

# 以下xxx替换成最新版本号

dependencies:
  ...
  #添加
  flutter_mixin_router_ann: xxx
  #添加
  flutter_mixin_router: xxx

dev_dependencies:
  ...
  #添加
  build_runner: 2.1.8
  #添加
  flutter_mixin_router_gen: xxx
```

## 使用

项目结构说明：

```

 --- Home                           : 大厅业务模块
 
  ---- home_page_1.dart             : 大厅页面1
  
  ---- home_page_2.dart             : 大厅页面2
  
 --- Mine                           : 个人业务模块     
 
  ---- mine_page.dart               : 个人页面1
 
 main.dart                          : 启动文件(entry-point)
 
 app_router_center.dart             : 使用mixin_router创建的文件，用于聚合所有模块(大厅业务模块 和 个人业务模块)，即：路由总表
```

跟 [flutter_mixin_router](https://pub.dev/packages/flutter_mixin_router)
说明中的项目结构对比，每个模块不再需要定义子路由表文件，改由`flutter_mixin_router_gen`生成。

使用`flutter_mixin_router_gen`需要关注三点：总路由表 `app_router_center.dart` 文件编写、页面路由注册、拦截路由注册。

app_router_center.dart:

```dart

//定义大厅子路由表名称
const String HOME_ROUTER_TABLE = 'HomeRouterTable';
//定义个人子路由表名称
const String MINE_ROUTER_TABLE = 'MineRouterTable';

//向总路由表注册各子路由表
//tDescription: 仅仅作为生成类的注释
@RouterTableList(
  tableList: [
    RouterTable(tName: HOME_ROUTER_TABLE, tDescription: '大厅路由模块'),
    RouterTable(tName: MINE_ROUTER_TABLE, tDescription: '个人路由模块'),
  ],
)
//with HomeRouterTable, MineRouterTable，即上面声明的两个路由表的名字
class AppRouterCenter extends UriRouterInterceptContainer
    with HomeRouterTable, MineRouterTable {
  AppRouterCenter._();

  static final AppRouterCenter _instance = AppRouterCenter._();

  static AppRouterCenter get share => _instance;
}
```

页面注册：

```dart
//定义路由页面，tName 代表该路由属于哪个路由子表
@MixinRoute(tName: HOME_ROUTER_TABLE, path: '/home_page_1')
class Home1Page extends StatelessWidget {
  ...
}
```

拦截路由注册：

```dart
@MixinRoute(tName: MINE_ROUTER_TABLE, path: '/mine_page')
class MinePage extends StatelessWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ...
  }
}

//定义路由拦截，该注解使用在方法上，方法有以下两个约束：
//1、作为顶级元素声明在文件中
//2、方法的参数和返回值固定
@MixinInterceptRoute(tName: MINE_ROUTER_TABLE, path: '/mine_page')
bool interceptorMinePage(context, pageName, pushType, {arguments, predicate}) {
  if (isLogin) {
    return false;
  }
  print('toLogin');
  return true;
}
```

## 生成文件
  ```shell
    # 清除增量编译缓存
    flutter packages pub run build_runner clean
  
    # 重新生成代码
    flutter packages pub run build_runner build --delete-conflicting-outputs
  ```

生成的文件与被`RouterTableList`注解的`文件X`同级。

## 页面跳转和参数处理：

[flutter_mixin_router](https://pub.dev/packages/flutter_mixin_router)