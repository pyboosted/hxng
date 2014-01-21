class TestData {
  public var str:String = "testString";
  public function method() return "testMethod";
  public function new() {};

  private var _getSet:String = 'Hello';
  public var getSet(get, set):String;

  public function get_getSet() {
    return _getSet;
  }

  public function set_getSet(value) {
    return _getSet = value;
  }
}

#if rtti_support @:rtti #end
class WithPrivateField {
  public var publicField:Int = 4;
  private var privateField:Int = 5;
  public function new() {};
}

class ScopeWithErrors {
  public function new() {};
  public var boo(get, null):String; 
  public function get_boo() { throw "boo to you"; return null; }
  public function foo() { throw "foo to you"; }
}

class Ident {
  public function new() {}
  public function id(x:Int):Int return x;
  public function doubleId(x:Int,y:Int):Array<Int> return [x,y];
}


class ParserTests extends haxe.unit.TestCase {


  var parse: String->ng.parser.Syntax.Expression;
  var scope: Dynamic = {};

  public function eval(text:String, ?localScope:Dynamic = null):Dynamic {
    if (localScope != null) return parse(text).eval(localScope);
    return parse(text).eval(scope);
  }


  // setup

  override public function setup() {
    parse = ng.parser.DynamicParser.parse;
  }
  
  public function testSetup() {
    assertTrue(parse != null);
  }

  // expressions

  public function testNumericalExpressions() {
    assertEquals(eval('1'), 1);
  }

  public function testUnaryExpressions() {
    assertEquals(eval("-1"),-1);
    assertEquals(eval("+1"),1);
  }


  public function testUnaryNotExpressions() {
    assertEquals(eval("!true"), !true);
  }


  public function testMultiplicativeExpressions() {
    //NOTE(pythonic): Hi, Haxe! Priorities differ here (%-operator in HaXe and JS)
    assertEquals(eval("3*4/2%5"), (3*4/2)%5);
  }


  public function testAdditiveExpressions() {
    assertEquals(eval("3+6-2"), 3+6-2);
  }


  public function testRelationalExpressions() {
    assertEquals(eval("2<3"), 2<3);
    assertEquals(eval("2>3"), 2>3);
    assertEquals(eval("2<=2"), 2<=2);
    assertEquals(eval("2>=2"), 2>=2);
  }


  public function testEqualityExpressions() {
    assertEquals(eval("2==3"), 2==3);
    assertEquals(eval("2!=3"), 2!=3);
  }


  public function testLogicalANDExpressions() {
    assertEquals(eval("true&&true"), true&&true);
    assertEquals(eval("true&&false"), true&&false);
  }


  public function testlogicalORExpressions() {
    assertEquals(eval("true||true"), true||true);
    assertEquals(eval("true||false"), true||false);
    assertEquals(eval("false||false"), false||false);
  }


  public function testTernaryConditionalExpressions() {
    var a, b, c;
    assertEquals(eval("7==3+4?10:20"), true?10:20);
    assertEquals(eval("false?10:20"), false?10:20);
    assertEquals(eval("5?10:20"), ng.parser.Utils.toBool(5)?10:20);
    assertEquals(eval("null?10:20"), ng.parser.Utils.toBool(null)?10:20);
    assertEquals(eval("true||false?10:20"), true||false?10:20);
    assertEquals(eval("true&&false?10:20"), true&&false?10:20);
    assertEquals(eval("true?a=10:a=20"), true?a=10:a=20);
    assertEquals(scope.a, 10); assertEquals(a, 10);
    scope.a = a = null;
    assertEquals(eval("b=true?a=false?11:c=12:a=13"), b=true?a=false?11:c=12:a=13);
    assertEquals(scope.a, a); assertEquals(a, 12);
    assertEquals(scope.b, b); assertEquals(b, 12);
    assertEquals(scope.c, c); assertEquals(c, 12);
  }


  public function testAutoConvertIntsToStrings() {
    assertEquals(eval("'str ' + 4"), "str 4");
    assertEquals(eval("4 + ' str'"), "4 str");
    assertEquals(eval("4 + 4"), 8);
    assertEquals(eval("4 + 4 + ' str'"), "8 str");
    assertEquals(eval("'str ' + 4 + 4"), "str 44");
  }

  // error handling

  public function assertThrow(text: String, error: String) {
    var err = null;
    try {
      eval(text);
    } catch (e:Dynamic) {
      err = e;
    }
    assertEquals(err, error);
  }

