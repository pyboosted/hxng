package ng.parser;

import ng.parser.Lexer;

interface Parser<T> {
  public function call(input:String):T;
}


class ParserBackend<T> {

  public function isAssignable(expression:T):Bool
    return false;

  public function newChain(expressions:Array<T>):T
    return null;
  public function newFilter(expression:T, name:String, arguments:Array<T>):T
    return null;

  public function newAssign(target:T, value:T):T
    return null;
  public function newConditional(condition:T, yes:T, no:T):T
    return null;

  public function newAccessScope(name:String):T
    return null;
  public function newAccessMember(object:T, name:String):T
    return null;
  public function newAccessKeyed(object:T, key:T):T
    return null;

  public function newCallScope(name:String, arguments:Array<T>):T
    return null;
  public function newCallFunction(fn:T, arguments:Array<T>):T
    return null;
  public function newCallMember(object:T, name:String, arguments:Array<T>):T
    return null;

  public function newPrefix(operation:String, expression:T):T
    return null;
  public function newPrefixPlus(expression:T):T
    return expression;
  public function newPrefixMinus(expression:T):T
    return newBinaryMinus(newLiteralZero(), expression);
  public function newPrefixNot(expression:T):T
    return newPrefix('!', expression);

  public function newBinary(operation:String, left:T, right:T):T
    return null;
  public function newBinaryPlus(left:T, right:T):T
    return newBinary('+', left, right);
  public function newBinaryMinus(left:T, right:T):T
    return newBinary('-', left, right);
  public function newBinaryMultiply(left:T, right:T):T
    return newBinary('*', left, right);
  public function newBinaryDivide(left:T, right:T):T
    return newBinary('/', left, right);
  public function newBinaryModulo(left:T, right:T):T
    return newBinary('%', left, right);
  public function newBinaryTruncatingDivide(left:T, right:T):T
    return newBinary('~/', left, right);
  public function newBinaryLogicalAnd(left:T, right:T):T
    return newBinary('&&', left, right);
  public function newBinaryLogicalOr(left:T, right:T):T
    return newBinary('||', left, right);
  public function newBinaryEqual(left:T, right:T):T
    return newBinary('==', left, right);
  public function newBinaryNotEqual(left:T, right:T):T
    return newBinary('!=', left, right);
  public function newBinaryLessThan(left:T, right:T):T
    return newBinary('<', left, right);
  public function newBinaryGreaterThan(left:T, right:T):T
    return newBinary('>', left, right);
  public function newBinaryLessThanEqual(left:T, right:T):T
    return newBinary('<=', left, right);
  public function newBinaryGreaterThanEqual(left:T, right:T):T
    return newBinary('>=', left, right);

  public function newLiteralPrimitive(value:Dynamic):T 
    return null;
  public function newLiteralArray(elements:Array<T>):T 
    return null;
  public function newLiteralObject(keys:Array<String>, values:Array<T>):T 
    return null;
  public function newLiteralNull():T 
    return newLiteralPrimitive(null);
  public function newLiteralZero():T 
    return newLiteralNumber(0);
  public function newLiteralBoolean(value:Bool):T 
    return newLiteralPrimitive(value);
  public function newLiteralNumber(value:Float):T 
    return newLiteralPrimitive(value);
  public function newLiteralString(value:String):T 
    return null;
}

