package ng;

class ScopeEvent {
  public var name:String;
  public var targetScope: Scope;
  public var currentScope: Scope;
  public var propagationStopped:Bool = false;
  public var _defaultPrevented:Bool = false;

  public function new(name: String, targetScope: Scope) {
    this.name = name;
    this.targetScope = targetScope;
  }

  public function stopPropagation() {
    propagationStopped = true;
  }

  public function defaultPrevented() {
    _defaultPrevented = true;
  }
}

typedef Listener = Dynamic;

class Scope {

  public static var initWatchValue:Dynamic = null;

  private var exceptionHandler: Dynamic;
  private var parser: String->ng.parser.Syntax.Expression;
  private var ttl:Int = 5;
  private var watchers:WatchList = new WatchList();
  private var isolate:Bool;
  private var lazy: Bool = false;
  private var perf: Dynamic;
  
  public var parent:Scope;
  public var id: String;
  public var root: Scope;

  public var nextId:Int = 0;
  private var phase:String;
  private var innerAsyncQueue:Array<Dynamic>;
  private var outerAsyncQueue:Array<Dynamic>;

  private var nextSibling:Scope;
  private var prevSibling:Scope;
  private var childHead:Scope;
  private var childTail:Scope;

  private var skipAutoDigest:Bool = false;
  private var disabled:Bool = false;

  
  public function new(exceptionHandler, parser, ?perf = null) {
    this.exceptionHandler = exceptionHandler;
    this.parser = parser;
    this.perf = perf;

    parent = null;
    isolate = false;
    lazy = false;
    root = this;
    id = '_${root.nextId++}';

    innerAsyncQueue = new Array<Dynamic>();
    outerAsyncQueue = new Array<Dynamic>();

  }

  public function child(?childType:Class<Dynamic>, ?isolate: Bool = false, ?lazy: Bool = false):Dynamic {
    var instance:Scope = isolate 
      ?  untyped __js__('{}; if (childType != null) for(var i in childType.prototype) instance[i] = childType.prototype[i]')
      :  untyped __js__('Object.create(this); if (childType != null) for(var i in childType.prototype) instance[i] = childType.prototype[i]');
    // untyped { childType.apply(instance, []); }
    // instance.init();
    
    instance.parent = this;
    instance.id = '_${root.nextId++}';
    instance.parser = parser;
    instance.innerAsyncQueue = innerAsyncQueue;
    instance.outerAsyncQueue = outerAsyncQueue;
    instance.root = root;

    instance.prevSibling = this.childTail;
    if (childHead != null) {
      childTail.nextSibling = instance;
      childTail = instance;
    } else {
      childHead = childTail = instance;
    }

    instance.childHead = null;
    instance.childTail = null;
    instance.nextSibling = null;

    instance.watchers = new WatchList();

    return instance;
  }

  private function autoDigestOnTurnDone() {
    if (skipAutoDigest) {
      skipAutoDigest = false;
    } else {
      digest();
    }
  }

  // private function _identical(a, b) {
  //   return identical(a,b) || (Std.is(a, String) && Std.is(b, String) && a == b) || (Std.isNan(a) && Std.isNan(b));
  // }

  public function watch(watchExpression:Dynamic, ?listener:Dynamic, ?watchStr:String = null) {
    if (watchStr == null) {
      watchStr = watchExpression.toString();
    }

    var watcher = new Watch(compileToFn(listener), initWatchValue, compileToFn(watchExpression), watchStr);
    watchers.addLast(watcher);
    return function () {
      watchers.remove(watcher);
    }
  }

  public function digest() {
    
    try {
      beginPhase("$digest");
      digestWhileDirtyLoop();
    } catch (e:Dynamic) {
      exceptionHandler(e);
    }
    
    clearPhase();
    
  }

  public function digestWhileDirtyLoop() {
    digestHandleQueue('ng.innerAsync', innerAsyncQueue);
    var lastDirtyWatch = digestComputeLastDirty();

    if (lastDirtyWatch == null) {
      digestHandleQueue('ng.outerAsync', outerAsyncQueue);
      return;
    }

    var watchLog = new Array<Array<String>>();
    for (iteration in 0...ttl) {
      lastDirtyWatch = null;
      var expressionLog = new Array<String>();

      var stopWatch:Watch = digestHandleQueue('ng.innerAsync', innerAsyncQueue) ? null : lastDirtyWatch;
      if (lastDirtyWatch == null) {
        digestHandleQueue('ng.outerAsync', outerAsyncQueue);
        return;
      }

    }
  }

  public function digestHandleQueue(timeName: String, queue: Array<Dynamic>) {
    if (queue.length == 0) {
      return false;
    }

    do {
      // var timerId;
      try {
        var workFn = queue.shift();
        // assert((timerId = _perf.startTimer(timerName, _source(workFn))) != false);
        root.eval(workFn);
      } catch (e:Dynamic) {
        exceptionHandler(e);
      }
      // assert(_perf.stopTimer(timerId) != false);
    } while (queue.length > 0);

    return true;
  }