  public function assertThrowFn(fn: Void->Void, error: String) {
    var err = null;
    try {
      fn();
    } catch (e:Dynamic) {
      err = e;
    }
    assertEquals(err, error);
  }

  public function testReasonableErrorForUnconsumedTokens() {
    assertThrow(")", 'Parser Error: Unconsumed token ) at column 1 in [)]');
  }


  public function testMissingExprectedToken() {
    assertThrow("a(b", 'Parser Error: Missing expected ) the end of the expression [a(b]');
  }


  public function testBadAssigment() {
    assertThrow("5=4", 'Parser Error: Expression 5 is not assignable at column 2 in [5=4]');
    assertThrow("array[5=4]", 'Parser Error: Expression 5 is not assignable at column 8 in [array[5=4]]');
  }

  // NOTE(pythonic): Everything is dynamic
  // public function testNonListNonMapFieldAccess() {
  //   assertThrow("6[3]", 'Attempted field access on a non-list, non-map');
  //   assertThrow("6[3]=2", 'Attempting to set a field on a non-list, non-map');
  // }

  public function testIncorectTernaryOperationSyntax() {
    assertThrow("true?1", 'Parser Error: Conditional expression true?1 requires all 3 expressions the end of the expression [true?1]');
  }

  // NOTE(pythonic): Cannot test
  public function testNonFunctionCall() {
    assertThrow("4()", '4 is not a function');
  }

  public function testLetNullBeNull() {
    scope.map = {};

    assertEquals(eval('null'), null);
    assertEquals(eval('map.null'), null);
  }


  public function testBehaveGracefullyWithANullScope() {
    assertEquals(parse('null').eval(null), null);
  }


  public function testPassExceptionsThroughGetters() {
    assertThrowFn(
      function () { parse('boo').eval(new ScopeWithErrors()); },
      'boo to you'
    );
  }


  public function testPassExceptionsthroughMethods() {
    assertThrowFn(
      function () { parse('foo()').eval(new ScopeWithErrors()); },
      'foo to you'
    );
  }


  public function testFailIfReflectedObjectHasNoProperty() {
    assertThrowFn(
      function () { parse('notAProperty').eval(new TestData()); },
      null
    );
  }

  public function testFailOnPrivateFieldAccess() {
    assertEquals(parse('publicField').eval(new WithPrivateField()), 4);

    #if rtti_support
    assertThrowFn(
      function () { parse('privateField').eval(new WithPrivateField()); },
      'Cannot access private property'
    );
    #end
  }

  public function testSetAFieldInAMap() {
    scope = {};
    scope.map = new haxe.ds.StringMap();
    eval('map["square"] = 6');
    // eval('map.dot = 7');

    assertEquals(scope.map.square, 6);
  }


  public function testSetAFieldInAList() {
    scope.list = [];
    eval('list[3] = 2');

    assertEquals(scope.list.length, 4);
    assertEquals(scope.list[3], 2);
  }


  public function testSetAFieldOnAnObject() {
    scope.obj = {};
    eval('obj.field = 1');

    assertEquals(scope.obj.field, 1);
  }

  public function testSetAFieldInANestedMapOnAnObject() {
    scope = {};
    scope.obj = {};
    eval('obj.map.mapKey = 3');

    assertEquals(scope.obj.map.mapKey, 3);
  }


  public function testSetAFieldInANestedObjectOnAnObject() {
    scope = {};
    scope.obj = {};
    eval('obj.nested.field = 1');

    assertEquals(scope.obj.nested.field, 1);
  }


  public function testCreateAMapForDottedAcces() {
    scope = {};
    scope.obj = {};
    eval('obj.field.key = 4');

    assertEquals(scope.obj.field.key, 4);
  }

  // TODO(pythonic): Implement type msimatch check for rtti_enabled mode
  // public function testThrowANiceErrorForTypeMismatch() {
  //   scope['obj'] = new SetterObject();
  //   expect(() {
  //     eval('obj.integer = "hello"');
  //   }).toThrow("Eval Error: Caught type 'String' is not a subtype of type 'int' of 'value'. while evaling [obj.integer = \"hello\"]");
  // }

