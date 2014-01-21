package ng.parser;

import ng.parser.Syntax;

class Unparser {
  public static function unparse(expression:Expression):String {
    return expression.toString();
  }
}