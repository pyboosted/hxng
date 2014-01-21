package hxng.lib;


class Controller {
  var scope(get,null):Dynamic;
  inline function get_scope() return this;
  inline function watch(key: String, fn: Void->Void, ?equals: Bool):Void {
    Reflect.callMethod(scope, Reflect.field(scope, '$watch'), [key, fn, equals]);
  }
}