  // Imported from angular.js
  public function testNgexpressions() {
    assertEquals(eval("-1"), -1);
    assertEquals(eval("1 + 2.5"), 3.5);
    assertEquals(eval("1 + -2.5"), -1.5);
    assertEquals(eval("1+2*3/4"), 1+2*3/4);
    assertEquals(eval("0--1+1.5"), 0- -1 + 1.5);
    assertEquals(eval("-0--1++2*-3/-4"), -0- -1+ 2*-3/-4);
    assertEquals(eval("1/2*3"), 1/2*3);
  }

  
  public function testNgComparison() {
    assertEquals(eval("false"), false);
    assertEquals(eval("!true"), false);
    assertEquals(eval("1==1"), true);
    assertEquals(eval("1!=2"), true);
    assertEquals(eval("1<2"), true);
    assertEquals(eval("1<=1"), true);
    assertEquals(eval("1>2"), 1>2);
    assertEquals(eval("2>=1"), 2>=1);
    assertEquals(eval("true==2<3"), true == (2<3));
  }

  
  public function testNgLogical() {
    assertEquals(eval("0&&2"), (0!=0)&&(2!=0)); 
    assertEquals(eval("0||2"), 0!=0||2!=0);
    assertEquals(eval("0||1&&2"), 0!=0||1!=0&&2!=0);
  }

  // NOTE(pythonic): Hard to test in haxe.
  public function testNgTernary() {

    var returnTrue = scope.returnTrue = function () return true;
    var returnFalse = scope.returnFalse = function () return false;
    var returnString = scope.returnString = function () return 'asd';
    var returnInt = scope.returnInt = function () return 123;
    var identity = scope.identity = function (x) return x;
    var B = ng.parser.Utils.toBool;

    assertEquals(eval('true?true:false'), true);
    assertEquals(eval('false?true:false'), false);

    // Function calls.
    assertEquals(eval('returnTrue() ? returnString() : returnInt()'), returnTrue() ? returnString() : returnInt());
    assertEquals(eval('returnFalse() ? returnString() : returnInt()'), returnFalse() ? returnString() : returnInt());
    assertEquals(eval('returnTrue() ? returnString() : returnInt()'), returnTrue() ? returnString() : returnInt());
    assertEquals(eval('identity(returnFalse() ? returnString() : returnInt())'), identity(returnFalse() ? returnString() : returnInt()));
    
  }


  public function testNgString() {
    assertEquals(eval("'a' + 'b c'"), "ab c");
  }


  public function testNgAccessScope() {
    var scope:Dynamic = {};
    scope.a =  123;
    scope.b = { c: 456 };
    assertEquals(eval('a', scope), 123);
    assertEquals(eval('b.c', scope), 456);
    assertEquals(eval('x.y.z', scope), null);
  }


  public function testNgAccessClassesOnScope() {
    scope.ident = new Ident();
    assertEquals(eval('ident.id(6)'), 6);
    assertEquals(eval('ident.doubleId(4,5)[0]'), 4);
    assertEquals(eval('ident.doubleId(4,5)[1]'), 5);
  }


  public function testNgResolveDeeplyNestedPaths() {
    scope.a = {'b': {'c': {'d': {'e': {'f': {'g': {'h': {'i': {'j': {'k': {'l': {'m': {'n': 'nooo!'}}}}}}}}}}}}};
    assertEquals(eval("a.b.c.d.e.f.g.h.i.j.k.l.m.n"), 'nooo!');
  }


  public function testNgBeForgiving() {
    scope = {'a': {'b': 23}};
    assertEquals(eval('b'), null);
    assertEquals(eval('a.x'), null);
  }

  // NOTE(pythonic): It parsed ok. Let it be forgiving in hx-version
  // public function testNgCatchNoSuchMethod() {
  //   scope = {'a': {'b': 23}};
  //   assertThrowFn(function () { 
  //     eval('a.b.c.d');
  //   }, 'NoSuchMethod');
  // }


  public function testNgEvaluateGroupedExpressions() {
    assertEquals(eval("(1+2)*3"), (1+2)*3);
  }


  public function testNgEvaluateAssignments() {
    scope = {'g': 4, 'arr': [3,4]};

    assertEquals(eval("a=12"), 12);
    assertEquals(scope.a, 12);

    assertEquals(eval("arr[c=1]"), 4);
    assertEquals(scope.c, 1);

    assertEquals(eval("x.y.z=123;"), 123);
    assertEquals(scope.x.y.z, 123);

    assertEquals(eval("a=123; b=234"), 234);
    assertEquals(scope.a, 123);
    assertEquals(scope.b, 234);
  }

