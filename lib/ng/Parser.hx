package ng;


typedef Token = {
  ?index: Int,
  ?text: String,
  ?json: Dynamic,
  ?fn: Dynamic,
  ?string: String,
  ?assign: Dynamic,
  ?constant: Bool,
  ?literal: Bool,
};

typedef OpFn = {
  fn: Dynamic->Dynamic->Dynamic,
  constant: Bool
};

typedef Locals = Dynamic;
private typedef Scope = Dynamic;

class Helpers {

  public static function simpleGetterFn1(key:String, expr:String):Scope->Locals->Dynamic {
    return function (scope:Scope, locals:Locals) {
      if (scope == null) return null;
      var f = Reflect.field(locals, key);
      var s = ((locals != null && f != null) ? locals : scope);
      return Reflect.field(s, key);
    }
  }

  public static function simpleGetterFn2(key0:String, key1:String, expr:String):Scope->Locals->Dynamic {
    return function (scope:Scope, locals:Locals) {
      if (scope == null) return null;
      var f = Reflect.field(locals, key0);
      var s = ((locals != null && f != null)) ? locals: scope;
      scope = Reflect.field(s, key0);
      return Reflect.field(scope, key1);
    }
  }

  public static function getterFn(path:String, options:Dynamic, fullExp:String):Scope->Locals->Dynamic {
    var pathKeys = path.split('.');
    var pathKeysLength = pathKeys.length;
    var fn;

    if (pathKeysLength == 1) {
      fn = simpleGetterFn1(pathKeys[0], fullExp);
    } else if (pathKeysLength == 2) {
      fn = simpleGetterFn2(pathKeys[0], pathKeys[1], fullExp);
    } else {
      var code = 'var p;\n';
      for (i in 0...pathKeysLength) {
        var key = pathKeys[i];
        code += 'if (s == null) return undefined;\n' +
          's=' + ((i>0)?'s':'((k&&k.hasOwnProperty("' + key + '"))?k:s)') + '["' + key + '"]' + ';\n';
      }
      code += 'return s;';

      var evaledFnGetter = untyped __js__('new Function')("s", "k", "pw", code);
      evaledFnGetter.toString = function () { return code; };
      fn = cast evaledFnGetter;
    }
    return fn;
  }

  public static function setter(obj:Dynamic, path:String, setValue:Dynamic, fullExp:String, ?options:Dynamic):Dynamic {
    var element = path.split('.');
    var key;
    var i = 0;
    while(element.length > 1) {
      i++;
      key = element.shift();
      var propertyObj = Reflect.field(obj, key);
      if (propertyObj == null) {
        propertyObj = {};
        Reflect.setField(obj, key, propertyObj);
      }
      obj = propertyObj;
    }
    key = element.shift();
    Reflect.setField(obj ,key, setValue);
    return setValue;
  }
}

class Lexer {

  public static var ESCAPE:Map<String, String> = ['n' => '\n', '\'' => '\'', '"' => '"'];
  public static var OPERATORS:Map<String, Dynamic> = [
    'null' => function () { return null; },
    'true' => function () { return true; },
    'false' => function () { return false; },
    '+' => function (self, locals, afn, bfn) {
      var a = afn.fn(self, locals); 
      var b = bfn.fn(self,locals);
      if (a != null) {
        if (b != null) {
          return a + b;
        }
        return a;
      }
      return (b != null)?b:null;
    },
    '-' => function (self, locals, afn, bfn) {
      var a = afn.fn(self, locals); 
      var b = bfn.fn(self, locals);
      return ((a != null)?a:0) - ((b != null)?b:0);
    },
     '*' => function(self, locals, a,b){return a.fn(self, locals)*b.fn(self, locals);},
    '/' => function(self, locals, a,b){return a.fn(self, locals)/b.fn(self, locals);},
    '%' => function(self, locals, a,b){return a.fn(self, locals)%b.fn(self, locals);},
    '^' => function(self, locals, a,b){return a.fn(self, locals)^b.fn(self, locals);},
    '=' => function () { return null; },
    '===' => function(self, locals, a, b){return a.fn(self, locals)==b.fn(self, locals);},
    '!==' => function(self, locals, a, b){return a.fn(self, locals)!=b.fn(self, locals);},
    '==' => function(self, locals, a,b){return a.fn(self, locals)==b.fn(self, locals);},
    '!=' => function(self, locals, a,b){return a.fn(self, locals)!=b.fn(self, locals);},
    '<' => function(self, locals, a,b){return a.fn(self, locals)<b.fn(self, locals);},
    '>' => function(self, locals, a,b){return a.fn(self, locals)>b.fn(self, locals);},
    '<=' => function(self, locals, a,b){return a.fn(self, locals)<=b.fn(self, locals);},
    '>=' => function(self, locals, a,b){return a.fn(self, locals)>=b.fn(self, locals);},
    '&&' => function(self, locals, a,b){return a.fn(self, locals)&&b.fn(self, locals);},
    '||' => function(self, locals, a,b){return a.fn(self, locals)||b.fn(self, locals);},
    '&' => function(self, locals, a,b){return a.fn(self, locals)&b.fn(self, locals);},
    '|' => function(self, locals, a,b){return b.fn(self, locals)(self, locals, a.fn(self, locals));},
    '!' => function(self, locals, a){return !a.fn(self, locals);}
  ];

