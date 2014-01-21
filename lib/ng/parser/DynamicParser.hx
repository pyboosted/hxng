package ng.parser;

import ng.parser.Parser;
import ng.parser.Syntax;
import ng.parser.Eval;
import ng.parser.EvalAccess;
import ng.parser.EvalCalls;
import ng.parser.Lexer;

typedef Getter = String->Dynamic;
typedef Setter = String->Dynamic;

class ClosureMap {
  public function lookupGetter(name:String) return null;
  public function lookupSetter(name:String) return null;
  public function lookupFunction(name:String, arity:Int) return null;
}

class DynamicParser implements Parser<Expression> {
  private var lexer:Lexer;
  private var backend:ParserBackend<Expression>;


  public function new(lexer:Lexer, backend:ParserBackend<Expression>) {
    this.lexer = lexer;
    this.backend = backend;
  }

  public function call(input:String):Expression {
    if (input == null) input = '';
    return parse(input);
  }

  public static function parse(input:String) {
    var lexer = new Lexer();
    var backend = new DynamicParserBackend(null, null);
    var dynamicParser = new DynamicParser(lexer, backend);
    return dynamicParser._parse(input);
  }

  public function _parse(input:String):Expression {
    var parser:DynamicParserImpl = new DynamicParserImpl(lexer, backend,input);
    var expression:Expression = parser.parseChain();
    return new DynamicExpression(expression);
  }
}

class DynamicExpression extends Expression {
  
  private var expression:Expression;

  public function new(expression:Expression) {
    this.expression = expression;
  }

  public override function isAssignable() return expression.isAssignable();
  public override function isChain() return expression.isChain();

  public override function accept(visitor:Visitor) expression.accept(visitor);
  public override function toString():String return expression.toString();

  public override function eval(scope):Dynamic {
    try {
      return expression.eval(scope);
    } catch(e:Dynamic) {
      throw e;
    }
  }

  public override function assign(scope, value) {
    try {
      return expression.assign(scope, value);
    } catch(e:Dynamic) {
      throw e;
    }
  }
}

typedef FilterMap = Dynamic;

class DynamicParserBackend extends ParserBackend<Expression> {
  private var filters: FilterMap;
  private var closures: ClosureMap;
  
  public function new(filters, closures){
    this.filters = filters;
    this.closures = closures;
  }

  public override function isAssignable(expression:Expression):Bool {
    return expression.isAssignable();
  }

  public override function newFilter(expression:Expression, name:String, arguments:Array<Expression>):Expression {
    var filter = filters.get(name);
    var allArguments = new Array<Expression>();
    allArguments.push(expression);
    for (arg in arguments) allArguments.push(arg);
    return new EvalFilter(expression, name, arguments, filter, allArguments);
  }

  public override function newChain(expressions):Expression 
      return new EvalChain(expressions);
  public override function newAssign(target, value):Expression 
      return new EvalAssign(target, value);
  public override function newConditional(condition, yes, no):Expression 
      return new EvalConditional(condition, yes, no);

  public override function newAccessKeyed(object, key):Expression 
      return new EvalAccessKeyed(object, key);

  public override function newCallFunction(fn, arguments):Expression 
      return new EvalCallFunction(fn, arguments);

  public override function newPrefixNot(expression):Expression 
      return new EvalPrefixNot(expression);

  public override function newBinary(operation, left, right):Expression 
      return new EvalBinary(operation, left, right);

  public override function newLiteralPrimitive(value):Expression 
      return new EvalLiteralPrimitive(value);
  public override function newLiteralArray(elements):Expression 
      return new EvalLiteralArray(elements);
  public override function newLiteralObject(keys, values):Expression 
      return new EvalLiteralObject(keys, values);
  public override function newLiteralString(value):Expression 
      return new EvalLiteralString(value);


  public override function newAccessScope(name):Expression {
    // var getter:Getter = closures.lookupGetter(name);
    // var setter:Setter = closures.lookupSetter(name);
    // if (getter != null && setter != null) {
    //   return new EvalAccessScopeFast(name, getter, setter);
    // } else {
    return new EvalAccessScope(name);
    // }
  }

  public override function newAccessMember(object, name):Expression {
    // var getter:Getter = closures.lookupGetter(name);
    // var setter:Setter = closures.lookupSetter(name);
    // if (getter != null && setter != null) {
    //   return new EvalAccessMemberFast(object, name, getter, setter);
    // } else {
    return new EvalAccessMember(object, name);
    // }
  }

  public override function newCallScope(name, arguments:Array<Expression>):Expression {
    // var constructor = computeCallConstructor(callScopeConstructors, name, arguments.length);
    // return (constructor != null)
    //     ? constructor(name, arguments, closures)
    //     : new EvalCallScope(name, arguments);
    return new EvalCallScope(name, arguments);
  }

  public override function newCallMember(object, name, arguments:Array<Expression>):Expression {
    // var constructor = computeCallConstructor(callMemberConstructors, name, arguments.length);
    // return (constructor != null)
    //     ? constructor(object, name, arguments, closures)
    //     : new EvalCallMember(object, name, arguments);
    return new EvalCallMember(object, name, arguments);
  }

  public function computeCallConstructor(constructors:Map<Int, Dynamic>, name:String, arity:Int):Dynamic {
    var fn = closures.lookupFunction(name, arity);
    return (fn == null) ? null : constructors.get(arity);
  }

  public static var callScopeConstructors:Map<Int, Dynamic> = [
      0 => function (n, a, c) return new EvalCallScopeFast0(n, a, c.lookupFunction(n, 0)),
      1 => function (n, a, c) return new EvalCallScopeFast1(n, a, c.lookupFunction(n, 1))
  ];

  public static var callMemberConstructors:Map<Int, Dynamic> = [
      0 => function (o, n, a, c) return new EvalCallMemberFast0(o, n, a, c.lookupFunction(n, 0)),
      1 => function (o, n, a, c) return new EvalCallMemberFast1(o, n, a, c.lookupFunction(n, 1))
  ];
}
