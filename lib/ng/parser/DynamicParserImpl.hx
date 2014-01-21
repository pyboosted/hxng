package ng.parser;

import ng.parser.Parser;
import ng.parser.Lexer;
import ng.parser.Syntax; 

class DynamicParserImpl {

  public static var EOF:Token = new Token(-1, null);

  public var backend: ParserBackend<Expression>;
  public var input:String;
  public var lexer:Lexer;

  public var tokens:Array<Token>;
  public var index:Int = 0;

  public function new(lexer:Lexer, backend:ParserBackend<Expression>, input:String) {
    this.backend = backend;
    this.input = input;
    tokens = lexer.call(input);
  }

  public function peek():Token {
    return (index < tokens.length) ? tokens[index] : EOF;
  }

  public function parseChain() {
    while (optional(';')) {}
    var expressions = new Array<Expression>();
    while (index < tokens.length) {
      if (peek().text == ')' || peek().text == '}' || peek().text == ']') {
        error('Unconsumed token ${peek().text}');
      }
      expressions.push(parseFilter());
      while (optional(';')) {}
    }
    return (expressions.length == 1) ? expressions[0] : backend.newChain(expressions);
  }
      
  public function parseFilter() {
    var result = parseExpression();
    while (optional('|')) {
      var name = peek().text;
      advance();
      var arguments = [];
      while (optional(':')) {
        arguments.push(parseExpression());
      }
      result = backend.newFilter(result, name, arguments);
    }
    return result;
  }

  public function parseExpression() {
    var start = peek().index;
    var result = parseConditional();
    while (peek().text == '=') {
      if (!backend.isAssignable(result)) {
        var end = (index < tokens.length) ? peek().index : input.length;
        var expression = input.substring(start, end);
        error('Expression $expression is not assignable');
      }
      expect('=');
      result = backend.newAssign(result, parseConditional());
    }
    return result;
  }

  public function parseConditional() {
    var start = peek().index;
    var result = parseLogicalOr();
    if (optional('?')) {
      var yes = parseExpression();
      if (!optional(':')) {
        var end = (index < tokens.length) ? peek().index : input.length;
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
        var name = peek().text;  // TODO(kasperl): Check that this is an identifier
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
    } else if (peek().text == '{') {
      return parseObject();
    } else if (peek().key != null) {
      return parseQualified();
    } else if (peek().value != null) {
      var value:Dynamic = peek().value;
      advance();
      return Std.is(value, Float)
          ? backend.newLiteralNumber(value)
          : backend.newLiteralString(value);
    } else if (index >= tokens.length) {
      throw 'Unexpected end of expression: $input';
    } else {
      error('Unexpected token ${peek().text}');
      return null;
    }
  }

  public function parseQualified() {
    var components = peek().key.split('.');
    advance();
    var arguments = null;
    if (optional('(')) {
      arguments = parseExpressionList(')');
      expect(')');
    }
    
    var result = (arguments != null) && (components.length == 1)
        ? backend.newCallScope(components[0], arguments)
        : backend.newAccessScope(components[0]);
    for (i in 1...components.length) {
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
    if (peek().text != '}') {
      do {
        // TODO(kasperl): Stricter checking. Only allow identifiers
        // and strings as keys. Maybe also keywords?
        var value = peek().value;
        keys.push(Std.is(value, String) ? value : peek().text);
        advance();
        expect(':');
        values.push(parseExpression());
      } while (optional(','));
    }
    expect('}');
    return backend.newLiteralObject(keys, values);
  }

  public function parseExpressionList(terminator:String) {
    var result = [];
    if (peek().text != terminator) {
      do {
        result.push(parseExpression());
       } while (optional(','));
    }
    return result;
  }

  public function optional(text) {
    if (peek().text == text) {
      advance();
      return true;
    } else {
      return false;
    }
  }

  public function expect(text) {
    if (peek().text == text) {
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