  var options: Dynamic;
  public function new() {
    
  }

  var text: String;
  var index: Int = 0;
  var ch:String = null;
  var lastCh:String = null;
  var tokens: Array<Token> = new Array<Token>();

  function throwError(msg:String, ?data:Dynamic) {
    throw 'syntax error ' + msg;
  }

  public function lex(text:String):Array<Token> {
    this.text = text;

    var token;
    var json = [];

    while(index < text.length) {
      ch = text.charAt(index);
      if (is('"\'')) {
        readString(ch);
      } else if (isNumber(ch) || is('.') && isNumber(peek(1))) {
        readNumber();
      } else if (isIdent(ch)) {
        readIdent();
        if (was('{,') && json[0] == '{' && (token = tokens[tokens.length - 1]) != null) {
          token.json = token.text.indexOf('.') == -1;
        }
      } else if (is('(){}[].,;:?')) {
        tokens.push({
          index: index,
          text: ch,
          json: (was(':[,') && is('{[')) || is('}]:,')
        });
        if (is('{[')) json.unshift(ch);
        if (is('}]')) json.shift();
        index++;
      } else if (isWhitespace(ch)) {
        index++; continue;
      } else {
        var ch2 = ch + peek(1);
        var ch3 = ch2 + peek(2);
        var fn = OPERATORS.get(ch);
        var fn2 = OPERATORS.get(ch2);
        var fn3 = OPERATORS.get(ch3);
        if (fn3) {
          tokens.push({index: index, text:ch3, fn: fn3});
          index += 3;
        } else if (fn2) {
          tokens.push({index: index, text:ch2, fn: fn2});
          index += 2;
        } else if (fn) {
          tokens.push({index: index, text:ch, fn: fn, json: (was('[,:') && is('+-')) });
          index += 1;
        } else {
          throwError('Unexpected next char ', [index, index + 1]);
        }
      }
      lastCh = ch;
    }
    return tokens;
  }

  function is(chars:String):Bool {
    return chars.indexOf(ch) != -1;
  }

  function was(chars:String):Bool {
    return chars.indexOf(lastCh) != -1;
  }

  function peek(i:Int):String {
    return (index + i < text.length) ? text.charAt(index + i) : null;
  }

  function isNumber(char:String):Bool {
    return ('0' <= char) && (char <= '9');
  }

  function isIdent(char:String):Bool {
    return ('a' <= char && char <= 'z' || 'A' <= char && char <= 'Z' || '_' == char || char == '$');
  }

  function isExpOperator(char:String):Bool {
    return (char == '-' || char == '+' || isNumber(char));
  }

  function readNumber():Void {
    var number = '';
    var start = index;
    while(index < text.length) {
      var ch = text.charAt(index);
      if (ch == '.' || isNumber(ch)) {
        number += ch;
      } else {
        var peekCh = peek(1);
        if (ch == 'e' && isExpOperator(peekCh)) {
          number += ch;
        } else if (isExpOperator(ch) && peekCh != null && isNumber(peekCh) && number.charAt(number.length - 1) == 'e' ) {
          number += ch;
        } else if (isExpOperator(ch) && (peekCh == null || !isNumber(peekCh)) && number.charAt(number.length - 1) == 'e') {
          throwError('Invalid exponent');
        } else {
          break;
        }
      }
      index++;
    }
    var num = Std.parseInt(number);
    tokens.push({
      index: start,
      text: number,
      json: true,
      fn: function () { return num; }
    });
  }

