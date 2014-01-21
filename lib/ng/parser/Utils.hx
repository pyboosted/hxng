package ng.parser;

class Utils {
  public static function getKeyed(object:Dynamic, key:Dynamic) {
    if (Std.is(object,Array)) {
      return object[key];
    } else if(Std.is(object, Dynamic)) {
      return Reflect.getProperty(object, key);
    // } else if (isMap(object)) {
    //   return object.get(key); // toString dangerous?
    // } else if (object == null) {
    //   throw 'Accessing null object';
    }
    throw "Attempted field access on a non-list, non-map";
  }

  /// Set a keyed element in the given [object].
  public static function setKeyed(object:Dynamic, key:Dynamic, value:Dynamic) {
    if (Std.is(object, Array)) {
      var index:Int = key;
      if (object.length <= index) object.length = index + 1;
      object[index] = value;
    } else if(Std.is(object, Dynamic)) {
      Reflect.setProperty(object, key, value);
    // } else if (isMap(object)) {
    //   trace('Set value');
    //   object.set(key, value); // toString dangerous?
    } else {
      throw "Attempting to set a field on a non-list, non-map";
    }
    return value;
  }

  public static inline function toBool(a:Dynamic):Bool {
    if (Std.is(a, Bool)) return a;
    return (a != null && a != 0 && a != '');
  }

  public static function relaxFnApply(fn:Dynamic, args:Array<Dynamic>) {
    var argsLen = args.length;
    if(!isFunction(fn)) {
      return throw 'Not a funciton';
    }
    return switch (argsLen) {
      case 5: fn(args[0], args[1], args[2], args[3], args[4]);
      case 4: fn(args[0], args[1], args[2], args[3]);
      case 3: fn(args[0], args[1], args[2]);
      case 2: fn(args[0], args[1]);
      case 1: fn(args[0]);
      case 0: fn();
      default: throw 'Uknown function type, expecting 0 to 5 arguments';
    }
  }

  public static var evalListCache: Array<Dynamic> = new Array<Dynamic>();
  public static function evalList(scope, list:Array<Syntax.Expression>):Array<Dynamic> {
    var length = list.length;
    for(cacheLength in evalListCache.length...length+1) {
      evalListCache.push(new Array<Dynamic>());
    }
    var result = evalListCache[length];
    for (i in 0...length) {
      result[i] = list[i].eval(scope);
    }
    return result;
  }

  public static function isFunction(f) {
    var type = untyped __js__('typeof f');
    return (type == 'function');
  }

  public static function isMap(m) {
    return m.set != null && m.get != null;
  }

  public static function isPrivate(instance, fieldName) {
    #if rtti_support
    if (instance != null && fieldName != null) {
      var cl = untyped Type.getClass(instance);
      if (cl == null) return false;
      var rtti = cl.__rtti;
      if (rtti != null) {
        var x = Xml.parse(rtti).firstElement();
        var infos = new haxe.rtti.XmlParser().processElement(x);
        switch(infos) {
          case TClassdecl(cl):
            for (f in cl.fields)
            {
              if (f.name == fieldName) return (f.isPublic != true);
            }
          default:
        }
      }
      return false;
    }
    #end
    return false;
  }
}