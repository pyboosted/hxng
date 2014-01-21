
class LexerTests extends haxe.unit.TestCase {
  
  var lexer: ng.parser.Lexer;
  var lex:String->Array<ng.parser.Lexer.Token>;

  public function assertToken(token: ng.parser.Lexer.Token, index: Int, text: String) {
    assertTrue(Std.is(token, ng.parser.Lexer.Token));
    assertEquals(token.index, index);
    assertEquals(token.text, text);
  }

  override public function setup() {
    lexer = new ng.parser.Lexer();
    lex = lexer.call;
  }
  
  public function testSetup() {
    assertTrue(lex != null);
  }
  public function testSimpleIdentifier() {
    var tokens = lex('s');
    assertEquals(tokens.length, 1);
    assertToken(tokens[0], 0, 's');
  }

  public function testDottenIdentifier() {
    var tokens = lex("j.k");
    assertEquals(tokens.length, 1);
    assertToken(tokens[0], 0, 'j.k');
  }

  
  public function testOperator() {
    var tokens = lex('j-k');
    assertEquals(tokens.length, 3);
    assertToken(tokens[1], 1, '-');
  }

  public function testIndexedOperator() {
    var tokens = lex('j[k]');
    assertEquals(tokens.length, 4);
    assertToken(tokens[1], 1, '[');
  }

  public function testNumbers() {
    var tokens = lex('88');
    assertEquals(tokens.length, 1);
    assertToken(tokens[0], 0, '88');
  }

  public function testNumbersWithinIndexOps() {
    assertToken(lex('a[22]')[2], 2, '22');
    
  }

  public function testSimpleQuotedStrings() {
    assertToken(lex('"a"')[0], 0, '"a"');
  }

  public function testQuotedStringsWithEscapedQuotes() {
    assertToken(lex('"a\\""')[0], 0, '"a\\""');
  }

  public function testString() {
    var tokens = lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
    var i = 0;

    assertToken(tokens[i], 0, 'j');

    i++;
    assertToken(tokens[i], 1, '-');

    i++;
    assertToken(tokens[i], 2, 'a.bc');

    i++;
    assertToken(tokens[i], 6, '[');

    i++;
    assertToken(tokens[i], 7, '22');

    i++;
    assertToken(tokens[i], 9, ']');

    i++;
    assertToken(tokens[i], 10, '+');

    i++;
    assertToken(tokens[i], 11, '1.3');

    i++;
    assertToken(tokens[i], 14, '|');

    i++;
    assertToken(tokens[i], 15, 'f');

    i++;
    assertToken(tokens[i], 16, ':');

    i++;
    assertToken(tokens[i], 17, '\'a\\\'c\'');

    i++;
    assertToken(tokens[i], 23, ':');

    i++;
    assertToken(tokens[i], 24, '"d\\"e"');
  }

  public function testUndefined() {
    var tokens = lex("undefined");
    var i = 0;
    assertToken(tokens[i], 0, 'undefined');
    assertEquals(tokens[i].value, null);
  }

  public function testIgnoreWhitespace() {
    var tokens = lex("a \t \n \r b");
    assertEquals(tokens[0].text, 'a');
    assertEquals(tokens[1].text, 'b');
  }

  public function testQuotedString() {
    var str = "['\\'', \"\\\"\"]";
    var tokens = lex(str);

    assertEquals(tokens[1].index, 1);
    assertEquals(tokens[1].value, "'");

    assertEquals(tokens[3].index, 7);
    assertEquals(tokens[3].value, '"');
  }

  // NOTE(pythonic): Couldn't test in haxe, ivalid escape sequence
  // public function testEscapedQuotedString() {
  //   var str = '"\\"\\n\\f\\r\\t\\v\\u00A0"';
  //   var tokens = lex(str);

  //   assertEquals(tokens[0].value, '"\n\f\r\t\v\u00A0');
  // }

  // NOTE(pythonic): Couldn't test in haxe, ivalid escape sequence
  // public function testUnicode() {
  //   var tokens = lex('"\\u00A0"');
  //   assertEquals(tokens.length, 1);
  //   assertEquals(tokens[0].value, '\u00a0');
  // }

  public function testRelation() {
    var tokens = lex("! == != < > <= >=");
    assertEquals(tokens[0].text, '!');
    assertEquals(tokens[1].text, '==');
    assertEquals(tokens[2].text, '!=');
    assertEquals(tokens[3].text, '<');
    assertEquals(tokens[4].text, '>');
    assertEquals(tokens[5].text, '<=');
    assertEquals(tokens[6].text, '>=');
  }

  public function testStatements() {
    var tokens = lex("a;b;");
    assertEquals(tokens[0].text, 'a');
    assertEquals(tokens[1].text, ';');
    assertEquals(tokens[2].text, 'b');
    assertEquals(tokens[3].text, ';');
  }

  public function testFunctionInvocation() {
    var tokens = lex("a()");
    assertToken(tokens[0], 0, 'a');
    assertToken(tokens[1], 1, '(');
    assertToken(tokens[2], 2, ')');
  }

  public function testSimpleMethodInvocations() {
    var tokens = lex("a.method()");
    assertToken(tokens[2], 2, 'method');
  }

  public function testMethodInvocation() {
    var tokens = lex("a.b.c (d) - e.f()");
    assertToken(tokens[0], 0, 'a.b');
    assertToken(tokens[1], 3, '.');
    assertToken(tokens[2], 4, 'c');
    assertToken(tokens[3], 6, '(');
    assertToken(tokens[4], 7, 'd');
    assertToken(tokens[5], 8, ')');
    assertToken(tokens[6], 10, '-');
    assertToken(tokens[7], 12, 'e');
    assertToken(tokens[8], 13, '.');
    assertToken(tokens[9], 14, 'f');
    assertToken(tokens[10], 15, '(');
    assertToken(tokens[11], 16, ')');
  }

  public function testNumber() {
    var tokens = lex("0.5");
    assertEquals(tokens[0].value, 0.5);
  }

  // NOTE(deboer): NOT A LEXER TEST
  //    public function testnegative number() {
  //      var tokens = lex("-0.5");
  //      assertEquals(tokens[0].value, -0.5);
  //    }

  public function testNumberWithExponent() {
    var tokens = lex("0.5E-10");
    assertEquals(tokens.length, 1);
    assertEquals(tokens[0].value, 0.5E-10);
    tokens = lex("0.5E+10");
    assertEquals(tokens[0].value, 0.5E+10);
  }

  public function testExceptionForInvalidExponent() {
    var err = null;
    try {
      lex('0.5E-');
    } catch (e:Dynamic) {
      err = e;
    }
    assertEquals(err, 'Lexer Error: Invalid exponent at column 4 in expression [0.5E-]');

    try {
      lex('0.5E-A');
    } catch (e:Dynamic) {
      err = e;
    }
    assertEquals(err, 'Lexer Error: Invalid exponent at column 4 in expression [0.5E-A]');
  }

  public function testNumberStartingWithADot() {
    var tokens = lex(".5");
    assertEquals(tokens[0].value, 0.5);
  }

  // NOTE(pythonic): Couldn't test in haxe, lexing normally :D
  // public function testExceptionOnInvalidUnicode() {
  //   var err = null;
  //   try {
  //     lex("'\\u1''bla'");
  //   } catch (e:Dynamic) {
  //     err = e;
  //   }
  //   assertEquals(err, "Lexer Error: Invalid unicode escape [\\u1''b] at column 2 in expression ['\\u1''bla']");
  // }
  
}