  // TODO: assignment to an arr[c]
  // TODO: failed assignment
  // TODO: null statements in multiple statements

  
  public function testNgEvaluateFunctionCallWithoutArguments() {
    scope.constN = function () return 123;
    assertEquals(eval("constN()"), 123);
  }

  public function testNgAccessAProtectedKeywordOnScope() {
    scope.const = 3;
    assertEquals(eval('const'), 3);
  }


  public function testNgEvaluateFunctionCallWithArguments() {
    scope.add = function (a,b) {
      return a+b;
    };
    assertEquals(eval("add(1,2)"), 3);
  }


  public function testNgEvaluateFunctionCallFromAReturnValue() {
    scope.val = 33;
    scope.getter = function () { 
      return function () { 
        return scope.val; 
      };
    };
    assertEquals(eval("getter()()"), 33);
  }


  public function testNgEvaluateMethodsOnObject() {
    scope.obj = ['ABC'];
    var fn = parse("obj[0]").eval;
    assertEquals(fn(scope), 'ABC');
    // assertEquals(scope.$eval(fn), 'ABC');
  }


  public function testNgOnlyCheckLocalsOnFirstDereference() {
    scope.a = {'b': 1};
    var locals = {'b': 2};
    var fn = parse("a.b").bind(scope, ng.Scope.ScopeLocals.wrapper);
    assertEquals(fn(locals), 1);
  }


  public function testNgEvaluateMultiplicationAndDivision() {
    scope.taxRate =  8;
    scope.subTotal =  100;
    assertEquals(eval("taxRate / 100 * subTotal"), 8);
    assertEquals(eval("subTotal * taxRate / 100"), 8);
  }


  public function testNgevaluateArray() {
    assertEquals(eval("[]").length, 0);
    assertEquals(eval("[1, 2]").length, 2);
    assertEquals(eval("[1, 2]")[0], 1);
    assertEquals(eval("[1, 2]")[1], 2);
  }


  public function testNgevaluateArrayAccess() {
    assertEquals(eval("[1][0]"), 1);
    assertEquals(eval("[[1]][0][0]"), 1);
    assertEquals(eval("[].length"), [].length);
    assertEquals(eval("[].length"), 0);
    assertEquals(eval("[1, 2].length"), 2);
  }

  // NOTE(pythonic): {} != {} here
  // public function testNgEvaluateObject() {
  //   // assertEquals(eval("{}"), {});
  //   // assertEquals(eval("{a:'b'}"), {"a":"b"});
  //   // assertEquals(eval("{'a':'b'}"), {"a":"b"});
  //   // assertEquals(eval("{\"a\":'b'}"), {"a":"b"});
  // }


  public function testNgEvaluateObjectAccess() {
    assertEquals(eval("{'false':'WC', 'true':'CC'}['false']"), "WC");
  }


  public function testNgEvaluateJSON() {
    assertEquals(eval("[{a:[]}, {b:1}][1]['b']"), 1);

    // TODO(pythonic): Check why it is wrong
    // assertEquals(eval("[{a:[]}, {b:1}][1].b"), 1);
  }


  public function testNgEvaluateMultipleStatements() {
    assertEquals(eval("a=1;b=3;a+b"), 4);
    assertEquals(eval(";;1;;"), 1);
  }


  // skipping should evaluate object methods in correct context (this)
  // skipping should evaluate methods in correct context (this) in argument


  public function testNgEvaluateObjectsOnScopeContext() {
    scope.a =  "abc";
    assertEquals(eval("{a:a}").a, "abc");
  }


  // public function testNgEvalulateObjectsOnScope() {
  //   assertEquals(eval(r'$id'), scope.$id);
  //   assertEquals(eval(r'$root'), scope.$root);
  //   assertEquals(eval(r'$parent'), scope.$parent);
  // }));


  public function testNgEvaluateFieldAccessOnFunctionCallResult() {
    scope.a = function () {
      return {'name':'misko'};
    };
    assertEquals(eval("a().name"), "misko");
  }


  public function testNgEvaluateFieldAccessAfterArrayAccess() {
    scope.items =  [{}, {'name':'misko'}];
    assertEquals(eval('items[1].name'), 'misko');
  }

  
  public function testNgEvaluateArrayAssignment() {
    scope.items =  [];

    assertEquals(eval('items[1] = "abc"'), "abc");
    assertEquals(eval('items[1]'), "abc");
    // TODO: Make this work
    //    Dont know how to make this work....
    //    assertEquals(eval('books[1] = "moby"'), "moby");
    //    assertEquals(eval('books[1]'), "moby");
  }


