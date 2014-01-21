package ng.parser;

using Lambda;

private class Symbols {
  public static inline var _EOF:Int       = 0;
  public static inline var _TAB:Int       = 9;
  public static inline var _LF:Int        = 10;
  public static inline var _VTAB:Int      = 11;
  public static inline var _FF:Int        = 12;
  public static inline var _CR:Int        = 13;
  public static inline var _SPACE:Int     = 32;
  public static inline var _BANG:Int      = 33;
  public static inline var _DQ:Int        = 34;
  public static inline var _DOLLAR:Int    = 36;
  public static inline var _PERCENT:Int   = 37;
  public static inline var _AMPERSAND:Int = 38;
  public static inline var _SQ:Int        = 39;
  public static inline var _LPAREN:Int    = 40;
  public static inline var _RPAREN:Int    = 41;
  public static inline var _STAR:Int      = 42;
  public static inline var _PLUS:Int      = 43;
  public static inline var _COMMA:Int     = 44;
  public static inline var _MINUS:Int     = 45;
  public static inline var _PERIOD:Int    = 46;
  public static inline var _SLASH:Int     = 47;
  public static inline var _COLON:Int     = 58;
  public static inline var _SEMICOLON:Int = 59;
  public static inline var _LT:Int        = 60;
  public static inline var _EQ:Int        = 61;
  public static inline var _GT:Int        = 62;
  public static inline var _QUESTION:Int  = 63;

  public static inline var _0:Int = 48;
  public static inline var _9:Int = 57;

  public static inline var _A:Int = 65;
  public static inline var _B:Int = 66;
  public static inline var _C:Int = 67;
  public static inline var _D:Int = 68;
  public static inline var _E:Int = 69;
  public static inline var _F:Int = 70;
  public static inline var _G:Int = 71;
  public static inline var _H:Int = 72;
  public static inline var _I:Int = 73;
  public static inline var _J:Int = 74;
  public static inline var _K:Int = 75;
  public static inline var _L:Int = 76;
  public static inline var _M:Int = 77;
  public static inline var _N:Int = 78;
  public static inline var _O:Int = 79;
  public static inline var _P:Int = 80;
  public static inline var _Q:Int = 81;
  public static inline var _R:Int = 82;
  public static inline var _S:Int = 83;
  public static inline var _T:Int = 84;
  public static inline var _U:Int = 85;
  public static inline var _V:Int = 86;
  public static inline var _W:Int = 87;
  public static inline var _X:Int = 88;
  public static inline var _Y:Int = 89;
  public static inline var _Z:Int = 90;

  public static inline var _LBRACKET:Int  = 91;
  public static inline var _BACKSLASH:Int = 92;
  public static inline var _RBRACKET:Int  = 93;
  public static inline var _CARET:Int     = 94;
  public static inline var _UNDERSCORE:Int= 95;

  public static inline var _a:Int = 97;
  public static inline var _b:Int = 98;
  public static inline var _c:Int = 99;
  public static inline var _d:Int = 100;
  public static inline var _e:Int = 101;
  public static inline var _f:Int = 102;
  public static inline var _g:Int = 103;
  public static inline var _h:Int = 104;
  public static inline var _i:Int = 105;
  public static inline var _j:Int = 106;
  public static inline var _k:Int = 107;
  public static inline var _l:Int = 108;
  public static inline var _m:Int = 109;
  public static inline var _n:Int = 110;
  public static inline var _o:Int = 111;
  public static inline var _p:Int = 112;
  public static inline var _q:Int = 113;
  public static inline var _r:Int = 114;
  public static inline var _s:Int = 115;
  public static inline var _t:Int = 116;
  public static inline var _u:Int = 117;
  public static inline var _v:Int = 118;
  public static inline var _w:Int = 119;
  public static inline var _x:Int = 120;
  public static inline var _y:Int = 121;
  public static inline var _z:Int = 122;

  public static inline var _LBRACE:Int = 123;
  public static inline var _BAR:Int    = 124;
  public static inline var _RBRACE:Int = 125;
  public static inline var _TILDE:Int  = 126;
  public static inline var _NBSP:Int   = 160;

  public static inline function isWhitespace(code:Int) {
    return (code >= _TAB && code <= _SPACE) || (code == _NBSP);
  }

  public static inline function isIdentifierStart(code:Int) {
    return (_a <= code && code <= _z) || (_A <= code && code <= _Z) || (code == _UNDERSCORE) || (code == _DOLLAR);
  }

  public static inline function isIdentifierPart(code:Int) {
    return (_a <= code && code <= _z)
      || (_A <= code && code <= _Z)
      || (_0 <= code && code <= _9)
      || (code == _UNDERSCORE)
      || (code == _DOLLAR);
  }