/*
class Expression {

  public var isAssignable:Bool = false;
  public var isChain:Bool = false;

  public var assign: Dynamic->Dynamic->Dynamic;
  public var eval: Dynamic->Dynamic;
  public function toString() {
    return expression;
  }
}

class DynamicExpression extends Expression {
  
  private var expression:Expression;

  public override function isAssignable() return expression.isAssignable;
  public override function isChain() return expression.isChain;

  public override function accept(visitor:Visitor) expression.accept(visitor);
  public override function toString():String return expression.toString();

  public override function eval(scope) {
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

class Parser {

  public var lexer: Lexer;
  public var backend: ParserBackend<Expression>;
  public var tokens:Array<Token>;

  public static function parse(text:String):Expression {
    var lexer = new Lexer();
    var filters = new Map<String, Filter>();
    var closures = new Map<String, Dynamic>();

    var backend = new ParserBackend<Expression>(filters, closures);

    var parser = new Parser(lexer, backend);
    return parser._parse(text);
  }

  public function new(lexer:Lexer, backend:ParserBackend<Expression>) {
    this.lexer = lexer;
    this.backend = backend;
  }


  public static var EOF = new Token(-1, null);
  var index:Int = 0;
  public var peek(get, never):Token;
  private function get_peek() {
    return (index < tokens.length) ? tokens[index] : EOF;
  }

  public function _parse(text:String):Expression {
    tokens = lexer.call(text);
    return new DynamicExpression(parseChain());
  }

  public function parseChain() {
    while (optional(';')) {};
    List<Expression> exressions = new List<Expression>();
    while (index < tokens.length) {
      if (peek.text == ')' || peek.text == '}' || peek.text == ']') {
        error('Unconsumed token ${peek.text}');
      }
      expressions.push(parseFilter());
      while (optional(';')) {};
    }
    return (expressions.length == 1) ? expressions.first() : backend.newChain(expressions);
  }
      
  public function parseFilter() {
    var result = parseExpression();
    while (optional('|')) {
      var name = peek.text;
      advance();
      var arguments = [];
      while (optional(':')) {
        arguments.add(parseExpression());
      }
      result = backend.newFilter(result, name, arguments);
    }
    return result;
  }

  public function parseExpression() {
    var start = peek.index;
    var result = parseConditional();
    while (peek.text == '=') {
      if (!backend.isAssignable(result)) {
        var end = (index < tokens.length) ? peek.index : input.length;
        var expression = input.substring(start, end);
        error('Expression $expression is not assignable');
      }
      expect('=');
      result = backend.newAssign(result, parseConditional());
    }
    return result;
  }

  public function parseConditional() {
    var start = peek.index;
    var result = parseLogicalOr();
    if (optional('?')) {
      var yes = parseExpression();
      if (!optional(':')) {
        var end = (index < tokens.length) ? peek.index : input.length;
        var expression = input.substring(start, end);
        error('Conditional expression $expression requires all 3 expressions');
      }
      var no = parseExpression();
      result = backend.newConditional(result, yes, no);
    }
    return result;
  }

  public function parseLogicalOr() {
    // '||'
    var result = parseLogicalAnd();
    while (optional('||')) {
      result = backend.newBinaryLogicalOr(result, parseLogicalAnd());
    }
    return result;
  }

  public function parseLogicalAnd() {
    // '&&'
    var result = parseEquality();
    while (optional('&&')) {
      result = backend.newBinaryLogicalAnd(result, parseEquality());
    }
    return result;
  }

  public function parseEquality() {
    // '==','!='
    var result = parseRelational();
    while (true) {
      if (optional('==')) {
        result = backend.newBinaryEqual(result, parseRelational());
      } else if (optional('!=')) {
        result = backend.newBinaryNotEqual(result, parseRelational());
      } else {
        return result;
      }
    }
  }

  public function parseRelational() {
    // '<', '>', '<=', '>='
    var result = parseAdditive();
    while (true) {
      if (optional('<')) {
        result = backend.newBinaryLessThan(result, parseAdditive());
      } else if (optional('>')) {
        result = backend.newBinaryGreaterThan(result, parseAdditive());
      } else if (optional('<=')) {
        result = backend.newBinaryLessThanEqual(result, parseAdditive());
      } else if (optional('>=')) {
        result = backend.newBinaryGreaterThanEqual(result, parseAdditive());
      } else {
        return result;
      }
    }
  }

  public function parseAdditive() {
    // '+', '-'
    var result = parseMultiplicative();
    while (true) {
      if (optional('+')) {
        result = backend.newBinaryPlus(result, parseMultiplicative());
      } else if (optional('-')) {
        result = backend.newBinaryMinus(result, parseMultiplicative());
      } else {
        return result;
      }
    }
  }

  public function parseMultiplicative() {
    // '*', '%', '/', '~/'
    var result = parsePrefix();
    while (true) {
      if (optional('*')) {
        result = backend.newBinaryMultiply(result, parsePrefix());
      } else if (optional('%')) {
        result = backend.newBinaryModulo(result, parsePrefix());
      } else if (optional('/')) {
        result = backend.newBinaryDivide(result, parsePrefix());
      } else if (optional('~/')) {
        result = backend.newBinaryTruncatingDivide(result, parsePrefix());
      } else {
        return result;
      }
    }
  }

  public function parsePrefix() {
    if (optional('+')) {
      // TODO(kasperl): This is different than the original parser.
      return backend.newPrefixPlus(parsePrefix());
    } else if (optional('-')) {
      return backend.newPrefixMinus(parsePrefix());
    } else if (optional('!')) {
      return backend.newPrefixNot(parsePrefix());
    } else {
      return parseMemberOrCall();
    }
  }

  public function parseMemberOrCall() {
    var result = parsePrimary();
    while (true) {
      if (optional('.')) {
        var name = peek.text;  // TODO(kasperl): Check that this is an identifier
        advance();
        if (optional('(')) {
          var arguments = parseExpressionList(')');
          expect(')');
          result = backend.newCallMember(result, name, arguments);
        } else {
          result = backend.newAccessMember(result, name);
        }
      } else if (optional('[')) {
        var key = parseExpression();
        expect(']');
        result = backend.newAccessKeyed(result, key);
      } else if (optional('(')) {
        var arguments = parseExpressionList(')');
        expect(')');
        result = backend.newCallFunction(result, arguments);
      } else {
        return result;
      }
    }
  }

  public function parsePrimary() {
    if (optional('(')) {
      var result = parseFilter();
      expect(')');
      return result;
    } else if (optional('null') || optional('undefined')) {
      return backend.newLiteralNull();
    } else if (optional('true')) {
      return backend.newLiteralBoolean(true);
    } else if (optional('false')) {
      return backend.newLiteralBoolean(false);
    } else if (optional('[')) {
      var elements = parseExpressionList(']');
      expect(']');
      return backend.newLiteralArray(elements);
    } else if (peek.text == '{') {
      return parseObject();
    } else if (peek.key != null) {
      return parseQualified();
    } else if (peek.value != null) {
      var value = peek.value;
      advance();
      return (Std.is(value, Float)
          ? backend.newLiteralNumber(value)
          : backend.newLiteralString(value);
    } else if (index >= tokens.length) {
      throw 'Unexpected end of expression: $input';
    } else {
      error('Unexpected token ${peek.text}');
    }
  }

  public function parseQualified() {
    var components = peek.key.split('.');
    advance();
    var arguments;
    if (optional('(')) {
      arguments = parseExpressionList(')');
      expect(')');
    }
    var result = (arguments != null) && (components.length == 1)
        ? backend.newCallScope(components.first, arguments)
        : backend.newAccessScope(components.first);
    for (i in 0...components.length) {
      result = (arguments != null) && (components.length == i + 1)
          ? backend.newCallMember(result, components[i], arguments)
          : backend.newAccessMember(result, components[i]);
    }
    return result;
  }

  public function parseObject() {
    var keys = [];
    var values = [];
    expect('{');
    if (peek.text != '}') {
      do {
        // TODO(kasperl): Stricter checking. Only allow identifiers
        // and strings as keys. Maybe also keywords?
        var value = peek.value;
        keys.add(Std.is(value, String) ? value : peek.text);
        advance();
        expect(':');
        values.add(parseExpression());
      } while (optional(','));
    }
    expect('}');
    return backend.newLiteralObject(keys, values);
  }

  public function parseExpressionList(terminator:String) {
    var result = [];
    if (peek.text != terminator) {
      do {
        result.add(parseExpression());
       } while (optional(','));
    }
    return result;
  }

  public function optional(text) {
    if (peek.text == text) {
      advance();
      return true;
    } else {
      return false;
    }
  }

  public function expect(text) {
    if (peek.text == text) {
      advance();
    } else {
      error('Missing expected $text');
    }
  }

  public function advance() {
    index++;
  }

  public function error(message) {
    var location = (index < tokens.length)
        ? 'at column ${tokens[index].index + 1} in'
        : 'the end of the expression';
    throw 'Parser Error: $message $location [$input]';
  }

}

class ParserBackend<T> {

  var filters: Map<String, Filter>;
  var closures: Map<String, Dynamic>;

  public function new(filters, closures) {
    this.filters = filters;
    this.closures = closures;
  }

  public function isAssignable(expression:T):Bool
    return false;

  public function newChain(expressions:Array<T>):T
    return new Chain(expressions);
  public function newFilter(expression:T, name:String, arguments:Array<T>):T {
    var filter:Dynamic->Dynamic = filters(name);
    var allArguments:List<T> = new List<T>();
    allArguments.add(expression);
    for (arg in arguments) allArguments.add(arg);
    return new Filter(expression, name, arguments, filter, allArguments);
  }

  public function newAssign(target:T, value:T):T
    return new Assign(target, value);
  public function newConditional(condition:T, yes:T, no:T):T
    return new Conditional(condition, yes, no);

  public function newAccessScope(name:String):T {
    var getter:Getter = closures.lookupGetter(name);
    var setter:Setter = closures.lookupSetter(name);
    if (getter != null && setter != null) {
      return new AccessScopeFast(name, getter, setter);
    } else {
      return new AccessScope(name);
    }
  }
  public function newAccessMember(object:T, name:String):T {
    var getter:Getter = closures.lookupGetter(name);
    var setter:Setter = closures.lookupSetter(name);
    if (getter != null && setter != null) {
      return new AccessMemberFast(object, name, getter, setter);
    } else {
      return new AccessMember(object, name);
    }
  }
  public function newAccessKeyed(object:T, key:T):T
    return new AccessedKeyed(object, key);

  public function newCallScope(name:String, arguments:Array<T>):T {
    var constuctor = computeAllConstructor(callScopeConstructors, name, arguments.length);
    return (constuctor != null)
      ? constuctor(name, arguments, closures)
      : new CallScope(name, arguments);
  }

  public function newCallFunction(fn:T, arguments:Array<T>):T
    return new CallFunction(fn, arguments);

  public function newCallMember(object:T, name:String, arguments:Array<T>):T {
    var constuctor = computeAllConstructor(callScopeConstructors, name, arguments.length);
    return (constuctor != null)
      ? constuctor(object, name, arguments, closures)
      : new CallMember(object, name, arguments);
  }

  private function computeCallConstructor(constuctors:Map<Int, Dynamic>, name: String, arity:Int) {
    var fn = closures.lookupFunction(name, arity);
    return (fn == null) ? null : constructors[arity];
  }

  private var callScopeConstructors:Map<Int, Dynamic> = [
    0 => function (n, a, c) return new CallScopeFast0(n, a, c.lookupFunction(n, 0)),
    1 => function (n, a, c) return new CallScopeFast1(n, a, c.lookupFunction(n, 1))
  ];

  private var callMember:Map<Int, Dynamic> = [
    0 => function (o, n, a, c) return new CallMemberFast0(o, n, a, c.lookupFunction(n, 0)),
    1 => function (o, n, a, c) return new CallMemberFast1(o, n, a, c.lookupFunction(n, 1))
  ];  

  public function newPrefix(operation:String, expression:T):T
    return null;
  public function newPrefixPlus(expression:T):T
    return expression;
  public function newPrefixMinus(expression:T):T
    return newBinaryMinus(newLiteralZero(), expression);
  public function newPrefixNot(expression:T):T
    return new PrefixNot(expression);

  public function newBinary(operation:String, left:T, right:T):T
    return new Binary(operation, left, right);
  public function newBinaryPlus(left:T, right:T):T
    return newBinary('+', left, right);
  public function newBinaryMinus(left:T, right:T):T
    return newBinary('-', left, right);
  public function newBinaryMultiply(left:T, right:T):T
    return newBinary('*', left, right);
  public function newBinaryDivide(left:T, right:T):T
    return newBinary('/', left, right);
  public function newBinaryModulo(left:T, right:T):T
    return newBinary('%', left, right);
  public function newBinaryTruncatingDivide(left:T, right:T):T
    return newBinary('~/', left, right);
  public function newBinaryLogicalAnd(left:T, right:T):T
    return newBinary('&&', left, right);
  public function newBinaryLogicalOr(left:T, right:T):T
    return newBinary('||', left, right);
  public function newBinaryEqual(left:T, right:T):T
    return newBinary('==', left, right);
  public function newBinaryNotEqual(left:T, right:T):T
    return newBinary('!=', left, right);
  public function newBinaryLessThan(left:T, right:T):T
    return newBinary('<', left, right);
  public function newBinaryGreaterThan(left:T, right:T):T
    return newBinary('>', left, right);
  public function newBinaryLessThanEqual(left:T, right:T):T
    return newBinary('<=', left, right);
  public function newBinaryGreaterThanEqual(left:T, right:T):T
    return newBinary('>=', left, right);

  public function newLiteralPrimitive(value:Dynamic):T 
    return new LiteralPrimitive(value);
  public function newLiteralArray(elements:Array<T>):T 
    return new LiteralArray(elements);
  public function newLiteralObject(keys:Array<String>, values:Array<T>):T 
    return new LiteralObject(keys, values);
  public function newLiteralNull():T 
    return newLiteralPrimitive(null);
  public function newLiteralZero():T 
    return newLiteralNumber(0);
  public function newLiteralBoolean(value:Bool):T 
    return newLiteralPrimitive(value);
  public function newLiteralNumber(value:Float):T 
    return newLiteralPrimitive(value);
  public function newLiteralString(value:String):T 
    return new LiteralString(value);
}

class Visitor {
  public function visit(expression:Expression)
    return expression.accept(this);

  public function visitExpression(expression:Expression)
    return null;
  public function visitChain(expression:Chain)
    return visitExpression(expression);
  public function visitFilter(expression:Filter)
    return visitExpression(expression);

  public function visitAssign(expression:Assign)
    return visitExpression(expression);
  public function visitConditional(expression:Conditional)
    return visitExpression(expression);

  public function visitAccessScope(expression:AccessScope)
    return visitExpression(expression);
  public function visitAccessMember(expression:AccessMember)
    return visitExpression(expression);
  public function visitAccessKeyed(expression:AccessKeyed)
    return visitExpression(expression);

  public function visitCallScope(expression:CallScope)
    return visitExpression(expression);
  public function visitCallFunction(expression:CallFunction)
    return visitExpression(expression);
  public function visitCallMember(expression:CallMember)
    return visitExpression(expression);

  public function visitBinary(expression:Binary)
    return visitExpression(expression);

  public function visitPrefix(expression:Prefix)
    return visitExpression(expression);

  public function visitLiteral(expression:Literal)
    return visitExpression(expression);
  public function visitLiteralPrimitive(expression:LiteralPrimitive)
    return visitLiteral(expression);
  public function visitLiteralString(expression:LiteralString)
    return visitLiteral(expression);
  public function visitLiteralArray(expression:LiteralArray)
    return visitLiteral(expression);
  public function visitLiteralObject(expression:LiteralObject)
    return visitLiteral(expression);
}

class Chain extends Expression {
  public var expressions:Array<Expression>;
  public function new(expressions) {
    this.expressions = expressions;
  }
  public override function isChain():Bool return true;
  public override function accept(visitor:Visitor) visitor.visitChain(this);
}

class Filter extends Expression {
  public var name:String;
  public var arguments:Array<Expression>;
  public function new(expression:Expression, name:String, arguments:Array<Expression>) {
    this.expression = expression;
    this.name = name;
    this.arguments = arguments;
  }
  
  public override function accept(visitor:Visitor) visitor.visitFilter(this);
}

class Assign extends Expression {
  public var target:Expression;
  public var value:Expression;
  public function new(target, value) {
    this.target = target;
    this.value = value;
  }
  public override function accept(visitor:Visitor) visitor.visitAssign(this);
}

class Conditional extends Expression {
  public var condition:Expression;
  public var yes:Expression;
  public var no:Expression;
  public function new(condition, yes, no) {
    this.condition = condition;
    this.yes = yes;
    this.no = no;
  }
  public override function accept(visitor:Visitor) visitor.visitConditional(this);
}

class AccessScope extends Expression {
  public var name:String;
  public function new(name) {
    this.name = name;
  }
  public override function isAssignable() return true;
  public override function accept(visitor:Visitor) visitor.visitAccessScope(this);
}

class AccessMember extends Expression {
  public var object:Expression;
  public var name:String;
  public function new(object, name) {
    this.object = object;
    this.name = name;
  }
  public override function isAssignable() return true;
  public override function accept(visitor:Visitor) visitor.visitAccessMember(this);
}

class AccessKeyed extends Expression {
  public var object:Expression;
  public var key:Expression;
  public function new(object, key) {
    this.object = object;
    this.key = key;
  }
  public override function isAssignable() return true;
  public override function accept(visitor:Visitor) visitor.visitAccessKeyed(this);
}

class CallScope extends Expression {
  public var name:String;
  public var arguments:Array<Expression>;
  public function new(name, arguments) {
    this.name = name;
    this.arguments = arguments;
  }
  public override function accept(visitor:Visitor) visitor.visitCallScope(this);
}

class CallFunction extends Expression {
  public var fn:Expression;
  public var arguments:Array<Expression>;
  public function new(fn, arguments) {
    this.fn = fn;
    this.arguments = arguments;
  }
  public override function accept(visitor:Visitor) visitor.visitCallFunction(this);
}

class CallMember extends Expression {
  public var object:Expression;
  public var name:String;
  public var arguments:Array<Expression>;
  public function new(object, name, arguments) {
    this.object = object;
    this.name = name;
    this.arguments = arguments;
  }
  public override function accept(visitor:Visitor) visitor.visitCallMember(this);
}

class Binary extends Expression {
  public var operation:String;
  public var left:Expression;
  public var right:Expression;
  public function new(operation, left, right) {
    this.operation = operation;
    this.left = left;
    this.right = right;
  }
  public override function accept(visitor:Visitor) visitor.visitBinary(this);
}

class Prefix extends Expression {
  public var operation:String;
  public function new(operation, expression) {
    this.operation = operation;
    this.expression = expression;
  }
  public override function accept(visitor:Visitor) visitor.visitPrefix(this);
}

class Literal extends Expression {
}

class LiteralPrimitive extends Literal {
  public var value:Dynamic;
  public function new(value) {
    this.value = value;
  }
  public override function accept(visitor:Visitor) visitor.visitLiteralPrimitive(this);
}

class LiteralString extends Literal {
  public var value:String;
  public function new(value) {
    this.value = value;
  }
  public override function accept(visitor:Visitor) visitor.visitLiteralString(this);
}

class LiteralArray extends Literal {
  public var elements:Array<Expression>;
  public function new(elements) {
    this.elements = elements;
  }
  public override function accept(visitor:Visitor) visitor.visitLiteralArray(this);
}

class LiteralObject extends Literal {
  public var keys:Array<String>;
  public var values:List<Expression>;
  public function new(keys, values) {
    this.keys = keys;
    this.values = values;
  }
  public override function accept(visitor:Visitor) visitor.visitLiteralObject(this);
}
*/