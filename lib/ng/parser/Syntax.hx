package ng.parser;

class Syntax {}

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

typedef Context = Dynamic;
typedef Locals = Dynamic;
typedef LocalsWrapper = Dynamic;

class Expression {
  
  public function isAssignable():Bool return false;
  public function isChain():Bool return false;
  public function eval(scope):Dynamic {
    throw "Cannot evaluate $this";
    return null;
  }
  public function assign(scope, value):Dynamic {
    throw "Cannot assign to $this";
    return null;
  }

  public function bind(context:Context, ?wrapper:LocalsWrapper):Locals->Dynamic {
    return new BoundExpression(this, context, wrapper).call;
  }
  public function accept(visitor:Visitor) {};
  public function toString():String return Unparser.unparse(this);
}

class BoundExpression {

  public var expression: Expression;
  private var context:Context;
  private var wrapper:LocalsWrapper;

  public function new(expression:Expression, context:Context, wrapper:LocalsWrapper) {
    this.expression = expression;
    this.context = context;
    this.wrapper = wrapper.call;
  }

  // NOTE(pythonic): Very very dirty implementation
  public function call(locals:Locals) {
    var result = expression.eval(locals);
    if (result == null) {
      result = expression.eval(context);
    }
    return result;
    // return expression.eval(computeContext(locals));
  }

  public function assign(value, ?locals:Locals):Dynamic {
    return expression.assign(computeContext(locals), value);
  }

  private function computeContext(locals:Locals) {
    if (locals == null) return context;
    if (wrapper != null) return wrapper(context, locals);
    throw "Locals $locals provided, but missing wrapper.";
  }
}

class Chain extends Expression {
  public var expressions:Array<Expression>;
  public function new(expressions) {
    this.expressions = expressions;
  }
  public override function isChain():Bool return true;
  public override function accept(visitor) visitor.visitChain(this);
}

class Filter extends Expression {
  public var expression:Expression;
  public var name:String;
  public var arguments:Array<Expression>;
  public function new(expression:Expression, name:String, arguments:Array<Expression>) {
    this.expression = expression;
    this.name = name;
    this.arguments = arguments;
  }
  
  public override function accept(visitor) visitor.visitFilter(this);
}

class Assign extends Expression {
  public var target:Expression;
  public var value:Expression;
  public function new(target, value) {
    this.target = target;
    this.value = value;
  }
  public override function accept(visitor) visitor.visitAssign(this);
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
  public override function accept(visitor) visitor.visitConditional(this);
}

class AccessScope extends Expression {
  public var name:String;
  public function new(name) {
    this.name = name;
  }
  public override function isAssignable() return true;
  public override function accept(visitor) visitor.visitAccessScope(this);
}

class AccessMember extends Expression {
  public var object:Expression;
  public var name:String;
  public function new(object, name) {
    this.object = object;
    this.name = name;
  }
  public override function isAssignable() return true;
  public override function accept(visitor) visitor.visitAccessMember(this);
}

class AccessKeyed extends Expression {
  public var object:Expression;
  public var key:Expression;
  public function new(object, key) {
    this.object = object;
    this.key = key;
  }
  public override function isAssignable() return true;
  public override function accept(visitor) visitor.visitAccessKeyed(this);
}

class CallScope extends Expression {
  public var name:String;
  public var arguments:Array<Expression>;
  public function new(name, arguments) {
    this.name = name;
    this.arguments = arguments;
  }
  public override function accept(visitor) visitor.visitCallScope(this);
}

class CallFunction extends Expression {
  public var fn:Expression;
  public var arguments:Array<Expression>;
  public function new(fn, arguments) {
    this.fn = fn;
    this.arguments = arguments;
  }
  public override function accept(visitor) visitor.visitCallFunction(this);
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
  public override function accept(visitor) visitor.visitCallMember(this);
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
  public override function accept(visitor) visitor.visitBinary(this);
}

class Prefix extends Expression {
  public var operation:String;
  public var expression:Expression;
  public function new(operation, expression) {
    this.operation = operation;
    this.expression = expression;
  }
  public override function accept(visitor) visitor.visitPrefix(this);
}

class Literal extends Expression {
}

class LiteralPrimitive extends Literal {
  public var value:Dynamic;
  public function new(value) {
    this.value = value;
  }
  public override function accept(visitor) visitor.visitLiteralPrimitive(this);
}

class LiteralString extends Literal {
  public var value:String;
  public function new(value) {
    this.value = value;
  }
  public override function accept(visitor) visitor.visitLiteralString(this);
}

class LiteralArray extends Literal {
  public var elements:Array<Expression>;
  public function new(elements) {
    this.elements = elements;
  }
  public override function accept(visitor) visitor.visitLiteralArray(this);
}

class LiteralObject extends Literal {
  public var keys:Array<String>;
  public var values:Array<Expression>;
  public function new(keys, values) {
    this.keys = keys;
    this.values = values;
  }
  public override function accept(visitor) visitor.visitLiteralObject(this);
}