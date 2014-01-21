package ng.parser;

import ng.parser.Syntax;

class EvalCalls {}

class EvalCallScope extends Syntax.CallScope /*with CallReflective*/ {
  public var symbol:String;
  public function new(name, arguments) {
    super(name, arguments);
    symbol = name;
  }
      
  public override function eval(scope) {
    return CallReflective.eval(this, scope, scope);
  }
}

class EvalCallMember extends Syntax.CallMember /*with CallReflective*/ {
  public var symbol:String;
  public function new(object, name, arguments) {
    super(object, name, arguments);
    symbol = name;
  }
  public override function eval(scope) {
    return CallReflective.eval(this, scope, object.eval(scope));
  }
}

class EvalCallScopeFast0 extends Syntax.CallScope /*with CallFast*/ {
  public var fn:Dynamic;
  public function new(name, arguments, fn) {
    super(name, arguments);
    this.fn = fn;
  }
  public override function eval(scope) return CallFast.evaluate0(this, scope);
}

class EvalCallScopeFast1 extends Syntax.CallScope /*with CallFast*/ {
  public var fn:Dynamic;
  public function new(name, arguments, fn) {
    super(name, arguments);
    this.fn = fn;
  }
  public override function eval(scope) return CallFast.evaluate1(this, scope, arguments[0].eval(scope));
}

class EvalCallMemberFast0 extends Syntax.CallMember /*with CallFast*/ {
  public var fn:Dynamic;
  public function new(object, name, arguments, fn) {
    super(object, name, arguments);
    this.fn = fn;
  }
      
  public override function eval(scope) return CallFast.evaluate0(this, object.eval(scope));
}

class EvalCallMemberFast1 extends Syntax.CallMember /*with CallFast*/ {
  public var fn:Dynamic;
  public function new(object, name, arguments, fn) {
    super(object, name, arguments);
    this.fn = fn;
  }
      
  public override function eval(scope) return CallFast.evaluate1(this, object.eval(scope), arguments[0].eval(scope));
}

class EvalCallFunction extends Syntax.CallFunction {
  public function new(fn, arguments) super(fn, arguments);
  public override function eval(scope) {
    var fn = this.fn.eval(scope);
    if (Utils.isFunction(fn)) {
      return Utils.relaxFnApply(fn, Utils.evalList(scope, arguments));
    } else {
      throw '$fn is not a function';
    }
    return null;
  }
}

class CallReflective {
  public static function eval(self:Dynamic, scope, holder) {
    var arguments:Array<Dynamic> = Utils.evalList(scope, self.arguments);
    return Reflect.callMethod(scope, Reflect.field(holder, self.name), arguments);
  }
}

class CallFast {
  public static function evaluate0(self:Dynamic, holder) {
    return self.fn(holder);
  }
  public static function evaluate1(self:Dynamic, holder, a0) {
    return self.fn(holder, a0);
  } 
}