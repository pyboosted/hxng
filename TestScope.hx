package ;

import ng.parser.DynamicParser;
import ng.Scope;

class MyScope extends Scope {
  public var test:String;
}

class MyChildScope extends Scope {
  public var test2:String;
}

class TestScope {
  public static function main() {

    var errorHandler = function (e) {
      trace('Error: $e');
    }

    var rootScope = new Scope(errorHandler, DynamicParser.parse);
    var scope:MyScope = rootScope.child(MyScope);
    var childScope:MyChildScope = scope.child(MyChildScope, true);

    scope.test = 'test';
    childScope.test2 = 'test2';
    rootScope.digest();

    childScope.watch('test + " world"', function (val) {
      trace(val);
    });

    scope.watch('test + " another world"', function (val) {
      trace(val);
    });

    rootScope.digest();
    rootScope.digest();

    scope.test = 'test changed';
    scope.digest();

  }

}