///@author: YangLang
///@version: v1.0
///@email: yanglang116@gmail.com
class RouteUtils {
  static String path2Variant(String path) {
    String variantName = path.toUpperCase();
    if (variantName.startsWith('/')) variantName = variantName.substring(1);
    return variantName;
  }
}
