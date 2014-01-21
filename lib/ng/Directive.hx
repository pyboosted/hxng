package ng;

import ng.Scope;

private typedef DDO = {
  ?priority: Int,
  ?replace: Bool,
  ?template: String,
  ?templateUrl: String,
  ?transclude: Bool,
  ?scope: Dynamic,
  ?restrict: String,
};

class Directive extends Scope {
  var ddo: DDO;
  
  public function compile(element, attrs) {

  }

  public function link(scope) {

  }

  public override function init() {
    // link
  }


}