  public function testNgEvaluateRemainder() {
    assertEquals(eval('1%2'), 1);
  }


  public function testNgEvaluateSumWithUndefined() {
    assertEquals(eval('1+undefined'), 1);
    assertEquals(eval('undefined+1'), 1);
  }


  public function testNgThrowExceptionOnNonClosedBracket() {
    assertThrowFn(function() {
      eval('[].count(');
    }, 'Unexpected end of expression: [].count(');
  }


  public function testNgEvaluateDoubleNegation() {
    assertEquals(eval('true'), true);
    assertEquals(eval('!true'), false);
    assertEquals(eval('!!true'), true);
  }


  public function testNgEvaluateNegation() {
    assertEquals(eval("!false || true"), !false || true);
    assertEquals(eval("!(11 == 10)"), !(11 == 10));
    assertEquals(eval("12/6/2"), 12/6/2);
  }

  public function testNgEvaluateExclamationMark() {
    assertEquals(eval('suffix = "!"'), '!');
  }


  public function testNgEvaluateMinus() {
    assertEquals(eval("{a:'-'}.a"), {'a': "-"}.a);
  }


  public function testNgEvaluateUndefined() {
    assertEquals(eval("undefined"), null);
    assertEquals(eval("a=undefined"), null);
    assertEquals(scope.a, null);
  }


  public function testNgAllowAssignmentAfterArrayDereference() {
    scope.obj = [{}];
    eval('obj[0].name=1');
    // can not be expressed in Dart expect(scope["obj"]["name"], null);
    assertEquals(scope.obj[0].name, 1);
  }


  public function testNgShortCircuitANDOperator() {
    scope.run = function () {
      throw "IT SHOULD NOT HAVE RUN";
    };
    assertEquals(eval('false && run()'), false);
  }


  public function testNgShortCircuitOROperator() {
    scope.run = function () {
      throw "IT SHOULD NOT HAVE RUN";
    };
    assertEquals(eval('true || run()'),true);
  }

  // public function testNgSupportMethodCallsOnPrimitiveTypes() {
  //   scope["empty"] = '';
  //   scope["zero"] = 0;
  //   scope["bool"] = false;

  //   // DOES NOT WORK. String.substring is not reflected. Or toString
  //   // assertEquals(eval('empty.substring(0)'), '');
  //   // assertEquals(eval('zero.toString()'), '0');
  //   // DOES NOT WORK.  bool.toString is not reflected
  //   // assertEquals(eval('bool.toString()'), 'false');
  // }


  public function testNgSupportMapGetters() {
    assertEquals(parse('a').eval({'a': 4}), 4);
  }


  public function testNgSupportMemberGetters() {
    assertEquals(parse('str').eval(new TestData()), 'testString');
  }


  public function testNgSupportReturningMemberFunctions() {
    assertEquals(parse('method').eval(new TestData())(), 'testMethod');
  }


  public function testNgSupportCallingMemberFunctions() {
    assertEquals(parse('method()').eval(new TestData()), 'testMethod');
  }


  public function testNgSupportArraySetters() {
    var data = {'a': [1,3]};
    assertEquals(parse('a[1]=2').eval(data), 2);
    assertEquals(data.a[1], 2);
  }


  public function testNgSupportMemberFieldSetters() {
    var data = new TestData();
    assertEquals(parse('str="bob"').eval(data), 'bob');
    assertEquals(data.str, "bob");
  }

  // NOTE(pythonic): No mixins in Haxe
  // public function testNgSupportMemberFieldGettersFromMixins() {
  //   MixedTestData data = new MixedTestData();
  //   data.str = 'dole';
  //   assertEquals(parser('str').eval(data), 'dole');
  // }


  public function testNgSupportGettersSetters() {
   var testData = new TestData();
   assertEquals(parse('getSet').eval(testData), 'Hello');
   assertEquals(parse('getSet = "Bye"').eval(testData), 'Bye');
   assertEquals(parse('getSet').eval(testData), 'Bye');
  }

  // NOTE(pythonic): No mixins in Haxe
  // public function testNgSupportMapGettersFromMixins() {
  //   MixedMapData data = new MixedMapData();
  //   assertEquals(parser('str').eval(data), 'mapped-str');
  // }


  public function testNgFunctionsForObjectIndices() {
    assertEquals(parse('a[x()]()').eval({'a': [function () { return 6; }], 'x': function () { return 0; } }), 6);
  }
  
}