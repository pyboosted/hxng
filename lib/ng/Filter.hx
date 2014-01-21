package ng;

class Filter {
  public static function filter(name:String) {
    if (name == 'upper') {
      return function (name:String):String {
        return name.toUpperCase();
      }  
    } else if (name == 'lower') {
      return function (name:String):String {
        return name.toLowerCase();
      }
    }
    return null;
  };
}