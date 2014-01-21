package ng.parser;

import ng.parser.Syntax;

class EvalAcess {}

private typedef Getter = Dynamic;
private typedef Setter = Dynamic;

class EvalAccessScope extends Syntax.AccessScope /*with AccessReflective*/ {
  public var symbol:String;
  public function new(name:String) {
    super(name);
    symbol = name;
  }
  public override function eval(scope) return AccessReflective.eval(this, scope);
  public override function assign(scope, value) {
    return AccessReflective.assign(this, scope, scope, value);
  }
  public function assignToNonExisting(scope, value) return null;
}

class EvalAccessScopeFast extends Syntax.AccessScope /*with AccessFast*/ {
  public var getter:Getter;
  public var setter:Setter;
  public function new(name:String, getter, setter) {
    this.getter = getter;
    this.setter = setter;
    super(name);
  }
  public override function eval(scope) return AccessFast.eval(this, scope);
  public override function assign(scope, value) return AccessFast.assign(this, scope, scope, value);
}

class EvalAccessMember extends Syntax.AccessMember /*with AccessReflective*/ {
  public var symbol:String;
  public function new(object, name:String) {
    super(object, name);
    symbol = name;
  }
  public override function eval(scope) {
    return AccessReflective.eval(this, object.eval(scope));
  }
  public override function assign(scope, value) {
    return AccessReflective.assign(this, scope, object.eval(scope), value);
  }
  public function assignToNonExisting(scope, value) {
    var obj = {};
    Reflect.setField(obj, name, value);
    return object.assign(scope, obj);
  }
}

class EvalAccessMemberFast extends Syntax.AccessMember /*with AccessFast*/ {
  public var getter:Getter;
  public var setter:Setter;
  public function new(object, name:String, getter, setter) {
    super(object, name);
    this.getter = getter;
    this.setter = setter;
  }
      
  public override function eval(scope) return AccessFast.eval(this, object.eval(scope));
  public override function assign(scope, value) return AccessFast.assign(this, scope, object.eval(scope), value);
  // private function assignToNonExisting(scope, value) return object.assign(scope, { name: value });
}

class EvalAccessKeyed extends Syntax.AccessKeyed {
  public function new(object, key) super(object, key);
  public override function eval(scope) return Utils.getKeyed(object.eval(scope), key.eval(scope));
  public override function assign(scope, value) return Utils.setKeyed(object.eval(scope), key.eval(scope), value);
}


class AccessReflective {
  public static function eval(self:Dynamic, holder) {
    if (Utils.isPrivate(holder, self.name)) {
      throw 'Cannot access private property';
    }
    return Reflect.getProperty(holder, self.name);
  }
  public static function assign(self:Dynamic, scope, holder, value) {
    if (holder != null) {
      Reflect.setProperty(holder, self.name, value);  
    } else {
      self.assignToNonExisting(scope, value);
    }
    return value;
  }
}

class AccessFast {
  public static function eval(self:Dynamic, holder) {
    return null;
  }

  public static function assign(self:Dynamic, scope, holder, value) {
    return null;
  }
}

/**
 * The [AccessReflective] mixin is used to share code between access expressions
 * where we need to use reflection to get or set a field. We optimize for the
 * case where we access the same holder repeatedly through caching.
 */

/*
abstract class AccessReflective {
  static const int CACHED_FIELD = 0;
  static const int CACHED_MAP = 1;
  static const int CACHED_VALUE = 2;

  int _cachedKind = 0;
  var _cachedHolder = UNINITIALIZED;
  var _cachedValue;

  String get name;
  Symbol get symbol;

  _eval(holder) {
    if (!identical(holder, _cachedHolder)) return _evalUncached(holder);
    int cachedKind = _cachedKind;
    if (cachedKind == CACHED_MAP) return holder[name];
    var value = _cachedValue;
    return (cachedKind == CACHED_FIELD)
        ? value.getField(symbol).reflectee
        : value;
  }

  _evalUncached(holder) {
    _cachedHolder = holder;
    if (holder == null) {
      _cachedKind = CACHED_VALUE;
      return _cachedValue = null;
    } else if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      return holder[name];
    }
    InstanceMirror mirror = reflect(holder);
    try {
      var result = mirror.getField(symbol).reflectee;
      _cachedKind = CACHED_FIELD;
      _cachedValue = mirror;
      return result;
    } on NoSuchMethodError catch (e) {
      var result = createInvokeClosure(mirror, symbol);
      if (result == null) rethrow;
      _cachedKind = CACHED_VALUE;
      return _cachedValue = result;
    } on UnsupportedError catch (e) {
      var result = createInvokeClosure(mirror, symbol);
      if (result == null) rethrow;
      _cachedKind = CACHED_VALUE;
      return _cachedValue = result;
    }
  }

  _assign(scope, holder, value) {
    if (holder is Map) {
      holder[name] = value;
    } else if (holder == null) {
      _assignToNonExisting(scope, value);
    } else {
      reflect(holder).setField(symbol, value);
    }
    return value;
  }

  // By default we don't do any assignments to non-existing holders. This
  // is overwritten for access to members.
  _assignToNonExisting(scope, value) => null;

  static Function createInvokeClosure(InstanceMirror mirror, Symbol symbol) {
    if (!hasMember(mirror, symbol)) return null;
    return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
      var arguments = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
      return mirror.invoke(symbol, arguments).reflectee;
    });
  }

  static stripTrailingNulls(List list) {
    while (list.isNotEmpty && (list.last == null)) {
      list.removeLast();
    }
    return list;
  }

  static bool hasMember(InstanceMirror mirror, Symbol symbol) {
    return hasMethodHelper(mirror.type, symbol);
  }

  static final Function hasMethodHelper = (() {
    var objectType = reflect(Object).type;
    try {
      // Use ClassMirror.instanceMembers if available. It contains local
      // as well as inherited members.
      objectType.instanceMembers;
      return (type, symbol) => type.instanceMembers[symbol] is MethodMirror;
    } on NoSuchMethodError catch (e) {
      // For SDK 1.0 we fall back to just using the local members.
      return (type, symbol) => type.members[symbol] is MethodMirror;
    } on UnimplementedError catch (e) {
      // For SDK 1.1 we fall back to just using the local declarations.
      return (type, symbol) => type.declarations[symbol] is MethodMirror;
    }
    return null;
  })();
}

/**
 * The [AccessFast] mixin is used to share code between access expressions
 * where we have a pair of pre-compiled getter and setter functions that we
 * use to do the access the field.
 */

 /*
abstract class AccessFast {
  String get name;
  Getter get getter;
  Setter get setter;

  _eval(holder) {
    if (holder == null) return null;
    return (holder is Map) ? holder[name] : getter(holder);
  }

  _assign(scope, holder, value) {
    if (holder == null) {
      _assignToNonExisting(scope, value);
      return value;
    } else {
      return (holder is Map) ? (holder[name] = value) : setter(holder, value);
    }
  }

  // By default we don't do any assignments to non-existing holders. This
  // is overwritten for access to members.
  _assignToNonExisting(scope, value) => null;
}

*/