  public static inline function isDigit(code:Int) {
    return (_0 <= code && code <= _9);
  }

  public static inline function isExponentStart(code:Int) {
    return (code == _e || code == _E);
  }

  public static inline function isExponentSign(code:Int) {
    return (code == _MINUS || code == _PLUS);
  }

  public static inline function unescape(code:Int) {
    return switch(code) {
      case _n: _LF;
      case _f: _FF;
      case _r: _CR;
      case _t: _TAB;
      case _v: _VTAB;
      default: code;
    }
  }

}

class Token {
  public var index:Int;
  public var text:String;

  public var value:Dynamic;
  // Tokens should have one of these set.
  public var opKey:String;
  public var key:String;

  public function new(index, text) {
    this.index = index;
    this.text = text;
  }

  public function withOp(op):Token {
    opKey = op;
    return this;
  }

  public function withGetterSetter(key):Token {
    this.key = key;
    return this;
  }

  public function withValue(value:Dynamic):Token { 
    this.value = value; 
    return this;
  }

  public function toString():String return "Token($text)";
}

class Lexer {

  public function new() {};
  public function call(text:String):Array<Token> {
    var scanner = new Scanner(text);
    var tokens:Array<Token> = new Array<Token>();
    var token = scanner.scanToken();
    while (token != null) {
      tokens.push(token);
      token = scanner.scanToken();
    }
    return tokens;
  }
}

class Scanner {
  var input:String;
  var length:Int;

  // TODO(kasperl): Get rid of this buffer. It is currently used for
  // pushing back tokens for method calls found while scanning
  // identifiers. We should be able to do this in the parser instead.
  var buffer:Array<Token> = new Array<Token>();

  var peek:Int = 0;
  var index:Int = -1;

  public function new(input:String) {
    this.input = input; this.length = input.length;
    advance();
  }

  public function scanToken():Token {
    // TODO(kasperl): The current handling of method calls is somewhat
    // complicated. We should simplify it by dealing with it in the parser.
    if (buffer.length > 0) return buffer.pop();

    // Skip whitespace.
    while (Symbols.isWhitespace(peek)) advance();

    // Handle identifiers and numbers.
    if (Symbols.isIdentifierStart(peek)) return scanIdentifier();
    if (Symbols.isDigit(peek)) return scanNumber(index);

    var start = index;
    switch (peek) {
      case Symbols._EOF:
        return null;
      case Symbols._PERIOD:
        advance();
        return Symbols.isDigit(peek) ? scanNumber(start) : new Token(start, '.');
      case Symbols._LPAREN:
        return scanCharacter(start, '(');
      case Symbols._RPAREN:
        return scanCharacter(start, ')');
      case Symbols._LBRACE:
        return scanCharacter(start, '{');
      case Symbols._RBRACE:
        return scanCharacter(start, '}');
      case Symbols._LBRACKET:
        return scanCharacter(start, '[');
      case Symbols._RBRACKET:
        return scanCharacter(start, ']');
      case Symbols._COMMA:
        return scanCharacter(start, ',');
      case Symbols._COLON:
        return scanCharacter(start, ':');
      case Symbols._SEMICOLON:
        return scanCharacter(start, ';');
      case Symbols._SQ | Symbols._DQ:
        return scanString();
      case Symbols._PLUS:
        return scanOperator(start, '+');
      case Symbols._MINUS:
        return scanOperator(start, '-');
      case Symbols._STAR:
        return scanOperator(start, '*');
      case Symbols._SLASH:
        return scanOperator(start, '/');
      case Symbols._PERCENT:
        return scanOperator(start, '%');
      case Symbols._CARET:
        return scanOperator(start, '^');
      case Symbols._QUESTION:
        return scanOperator(start, '?');
      case Symbols._LT:
        return scanComplexOperator(start, Symbols._EQ, '<', '<=');
      case Symbols._GT:
        return scanComplexOperator(start, Symbols._EQ, '>', '>=');
      case Symbols._BANG:
        return scanComplexOperator(start, Symbols._EQ, '!', '!=');
      case Symbols._EQ:
        return scanComplexOperator(start, Symbols._EQ, '=', '==');
      case Symbols._AMPERSAND:
        return scanComplexOperator(start, Symbols._AMPERSAND, '&', '&&');
      case Symbols._BAR:
        return scanComplexOperator(start, Symbols._BAR, '|', '||');
      case Symbols._TILDE:
        return scanComplexOperator(start, Symbols._SLASH, '~', '~/');
    }

    var character = String.fromCharCode(peek);
    error('Unexpected character [$character]');
    return null;
  }