  function isWhitespace(ch):Bool {
    return (ch == ' ' || ch == '\n');
  }

  function readIdent():Void {
    var ident = '';
    var start = index;
    var lastDot:Int = null;
    var peekIndex:Int = null;
    var methodName:String = null;
    var ch:String = null;

    while(index < text.length) {
      ch = text.charAt(index);
      if (ch == '.' || isIdent(ch) || isNumber(ch)) {
        if (ch == '.') lastDot = index;
        ident += ch;
      } else {
        break;
      }
      index++;
    }

    if (lastDot != null) {
      peekIndex = index;
      while (peekIndex < text.length) {
        ch = text.charAt(peekIndex);
        if (ch == '(') {
          methodName = ident.substr(lastDot - start + 1);
          ident = ident.substr(0, lastDot - start);
          index = peekIndex;
          break;
        }
        if (isWhitespace(ch)) {
          peekIndex++;
        } else {
          break;
        }
      }
    }

    // TODO
    var token = {
      index: start,
      text: ident,
      json: false,
      fn: null,
      assign: null
    };

    if (OPERATORS.exists(ident)) {
      token.fn = OPERATORS.get(ident);
      token.json = OPERATORS.get(ident);
    } else {

      var getter = Helpers.getterFn(ident, options, text);
      token.fn = function (self, locals) {
        return getter(self, locals);
      }
      token.assign = function (self:Scope, value:Dynamic) {
        return Helpers.setter(self, ident, value, text, options);
      }
    }

    tokens.push(token);

    if (methodName != null) {
      tokens.push({
        index: lastDot,
        text: '.',
        json: false
      });
      tokens.push({
        index: lastDot + 1,
        text: methodName,
        json: false
      });
    }
  }

  function readString(quote) {
    var start = index;
    index++;
    var string = '';
    var rawString = quote;
    var escape = false;
    while (index < text.length) {
      var ch = text.charAt(index);
      rawString += ch;
      if (escape) {
        if (ch == 'u') {
          var hex = text.substring(index + 1, index + 5);
          var hexEreg:EReg = ~/[\da-f]{4}/i;
          if (!hexEreg.match(hex))
            throwError('Invalid unicode escape [\\u$hex]');
          index += 4;
          string += String.fromCharCode(Std.parseInt('0x' + hex));
        } else {
          var rep = ESCAPE[ch];
          if (rep != null) {
            string += rep;
          } else {
            string += ch;
          }
        }
        escape = false;
      } else if (ch == '\\') {
        escape = true;
      } else if (ch == quote) {
        index++;
        tokens.push({
          index:start,
          text:rawString,
          string:string,
          json: true,
          fn: function () { return string; }
        });
        return;
      } else {
        string += ch;
      }
      index++;
    }
    throwError('Unterminated quote', start);
  }

}

class Parser {

  var tokens: Array<Token>;
  var lexer:Lexer;
  public function new(lexer:Lexer) {
    this.lexer = lexer;
  }
  var text:String;
  var options:Dynamic = null;
  public function _parse(text: String): Dynamic {
    this.text = text;
    tokens = lexer.lex(text);
    var value = statements();

    if (tokens.length != 0) {
      throwError('is an unexpected token', tokens[0]);
    }
    return value;
  }
  
  function throwError(msg:String, ?data:Dynamic):Void {
    trace('Error', msg, data);
    throw 'Syntax Error: $msg';
  }

  function peekToken():Token {
    if (tokens.length == 0)
      throwError('Unexpected end of expression', this.text);
    return tokens[0];
  }

  function primary():Token {
    var primary;
    if (expect('(') != null) {
      primary = filterChain();
      consume(')');
    } else if (expect('[') != null) {
      primary = arrayDeclaration();
    } else if (expect('{') != null) {
      primary = object();
    } else {
      var token = expect();
      primary = token;
      if (primary == null) {
        throwError('not a primary expression', token);
      }
      if (token.json != null && token.json != false) {
        primary.constant = true;
        primary.literal = true;
      }
    }

    var next = null, context = null;
    while ((next = expect('(', '[', '.')) != null) {
      if (next.text == '(') {
        primary = functionCall(primary, context);
        context = null;
      } else if (next.text == '[') {
        context = primary;
        primary = objectIndex(primary);
      } else if (next.text == '.') {
        context = primary;
        primary = fieldAccess(primary);
      } else {
        throwError('IMPOSSIBLE');
      }
    }
    return primary;
  }

