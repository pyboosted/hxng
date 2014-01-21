
package ng.parser;

class Eval {}

class EvalChain extends Syntax.Chain {
  public function new(expressions:Array<Syntax.Expression>) {
    super(expressions);
  }

  public override function eval(scope) {
    var result = null;
    var length = expressions.length;
    for (i in 0...length) {
      var last = expressions[i].eval(scope);
      if (last != null) result = last;
    }
    return result;
  }

}

class EvalFilter extends Syntax.Filter {
  var fn:Dynamic;
  var allArguments:Array<Syntax.Expression>;
  public function new(expression:Syntax.Expression, name:String, arguments:Array<Syntax.Expression>, fn:Dynamic, allArguments:Array<Syntax.Expression>) {
    super(expression, name , arguments);
    this.allArguments = allArguments;
    this.fn = fn;
  }

  public override function eval(scope) {
    var fn = this.fn;
    var allArguments = allArguments;
    return Reflect.callMethod(scope, fn, allArguments);
    // return untyped __js__('fn.apply(scope, allArguments)');
  }
}

class EvalAssign extends Syntax.Assign {
  public function new(target:Syntax.Expression, value) super(target, value);
  public override function eval(scope) {
    return target.assign(scope, value.eval(scope));
  }
}

class EvalConditional extends Syntax.Conditional {
  public function new(condition:Syntax.Expression, yes:Syntax.Expression, no:Syntax.Expression) super(condition, yes, no);
  public override function eval(scope) {
    return (condition.eval(scope) != null && condition.eval(scope) != false)
      ? yes.eval(scope)
      : no.eval(scope);
  }
}

class EvalPrefixNot extends Syntax.Prefix {
  public function new(expression:Syntax.Expression) super('!', expression);
  public override function eval(scope) {
    return (
      expression.eval(scope) == null || 
      expression.eval(scope) == false ||
      expression.eval(scope) == '' ||
      expression.eval(scope) == 0
    );
  }
}

class EvalBinary extends Syntax.Binary {
  public function new(operation:String, left:Syntax.Expression, right:Syntax.Expression) super(operation, left, right);
  public override function eval(scope):Dynamic {
    var left:Dynamic = this.left.eval(scope);

    inline function autoConvertAdd(a:Dynamic, b:Dynamic) {
      if (a != null && b != null) {
        // TODO(deboer): Support others.
        if (Std.is(a,String) && !Std.is(b,String)) {
          return a + b.toString();
        }
        if (!Std.is(a,String) && Std.is(b,String)) {
          return a.toString() + b;
        }
        return a + b;
      }
      if (a != null) return a;
      if (b != null) return b;
      return null;
    }

    switch (operation) {
      case '&&': return Utils.toBool(left) && Utils.toBool(this.right.eval(scope));
      case '||': return Utils.toBool(left) || Utils.toBool(this.right.eval(scope));
    }

    var right:Dynamic = this.right.eval(scope);
    switch (operation) {
      case '+'  : return autoConvertAdd(left, right);
      case '-'  : return left - right;
      case '*'  : return left * right;
      case '/'  : return left / right;
      // NOTE(pythonic): Not avaiable in Haxe
      // case '~/' : return left ~/ right;
      case '%'  : return left % right;
      case '==' : return left == right;
      case '!=' : return left != right;
      case '<'  : return left < right;
      case '>'  : return left > right;
      case '<=' : return left <= right;
      case '>=' : return left >= right;
      case '^'  : return left ^ right;
      case '&'  : return left & right;
    }
    throw 'Internal error [$operation] not handled';
  }
}

class EvalLiteralPrimitive extends Syntax.LiteralPrimitive {
  public function new(value:Dynamic) super(value);
  public override function eval(scope) return value;
}

class EvalLiteralString extends Syntax.LiteralString {
  public function new(value:String) super(value);
  public override function eval(scope) return value;
}

class EvalLiteralArray extends Syntax.LiteralArray {
  public function new(elements:Array<Syntax.Expression>) super(elements);
  public override function eval(scope) {
    var res = [];
    for (el in elements) {
      res.push(el.eval(scope));
    }
    return res;
  } 
}

class EvalLiteralObject extends Syntax.LiteralObject {
  public function new(keys:Array<String>, values:Array<Syntax.Expression>) super(keys, values);
  public override function eval(scope) {
    var map:Dynamic = {};
    for (i in 0...keys.length) {
      Reflect.setProperty(map, keys[i], values[i].eval(scope));
    }
    return map;
  } 
}