  public function scanCharacter(start:Int, string:String) {
    // assert(peek == string.codeUnitAt(0));
    advance();
    return new Token(start, string);
  }

  public function scanOperator(start:Int, string:String):Token {
    // assert(peek == string.codeUnitAt(0));
    // assert(OPERATORS.has(string));
    advance();
    return new Token(start, string).withOp(string);
  }

  public function scanComplexOperator(start:Int, code:Int, one:String, two:String) {
    // assert(peek == one.codeUnitAt(0));
    advance();
    var string:String = one;
    if (peek == code) {
      advance();
      string = two;
    }
    // assert(OPERATORS.has(string));
    return new Token(start, string).withOp(string);
  }

  public function scanIdentifier():Token {
    // assert(Symbols.isIdentifierStart(peek));
    var start = index;
    var dot:Int = -1;
    advance();
    while (true) {
      if (peek == Symbols._PERIOD) {
        dot = index;
      } else if (!Symbols.isIdentifierPart(peek)) {
        break;
      }
      advance();
    }
    if (dot == -1) {
      var string = input.substring(start, index);
      var result = new Token(start, string);
      // TODO(kasperl): Deal with null, undefined, true, and false in
      // a cleaner and faster way.
      if (OPERATORS.has(string)) {
        result.withOp(string);
      } else {
        result.withGetterSetter(string);
      }
      return result;
    }

    var end = index;
    while (Symbols.isWhitespace(peek)) advance();
    if (peek == Symbols._LPAREN) {
      buffer.push(new Token(dot + 1, input.substring(dot + 1, end)));
      buffer.push(new Token(dot, '.'));
      end = dot;
    }
    var string = input.substring(start, end);
    return (new Token(start, string)).withGetterSetter(string);
  }

  public function scanNumber(start:Int):Token {
    // assert(Symbols.isDigit(peek));
    var simple = (index == start);
    while (true) {
      if (Symbols.isDigit(peek)) {
        // Do nothing.
      } else if (peek == Symbols._PERIOD) {
        simple = false;
      } else if (Symbols.isExponentStart(peek)) {
        advance();
        if (Symbols.isExponentSign(peek)) advance();
        if (!Symbols.isDigit(peek)) error('Invalid exponent', -1);
        simple = false;
      } else {
        break;
      }
      advance();
    }
    var string = input.substring(start, index);
    var value = simple ? Std.parseInt(string) : Std.parseFloat(string);
    return (new Token(start, string)).withValue(value);
  }

  public function scanString():Token {
    // assert(peek == Symbols._SQ || peek == Symbols._DQ);
    var start = index;
    var quote = peek;
    advance();  // Skip initial quote.

    var buffer = new Array<String>();
    var marker = index;

    while (peek != quote) {
      if (peek == Symbols._BACKSLASH) {
        if (buffer == null) buffer = new Array<String>();
        buffer.push(input.substring(marker, index));
        advance();
        var unescaped:Int;
        if (peek == Symbols._u) {
          // TODO(kasperl): Check bounds? Make sure we have test
          // coverage for this.
          var hex = input.substring(index + 1, index + 5);
          unescaped = Std.parseInt('0x'+hex);
          for (i in 0...5) advance();
        } else {
          unescaped = Symbols.unescape(peek);
          advance();
        }
        buffer.push(String.fromCharCode(unescaped));
        marker = index;
      } else if (peek == Symbols._EOF) {
        error('Unterminated quote');
      } else {
        advance();
      }
    }

    var last = input.substring(marker, index);
    advance();  // Skip terminating quote.
    var string = input.substring(start, index);

    // Compute the unescaped string value.
    var unescaped = last;
    if (buffer != null) {
      buffer.push(last);
      unescaped = buffer.join('');
    }
    return (new Token(start, string)).withValue(unescaped);
  }

  public function advance() {
    if (++index >= length) peek = Symbols._EOF;
    else peek = input.charCodeAt(index);
  }

  public function error(message:String, ?offset:Int = 0) {
    // TODO(kasperl): Try to get rid of the offset. It is only used to match
    // the error expectations in the lexer tests for numbers with exponents.
    var position = index + offset;
    throw 'Lexer Error: $message at column $position in expression [$input]';
  }

  public static var OPERATORS:Array<String> = ['undefined',
    'null',
    'true',
    'false',
    '+',
    '-',
    '*',
    '/',
    '~/',
    '%',
    '^',
    '=',
    '==',
    '!=',
    '<',
    '>',
    '<=',
    '>=',
    '&&',
    '||',
    '&',
    '|',
    '!',
    '?'];
}