  public function digestComputeLastDirty() {
    var watcherCount = 0;
    var scopeCount = 0;
    var scope = this;
    do {
      var watchers = scope.watchers;
      watcherCount += watchers.length;
      scopeCount++;
      var watch = watchers.head;
      while (watch != null) {
        var last = watch.last;
        var value = watch.get(scope);
        if (value != last) {
          return digestHandleDirty(scope, watch, last, value, null);
        }
        watch = watch.next;
      }
    } while ((scope = digestComputeNextScope(scope)) != null);
    
    // digestUpdatePerfCounters(watcherCount, scopeCount);
    
    return null;
  }

  public function digestComputeLastDirtyUntil(stopWatch:Watch, log:Array<String>):Watch {

    var watcherCount = 0;
    var scopeCount = 0;
    var scope = this;
    do {
      var watchers = scope.watchers;
      watcherCount += watchers.length;
      scopeCount++;
      var watch = watchers.head;
      while (watch != null) {
        if (stopWatch == watch) return null;
        var last = watch.last;
        var value = watch.get(scope);
        if (value != last) {
          return digestHandleDirty(scope, watch, last, value, log);
        }
        watch = watch.next;
      }
    } while ((scope = digestComputeNextScope(scope)) != null);
    return null;
  }

   public function digestHandleDirty(scope:Scope, watch:Watch, last, value, log:Array<String>):Watch {
    var lastDirtyWatch:Watch = null;
    while (true) {
      trace('digestHandleDirty while true: $last == $value (${watch.exp})');
      if (value != last) {
        lastDirtyWatch = watch;
        if (log != null) log.push(watch.exp == null ? '[unknown]' : watch.exp);
        watch.last = value;
        // var fireTimer;
        // assert((fireTimer = _perf.startTimer('ng.fire', watch.exp)) != false);
        watch.fn(value, (initWatchValue == last) ? value : last, scope);
        // assert(_perf.stopTimer(fireTimer) != false);
      }
      watch = watch.next;
      while (watch == null) {
        scope = digestComputeNextScope(scope);
        if (scope == null) return lastDirtyWatch;
        watch = scope.watchers.head;
      }
      last = watch.last;
      value = watch.get(scope);
    }
  }

  public function digestComputeNextScope(scope:Scope):Scope {

    // Insanity Warning: scope depth-first traversal
    // yes, this code is a bit crazy, but it works and we have tests to prove it!
    // this piece should be kept in sync with the traversal in $broadcast
    var target = this;
    var childHead = scope.childHead;
    while (childHead != null && childHead.disabled) {
      childHead = childHead.nextSibling;
    }
    if (childHead == null) {
      if (scope == target) {
        return null;
      } else {
        var next = scope.nextSibling;
        if (next == null) {
          while (scope != target && (next = scope.nextSibling) == null) {
            scope = scope.parent;
          }
        }
        return next;
      }
    } else {
      if (childHead.lazy) childHead.disabled = true;
      return childHead;
    }
  }

  public function beginPhase(phase) {
    if (root.phase != null) {
      // TODO(deboer): Remove the []s when dartbug.com/11999 is fixed.
      throw ['${root.phase} already in progress'];
    }
    // assert(_perf.startTimer('ng.phase.${phase}') != false);

    root.phase = phase;
  }

  public function clearPhase() {
    // assert(_perf.stopTimer('ng.phase.${$root._phase}') != false);
    root.phase = null;
  }

  public function compileToFn(exp):Dynamic {
    if (exp == null) {
      return function () return null;
    } else if (Std.is(exp, String)) {
      var expression = parser(exp);
      return expression.eval;
    } else if (ng.parser.Utils.isFunction(exp)) {
      return exp;
    } else {
      throw 'Expecting String or Function';
    }
  }

  public function eval(expr, ?locals) {
    return compileToFn(expr)(locals == null ? this : scopeLocals(locals));
  }


  public function evalAsync(expr, ?outsideDigest = false) {
    if (outsideDigest) {
      outerAsyncQueue.push(expr);
    } else {
      innerAsyncQueue.push(expr);
    }
  }
  // void _digestComputePerfCounters() {
  //   int watcherCount = 0, scopeCount = 0;
  //   Scope scope = this;
  //   do {
  //     scopeCount++;
  //     watcherCount += scope._watchers.length;
  //   } while ((scope = _digestComputeNextScope(scope)) != null);
  //   _digestUpdatePerfCounters(watcherCount, scopeCount);
  // }


  public function scopeLocals(locals) {
    return this;
  }

    
}

class Watch {
  public var fn:Dynamic;
  public var get: Dynamic;
  public var exp: String;
  public var last: Dynamic;

  public var previous: Watch;
  public var next: Watch;

  public function new(fn:Dynamic, last:Dynamic, getFn:Dynamic, exp:String) {
    this.last = last;
    this.exp = exp;
    this.fn = fn;
    this.get = getFn;
  }


}


class WatchList {

  public function new() {};

  public var length:Int = 0;
  public var head:Watch;
  public var tail:Watch;

  public function addLast(watch:Watch) {
    if (tail == null) {
      tail = head = watch;
    } else {
      watch.previous = tail;
      tail.next = watch;
      tail = watch;
    }
    length++;
  }

  public function remove(watch:Watch) {
    if (watch == head) {
      var next = watch.next;
      if (next == null) tail = null;
      else next.previous = null;
      head = next;
    } else if (watch == tail) {
      var previous = watch.previous;
      previous.next = null;
      tail = previous;
    } else {
      var next = watch.next;
      var previous = watch.previous;
      previous.next = next;
      next.previous = previous;
    }
    length--;
  }

}