  function statements():Token {
    var statements:Array<Token> = new Array<Token>();
    while(true) {
      if (tokens.length > 0 && peek('}', ')', ';', ']') == null)
        statements.push(filterChain());
      if (expect(';') == null) {
        return (statements.length == 1) ? statements[0] : {
          fn: function (self:Scope, locals:Locals):Dynamic {
            var value = null;
            for (statement in statements) {
              if (statement != null) value = statement.fn(self, locals);
            }
            return value;
          }
        }
      }
    }
  }

  function peek(?e1:String, ?e2:String, ?e3:String, ?e4:String):Token {
    if (tokens.length > 0) {
      var token = this.tokens[0];
      var t = token.text;
      if (t == e1 || t == e2 || t == e3 || t == e4 || (e1 == null && e2 == null && e3 == null && e4 == null)) {
        return token;
      }
    }
    return null;
  }

  function expect(?e1:String, ?e2:String, ?e3:String, ?e4:String):Token {
    var token = peek(e1,e2,e3,e4);
    if (token != null) {
      tokens.shift();
      return token;
    }
    return null;
  }

  function consume(e1):Void {
    if (expect(e1) == null) {
      var token = peek();
      throwError('token "' + token.text + '" is unexpected, expecting "$e1" in "$text" at ' + token.index, token);
    }
  }

  function unaryFn(fn, right:Token):Token {
    return {
      fn: function (self: Scope, locals: Locals) {
        return fn(self, locals, right);
      },
      constant: right.constant
    }
  }

  function ternaryFn(left:Token, middle:Token, right:Token):Token {
    return {
      fn: function (self: Scope, locals: Locals) {
        return (left.fn(self, locals, right) != null && left.fn(self, locals, right) != false) ? middle.fn(self, locals) : right.fn(self, locals);
      },
      constant: left.constant && middle.constant && right.constant
    }
  }

  function binaryFn(left:Token, fn, right:Token):Token {
    return {
      fn: function (self: Scope, locals: Locals) {
        return fn(self, locals, left, right);
      },
      constant: left.constant && right.constant
    }
  }



  function filterChain():Token {
    var left = expression();
    var token = null;
    while (true) {
      if ((token = this.expect('|')) != null) {
        left = binaryFn(left, token.fn, filter());
      } else {
        return left;
      }
    }
    return null;
  }

  function expression():Token {
    return assigment();
  }

  function assigment():Token {
    var left = ternary();
    var right;
    var token;
    if ((token = expect('=')) != null) {
      if (left.assign == null) {
        throwError('implies assigment but [] can not be assigned to', token);
      }
      right = this.ternary();
      return { 
        fn: function (scope: Scope, locals: Locals) {
          return left.assign(scope, right.fn(scope, locals), locals);
        }
      }
    }
    return left;
  }

  function ternary():Token {
    var left = logicalOR();
    var middle;
    var token;
    if ((token = expect('?')) != null) {
      middle = ternary();
      if ((token = expect(':')) != null) {
        return ternaryFn(left, middle, ternary());
      } else {
        throwError('expected :', token);
        return null;
      }
    } else {
      return left;
    }
  }

  function logicalOR():Token {
    var left = logicalAND();
    var token;
    while (true) {
      if ((token = expect('||')) != null) {
        left = binaryFn(left, token.fn, logicalAND());
      } else {
        return left;
      }
    }
  }

  function logicalAND() {
    var left = equality();
    var token;
    if ((token = expect('&&')) != null) {
      left = binaryFn(left, token.fn, logicalAND());
    }
    return left;
  }

  function equality() {
    var left = relational();
    var token;
    if ((token = expect('==','!=','===','!==')) != null) {
      left = binaryFn(left, token.fn, equality());
    }
    return left;
  }

  function relational() {
    var left = additive();
    var token;
    if ((token = expect('<', '>', '<=', '>=')) != null) {
      left = binaryFn(left, token.fn, relational());
    }
    return left;
  }

  function additive() {
    var left = multiplicative();
    var token;
    while ((token = expect('+','-')) != null) {
      left = binaryFn(left, token.fn, multiplicative());
    }
    return left;
  }

