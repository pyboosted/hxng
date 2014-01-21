import ng.Scope;

class ScopeTests extends haxe.unit.TestCase {
  public var root: ng.Scope;
  public var scope: Dynamic;
  public override function setup() {
    var hanlder = function (e) {
      trace(e);
    }
    root = new ng.Scope(hanlder, ng.parser.DynamicParser.parse);
    scope = root.child();
  }

  public function testPointToItself() {
    assertEquals(root.root, root);
  }

  public function testPointToParent() {
    var child:Scope = root.child();
    assertEquals(root.parent, null);
    assertEquals(child.parent, root);
    assertEquals(child.child().parent, child);
  }

  public function testAUniqueId() {
    assertEquals(root.id != root.child().id, true);
  }

  public function testCreateAChildScope() {
    var child:Dynamic = scope.child();
    scope.a = 123;
    assertEquals(child.a, 123);
  }

  public function testCreateANonPrototypicallyInheritedChildScope() {
    var child:Dynamic = scope.child(null, true);
    scope.a = 123;
    assertEquals(child.a, null);
    assertEquals(child.parent, scope);
    assertEquals(child.root, root);
  }

  public function testAutoDigestAtTheEndOfTheTurn() {
    var digestedValue = 0;
    scope.a = 1;
    scope.watch('a', function (newValue, oldValue, _this) {
      digestedValue = newValue;
    });
    assertEquals(digestedValue ,0);
    // zone.run(noop);
    root.digest();
    assertEquals(digestedValue, 1);
  }

  


}  
