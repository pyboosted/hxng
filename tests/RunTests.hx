class RunTests {  
  static function main(){
    var r = new haxe.unit.TestRunner();
    // r.add(new LexerTests());
    // r.add(new ParserTests());
    r.add(new ScopeTests());
    r.run();
  }
}