  function multiplicative() {
    var left = unary();
    var token;
    while ((token = expect('*','/','%')) != null) {
      left = binaryFn(left, token.fn, unary());
    }
    return left;
  }

  function unary() {
    var token;
    if (expect('+') != null) {
      return primary();
    } else if ((token = expect('-')) != null) {
      return binaryFn({ fn: Parser.ZERO, constant: false }, token.fn, unary());
    } else if ((token = this.expect('!')) != null) {
      return unaryFn(token.fn, unary());
    } else {
      return primary();
    }
  }
  
  function fieldAccess(object:Token):Token {
    var field = expect().text;
    var getter = Helpers.getterFn(field, options, text);
    return {
      fn: function(scope, locals, self) {
        return getter(self || object.fn(scope, locals), locals);
      },
      assign: function(scope, value, locals) {
        return Helpers.setter(object.fn(scope, locals), field, value, text, options);
      }
    };
  }

  function objectIndex(obj:Token):Token {

    var indexFn = expression();
    consume(']');

    return {
      fn: function(self, locals) {
        var o = obj.fn(self, locals),
            i = indexFn.fn(self, locals),
            v;

        if (o == null) return null;
        v = Reflect.field(o, i);
        return v;
      },
      assign: function(self, value, locals) {
        var key = indexFn.fn(self, locals);
        var safe = obj.fn(self, locals);
        Reflect.setField(safe, key, value);
        return value;
      }
    };
  }

  function functionCall(fn:Token, ?contextGetter:Token):Token {
    var argsFn = [];
    if (peekToken().text != ')') {
      do {
        argsFn.push(expression());
      } while (expect(',') != null);
    }
    consume(')');

    return {
      fn: function(scope, locals) {
        var args = [];
        var context = (contextGetter != null) ? contextGetter.fn(scope, locals) : scope;

        for (i in 0...argsFn.length) {
          args.push(argsFn[i].fn(scope, locals));
        }
        var fnPtr = fn.fn(scope, locals, context);
        if (fnPtr == null) fnPtr = function () { return null; };

        // IE stupidity! (IE doesn't have apply for some native functions)
        var v = untyped __js__('fnPtr.apply
              ? fnPtr.apply(context, args)
              : fnPtr(args[0], args[1], args[2], args[3], args[4])');
        return v;
      }
    };
  }

  function arrayDeclaration():Token {
    var elementFns = [];
    var allConstant = true;
    if (peekToken().text != ']') {
      do {
        var elementFn = this.expression();
        elementFns.push(elementFn);
        if (!elementFn.constant) {
          allConstant = false;
        }
      } while (this.expect(',') != null);
    }
    this.consume(']');

    return {
      fn: function(self, locals) {
        var array = [];
        for (i in 0...elementFns.length) {
          array.push(elementFns[i].fn(self, locals));
        }
        return array;
      },
      literal: true,
      constant: allConstant
    };
  }

  function object():Token {
    var keyValues = [];
    var allConstant = true;
    if (peekToken().text != '}') {
      do {
        var token = expect(),
        key = token.string;
        if (key == null) key = token.text;
        consume(':');
        var value = expression();
        keyValues.push({key: key, value: value});
        if (!value.constant) {
          allConstant = false;
        }
     } while (this.expect(',') != null);
    }
    consume('}');

    return {
      fn: function(self, locals) {
        var object = {};
        for (i in 0...keyValues.length) {
          var keyValue = keyValues[i];
          Reflect.setField(object, keyValue.key, keyValue.value.fn(self, locals));
        }
        return object;
      },
      literal: true,
      constant: allConstant
    };
  }
  
  function filter():Token {
    var token = expect();
    var fn = Filter.filter(token.text);
    var argsFn = [];
    while (true) {
      if ((token = expect(':'))!=null) {
        argsFn.push(expression());
      } else {
        var fnInvoke = function (self, locals, input) {
          var args = [input];
          for (i in 0...argsFn.length) {
            args.push(argsFn[i].fn(self, locals));
          }
          return (untyped fn).apply(self, args);
        };
        return {
          fn: function () {
            return fnInvoke;
          }
        }
      }
    }
  }

  public static function parse(expr:String): Token {
    var lexer = new Lexer();
    var parser = new Parser(lexer);

    return parser._parse(expr);

  }

  public static function ZERO() {
    return 0;
  }
}