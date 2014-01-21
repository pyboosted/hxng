(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = ["Lambda"];
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
var List = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	h: null
	,q: null
	,length: null
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,__class__: List
};
var IMap = function() { };
IMap.__name__ = ["IMap"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
var RunTests = function() { };
RunTests.__name__ = ["RunTests"];
RunTests.main = function() {
	var r = new haxe.unit.TestRunner();
	r.add(new ScopeTests());
	r.run();
};
var haxe = {};
haxe.unit = {};
haxe.unit.TestCase = function() {
};
haxe.unit.TestCase.__name__ = ["haxe","unit","TestCase"];
haxe.unit.TestCase.prototype = {
	currentTest: null
	,setup: function() {
	}
	,tearDown: function() {
	}
	,print: function(v) {
		haxe.unit.TestRunner.print(v);
	}
	,assertTrue: function(b,c) {
		this.currentTest.done = true;
		if(b == false) {
			this.currentTest.success = false;
			this.currentTest.error = "expected true but was false";
			this.currentTest.posInfos = c;
			throw this.currentTest;
		}
	}
	,assertFalse: function(b,c) {
		this.currentTest.done = true;
		if(b == true) {
			this.currentTest.success = false;
			this.currentTest.error = "expected false but was true";
			this.currentTest.posInfos = c;
			throw this.currentTest;
		}
	}
	,assertEquals: function(expected,actual,c) {
		this.currentTest.done = true;
		if(actual != expected) {
			this.currentTest.success = false;
			this.currentTest.error = "expected '" + Std.string(expected) + "' but was '" + Std.string(actual) + "'";
			this.currentTest.posInfos = c;
			throw this.currentTest;
		}
	}
	,__class__: haxe.unit.TestCase
};
var ScopeTests = function() {
	haxe.unit.TestCase.call(this);
};
ScopeTests.__name__ = ["ScopeTests"];
ScopeTests.__super__ = haxe.unit.TestCase;
ScopeTests.prototype = $extend(haxe.unit.TestCase.prototype,{
	root: null
	,scope: null
	,setup: function() {
		var hanlder = function(e) {
			haxe.Log.trace(e,{ fileName : "ScopeTests.hx", lineNumber : 8, className : "ScopeTests", methodName : "setup"});
		};
		this.root = new ng.Scope(hanlder,ng.parser.DynamicParser.parse);
		this.scope = this.root.child();
	}
	,testPointToItself: function() {
		this.assertEquals(this.root.root,this.root,{ fileName : "ScopeTests.hx", lineNumber : 15, className : "ScopeTests", methodName : "testPointToItself"});
	}
	,testPointToParent: function() {
		var child = this.root.child();
		this.assertEquals(this.root.parent,null,{ fileName : "ScopeTests.hx", lineNumber : 20, className : "ScopeTests", methodName : "testPointToParent"});
		this.assertEquals(child.parent,this.root,{ fileName : "ScopeTests.hx", lineNumber : 21, className : "ScopeTests", methodName : "testPointToParent"});
		this.assertEquals(child.child().parent,child,{ fileName : "ScopeTests.hx", lineNumber : 22, className : "ScopeTests", methodName : "testPointToParent"});
	}
	,testAUniqueId: function() {
		this.assertEquals(this.root.id != this.root.child().id,true,{ fileName : "ScopeTests.hx", lineNumber : 26, className : "ScopeTests", methodName : "testAUniqueId"});
	}
	,testCreateAChildScope: function() {
		var child = this.scope.child();
		this.scope.a = 123;
		this.assertEquals(child.a,123,{ fileName : "ScopeTests.hx", lineNumber : 32, className : "ScopeTests", methodName : "testCreateAChildScope"});
	}
	,testCreateANonPrototypicallyInheritedChildScope: function() {
		var child = this.scope.child(null,true);
		this.scope.a = 123;
		this.assertEquals(child.a,null,{ fileName : "ScopeTests.hx", lineNumber : 38, className : "ScopeTests", methodName : "testCreateANonPrototypicallyInheritedChildScope"});
		this.assertEquals(child.parent,this.scope,{ fileName : "ScopeTests.hx", lineNumber : 39, className : "ScopeTests", methodName : "testCreateANonPrototypicallyInheritedChildScope"});
		this.assertEquals(child.root,this.root,{ fileName : "ScopeTests.hx", lineNumber : 40, className : "ScopeTests", methodName : "testCreateANonPrototypicallyInheritedChildScope"});
	}
	,testAutoDigestAtTheEndOfTheTurn: function() {
		var digestedValue = 0;
		this.scope.a = 1;
		this.scope.watch("a",function(newValue,oldValue,_this) {
			digestedValue = newValue;
		});
		this.assertEquals(digestedValue,0,{ fileName : "ScopeTests.hx", lineNumber : 49, className : "ScopeTests", methodName : "testAutoDigestAtTheEndOfTheTurn"});
		this.root.digest();
		this.assertEquals(digestedValue,1,{ fileName : "ScopeTests.hx", lineNumber : 52, className : "ScopeTests", methodName : "testAutoDigestAtTheEndOfTheTurn"});
	}
	,__class__: ScopeTests
});
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
Std.parseFloat = function(x) {
	return parseFloat(x);
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	b: null
	,__class__: StringBuf
};
var StringTools = function() { };
StringTools.__name__ = ["StringTools"];
StringTools.htmlEscape = function(s,quotes) {
	s = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	if(quotes) return s.split("\"").join("&quot;").split("'").join("&#039;"); else return s;
};
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	return o.__class__;
};
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
};
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
};
haxe.StackItem = { __ename__ : true, __constructs__ : ["CFunction","Module","FilePos","Method","LocalFunction"] };
haxe.StackItem.CFunction = ["CFunction",0];
haxe.StackItem.CFunction.toString = $estr;
haxe.StackItem.CFunction.__enum__ = haxe.StackItem;
haxe.StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; };
haxe.StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; };
haxe.StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; };
haxe.StackItem.LocalFunction = function(v) { var $x = ["LocalFunction",4,v]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; };
haxe.CallStack = function() { };
haxe.CallStack.__name__ = ["haxe","CallStack"];
haxe.CallStack.exceptionStack = function() {
	return [];
};
haxe.CallStack.toString = function(stack) {
	var b = new StringBuf();
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		b.b += "\nCalled from ";
		haxe.CallStack.itemToString(b,s);
	}
	return b.b;
};
haxe.CallStack.itemToString = function(b,s) {
	switch(s[1]) {
	case 0:
		b.b += "a C function";
		break;
	case 1:
		var m = s[2];
		b.b += "module ";
		b.b += Std.string(m);
		break;
	case 2:
		var line = s[4];
		var file = s[3];
		var s1 = s[2];
		if(s1 != null) {
			haxe.CallStack.itemToString(b,s1);
			b.b += " (";
		}
		b.b += Std.string(file);
		b.b += " line ";
		b.b += Std.string(line);
		if(s1 != null) b.b += ")";
		break;
	case 3:
		var meth = s[3];
		var cname = s[2];
		b.b += Std.string(cname);
		b.b += ".";
		b.b += Std.string(meth);
		break;
	case 4:
		var n = s[2];
		b.b += "local function #";
		b.b += Std.string(n);
		break;
	}
};
haxe.Log = function() { };
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
};
haxe.ds = {};
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = ["haxe","ds","IntMap"];
haxe.ds.IntMap.__interfaces__ = [IMap];
haxe.ds.IntMap.prototype = {
	h: null
	,set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,__class__: haxe.ds.IntMap
};
haxe.unit.TestResult = function() {
	this.m_tests = new List();
	this.success = true;
};
haxe.unit.TestResult.__name__ = ["haxe","unit","TestResult"];
haxe.unit.TestResult.prototype = {
	m_tests: null
	,success: null
	,add: function(t) {
		this.m_tests.add(t);
		if(!t.success) this.success = false;
	}
	,toString: function() {
		var buf = new StringBuf();
		var failures = 0;
		var $it0 = this.m_tests.iterator();
		while( $it0.hasNext() ) {
			var test = $it0.next();
			if(test.success == false) {
				buf.b += "* ";
				buf.b += Std.string(test.classname);
				buf.b += "::";
				buf.b += Std.string(test.method);
				buf.b += "()";
				buf.b += "\n";
				buf.b += "ERR: ";
				if(test.posInfos != null) {
					buf.b += Std.string(test.posInfos.fileName);
					buf.b += ":";
					buf.b += Std.string(test.posInfos.lineNumber);
					buf.b += "(";
					buf.b += Std.string(test.posInfos.className);
					buf.b += ".";
					buf.b += Std.string(test.posInfos.methodName);
					buf.b += ") - ";
				}
				buf.b += Std.string(test.error);
				buf.b += "\n";
				if(test.backtrace != null) {
					buf.b += Std.string(test.backtrace);
					buf.b += "\n";
				}
				buf.b += "\n";
				failures++;
			}
		}
		buf.b += "\n";
		if(failures == 0) buf.b += "OK "; else buf.b += "FAILED ";
		buf.b += Std.string(this.m_tests.length);
		buf.b += " tests, ";
		buf.b += Std.string(failures);
		buf.b += " failed, ";
		buf.b += Std.string(this.m_tests.length - failures);
		buf.b += " success";
		buf.b += "\n";
		return buf.b;
	}
	,__class__: haxe.unit.TestResult
};
haxe.unit.TestRunner = function() {
	this.result = new haxe.unit.TestResult();
	this.cases = new List();
};
haxe.unit.TestRunner.__name__ = ["haxe","unit","TestRunner"];
haxe.unit.TestRunner.print = function(v) {
	var msg = js.Boot.__string_rec(v,"");
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) {
		msg = msg.split("\n").join("<br/>");
		d.innerHTML += StringTools.htmlEscape(msg) + "<br/>";
	} else if(typeof process != "undefined" && process.stdout != null && process.stdout.write != null) process.stdout.write(msg); else if(typeof console != "undefined" && console.log != null) console.log(msg);
};
haxe.unit.TestRunner.customTrace = function(v,p) {
	haxe.unit.TestRunner.print(p.fileName + ":" + p.lineNumber + ": " + Std.string(v) + "\n");
};
haxe.unit.TestRunner.prototype = {
	result: null
	,cases: null
	,add: function(c) {
		this.cases.add(c);
	}
	,run: function() {
		this.result = new haxe.unit.TestResult();
		var $it0 = this.cases.iterator();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			this.runCase(c);
		}
		haxe.unit.TestRunner.print(this.result.toString());
		return this.result.success;
	}
	,runCase: function(t) {
		var old = haxe.Log.trace;
		haxe.Log.trace = haxe.unit.TestRunner.customTrace;
		var cl = Type.getClass(t);
		var fields = Type.getInstanceFields(cl);
		haxe.unit.TestRunner.print("Class: " + Type.getClassName(cl) + " ");
		var _g = 0;
		while(_g < fields.length) {
			var f = fields[_g];
			++_g;
			var fname = f;
			var field;
			var v = null;
			try {
				v = t[f];
			} catch( e ) {
			}
			field = v;
			if(StringTools.startsWith(fname,"test") && Reflect.isFunction(field)) {
				t.currentTest = new haxe.unit.TestStatus();
				t.currentTest.classname = Type.getClassName(cl);
				t.currentTest.method = fname;
				t.setup();
				try {
					var args = new Array();
					field.apply(t,args);
					if(t.currentTest.done) {
						t.currentTest.success = true;
						haxe.unit.TestRunner.print(".");
					} else {
						t.currentTest.success = false;
						t.currentTest.error = "(warning) no assert";
						haxe.unit.TestRunner.print("W");
					}
				} catch( $e0 ) {
					if( js.Boot.__instanceof($e0,haxe.unit.TestStatus) ) {
						var e = $e0;
						haxe.unit.TestRunner.print("F");
						t.currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
					} else {
					var e = $e0;
					haxe.unit.TestRunner.print("E");
					if(e.message != null) t.currentTest.error = "exception thrown : " + Std.string(e) + " [" + Std.string(e.message) + "]"; else t.currentTest.error = "exception thrown : " + Std.string(e);
					t.currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
					}
				}
				this.result.add(t.currentTest);
				t.tearDown();
			}
		}
		haxe.unit.TestRunner.print("\n");
		haxe.Log.trace = old;
	}
	,__class__: haxe.unit.TestRunner
};
haxe.unit.TestStatus = function() {
	this.done = false;
	this.success = false;
};
haxe.unit.TestStatus.__name__ = ["haxe","unit","TestStatus"];
haxe.unit.TestStatus.prototype = {
	done: null
	,success: null
	,error: null
	,method: null
	,classname: null
	,posInfos: null
	,backtrace: null
	,__class__: haxe.unit.TestStatus
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
};
js.Boot.__trace = function(v,i) {
	var msg;
	if(i != null) msg = i.fileName + ":" + i.lineNumber + ": "; else msg = "";
	msg += js.Boot.__string_rec(v,"");
	if(i != null && i.customParams != null) {
		var _g = 0;
		var _g1 = i.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			msg += "," + js.Boot.__string_rec(v1,"");
		}
	}
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof console != "undefined" && console.log != null) console.log(msg);
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
var ng = {};
ng.ScopeEvent = function(name,targetScope) {
	this._defaultPrevented = false;
	this.propagationStopped = false;
	this.name = name;
	this.targetScope = targetScope;
};
ng.ScopeEvent.__name__ = ["ng","ScopeEvent"];
ng.ScopeEvent.prototype = {
	name: null
	,targetScope: null
	,currentScope: null
	,propagationStopped: null
	,_defaultPrevented: null
	,stopPropagation: function() {
		this.propagationStopped = true;
	}
	,defaultPrevented: function() {
		this._defaultPrevented = true;
	}
	,__class__: ng.ScopeEvent
};
ng.Scope = function(exceptionHandler,parser,perf) {
	this.disabled = false;
	this.skipAutoDigest = false;
	this.nextId = 0;
	this.lazy = false;
	this.watchers = new ng.WatchList();
	this.ttl = 5;
	this.exceptionHandler = exceptionHandler;
	this.parser = parser;
	this.perf = perf;
	this.parent = null;
	this.isolate = false;
	this.lazy = false;
	this.root = this;
	this.id = "_" + this.root.nextId++;
	this.innerAsyncQueue = new Array();
	this.outerAsyncQueue = new Array();
};
ng.Scope.__name__ = ["ng","Scope"];
ng.Scope.prototype = {
	exceptionHandler: null
	,parser: null
	,ttl: null
	,watchers: null
	,isolate: null
	,lazy: null
	,perf: null
	,parent: null
	,id: null
	,root: null
	,nextId: null
	,phase: null
	,innerAsyncQueue: null
	,outerAsyncQueue: null
	,nextSibling: null
	,prevSibling: null
	,childHead: null
	,childTail: null
	,skipAutoDigest: null
	,disabled: null
	,child: function(childType,isolate,lazy) {
		if(lazy == null) lazy = false;
		if(isolate == null) isolate = false;
		var instance;
		if(isolate) {
			instance = {}; if (childType != null) for(var i in childType.prototype) instance[i] = childType.prototype[i];
		} else {
			instance = Object.create(this); if (childType != null) for(var i in childType.prototype) instance[i] = childType.prototype[i];
		}
		instance.parent = this;
		instance.id = "_" + this.root.nextId++;
		instance.parser = this.parser;
		instance.innerAsyncQueue = this.innerAsyncQueue;
		instance.outerAsyncQueue = this.outerAsyncQueue;
		instance.root = this.root;
		instance.prevSibling = this.childTail;
		if(this.childHead != null) {
			this.childTail.nextSibling = instance;
			this.childTail = instance;
		} else this.childHead = this.childTail = instance;
		instance.childHead = null;
		instance.childTail = null;
		instance.nextSibling = null;
		instance.watchers = new ng.WatchList();
		return instance;
	}
	,autoDigestOnTurnDone: function() {
		if(this.skipAutoDigest) this.skipAutoDigest = false; else this.digest();
	}
	,watch: function(watchExpression,listener,watchStr) {
		var _g = this;
		if(watchStr == null) watchStr = watchExpression.toString();
		var watcher = new ng.Watch(this.compileToFn(listener),ng.Scope.initWatchValue,this.compileToFn(watchExpression),watchStr);
		this.watchers.addLast(watcher);
		return function() {
			_g.watchers.remove(watcher);
		};
	}
	,digest: function() {
		try {
			this.beginPhase("$digest");
			this.digestWhileDirtyLoop();
		} catch( e ) {
			this.exceptionHandler(e);
		}
		this.clearPhase();
	}
	,digestWhileDirtyLoop: function() {
		this.digestHandleQueue("ng.innerAsync",this.innerAsyncQueue);
		var lastDirtyWatch = this.digestComputeLastDirty();
		if(lastDirtyWatch == null) {
			this.digestHandleQueue("ng.outerAsync",this.outerAsyncQueue);
			return;
		}
		var watchLog = new Array();
		var _g1 = 0;
		var _g = this.ttl;
		while(_g1 < _g) {
			var iteration = _g1++;
			lastDirtyWatch = null;
			var expressionLog = new Array();
			var stopWatch;
			if(this.digestHandleQueue("ng.innerAsync",this.innerAsyncQueue)) stopWatch = null; else stopWatch = lastDirtyWatch;
			if(lastDirtyWatch == null) {
				this.digestHandleQueue("ng.outerAsync",this.outerAsyncQueue);
				return;
			}
		}
	}
	,digestHandleQueue: function(timeName,queue) {
		if(queue.length == 0) return false;
		do try {
			var workFn = queue.shift();
			this.root["eval"](workFn);
		} catch( e ) {
			this.exceptionHandler(e);
		} while(queue.length > 0);
		return true;
	}
	,digestComputeLastDirty: function() {
		var watcherCount = 0;
		var scopeCount = 0;
		var scope = this;
		do {
			var watchers = scope.watchers;
			watcherCount += watchers.length;
			scopeCount++;
			var watch = watchers.head;
			while(watch != null) {
				var last = watch.last;
				var value = watch.get(scope);
				if(value != last) return this.digestHandleDirty(scope,watch,last,value,null);
				watch = watch.next;
			}
		} while((scope = this.digestComputeNextScope(scope)) != null);
		return null;
	}
	,digestComputeLastDirtyUntil: function(stopWatch,log) {
		var watcherCount = 0;
		var scopeCount = 0;
		var scope = this;
		do {
			var watchers = scope.watchers;
			watcherCount += watchers.length;
			scopeCount++;
			var watch = watchers.head;
			while(watch != null) {
				if(stopWatch == watch) return null;
				var last = watch.last;
				var value = watch.get(scope);
				if(value != last) return this.digestHandleDirty(scope,watch,last,value,log);
				watch = watch.next;
			}
		} while((scope = this.digestComputeNextScope(scope)) != null);
		return null;
	}
	,digestHandleDirty: function(scope,watch,last,value,log) {
		var lastDirtyWatch = null;
		while(true) {
			haxe.Log.trace("digestHandleDirty while true: " + last + " == " + value + " (" + watch.exp + ")",{ fileName : "Scope.hx", lineNumber : 233, className : "ng.Scope", methodName : "digestHandleDirty"});
			if(value != last) {
				lastDirtyWatch = watch;
				if(log != null) log.push(watch.exp == null?"[unknown]":watch.exp);
				watch.last = value;
				watch.fn(value,ng.Scope.initWatchValue == last?value:last,scope);
			}
			watch = watch.next;
			while(watch == null) {
				scope = this.digestComputeNextScope(scope);
				if(scope == null) return lastDirtyWatch;
				watch = scope.watchers.head;
			}
			last = watch.last;
			value = watch.get(scope);
		}
	}
	,digestComputeNextScope: function(scope) {
		var target = this;
		var childHead = scope.childHead;
		while(childHead != null && childHead.disabled) childHead = childHead.nextSibling;
		if(childHead == null) {
			if(scope == target) return null; else {
				var next = scope.nextSibling;
				if(next == null) while(scope != target && (next = scope.nextSibling) == null) scope = scope.parent;
				return next;
			}
		} else {
			if(childHead.lazy) childHead.disabled = true;
			return childHead;
		}
	}
	,beginPhase: function(phase) {
		if(this.root.phase != null) throw ["" + this.root.phase + " already in progress"];
		this.root.phase = phase;
	}
	,clearPhase: function() {
		this.root.phase = null;
	}
	,compileToFn: function(exp) {
		if(exp == null) return function() {
			return null;
		}; else if(js.Boot.__instanceof(exp,String)) {
			var expression = this.parser(exp);
			return $bind(expression,expression["eval"]);
		} else if(ng.parser.Utils.isFunction(exp)) return exp; else throw "Expecting String or Function";
	}
	,'eval': function(expr,locals) {
		return (this.compileToFn(expr))(locals == null?this:this.scopeLocals(locals));
	}
	,evalAsync: function(expr,outsideDigest) {
		if(outsideDigest == null) outsideDigest = false;
		if(outsideDigest) this.outerAsyncQueue.push(expr); else this.innerAsyncQueue.push(expr);
	}
	,scopeLocals: function(locals) {
		return this;
	}
	,__class__: ng.Scope
};
ng.Watch = function(fn,last,getFn,exp) {
	this.last = last;
	this.exp = exp;
	this.fn = fn;
	this.get = getFn;
};
ng.Watch.__name__ = ["ng","Watch"];
ng.Watch.prototype = {
	fn: null
	,get: null
	,exp: null
	,last: null
	,previous: null
	,next: null
	,__class__: ng.Watch
};
ng.WatchList = function() {
	this.length = 0;
};
ng.WatchList.__name__ = ["ng","WatchList"];
ng.WatchList.prototype = {
	length: null
	,head: null
	,tail: null
	,addLast: function(watch) {
		if(this.tail == null) this.tail = this.head = watch; else {
			watch.previous = this.tail;
			this.tail.next = watch;
			this.tail = watch;
		}
		this.length++;
	}
	,remove: function(watch) {
		if(watch == this.head) {
			var next = watch.next;
			if(next == null) this.tail = null; else next.previous = null;
			this.head = next;
		} else if(watch == this.tail) {
			var previous = watch.previous;
			previous.next = null;
			this.tail = previous;
		} else {
			var next = watch.next;
			var previous = watch.previous;
			previous.next = next;
			next.previous = previous;
		}
		this.length--;
	}
	,__class__: ng.WatchList
};
ng.parser = {};
ng.parser.ClosureMap = function() { };
ng.parser.ClosureMap.__name__ = ["ng","parser","ClosureMap"];
ng.parser.ClosureMap.prototype = {
	lookupGetter: function(name) {
		return null;
	}
	,lookupSetter: function(name) {
		return null;
	}
	,lookupFunction: function(name,arity) {
		return null;
	}
	,__class__: ng.parser.ClosureMap
};
ng.parser.Parser = function() { };
ng.parser.Parser.__name__ = ["ng","parser","Parser"];
ng.parser.Parser.prototype = {
	call: null
	,__class__: ng.parser.Parser
};
ng.parser.DynamicParser = function(lexer,backend) {
	this.lexer = lexer;
	this.backend = backend;
};
ng.parser.DynamicParser.__name__ = ["ng","parser","DynamicParser"];
ng.parser.DynamicParser.__interfaces__ = [ng.parser.Parser];
ng.parser.DynamicParser.parse = function(input) {
	var lexer = new ng.parser.Lexer();
	var backend = new ng.parser.DynamicParserBackend(null,null);
	var dynamicParser = new ng.parser.DynamicParser(lexer,backend);
	return dynamicParser._parse(input);
};
ng.parser.DynamicParser.prototype = {
	lexer: null
	,backend: null
	,call: function(input) {
		if(input == null) input = "";
		return ng.parser.DynamicParser.parse(input);
	}
	,_parse: function(input) {
		var parser = new ng.parser.DynamicParserImpl(this.lexer,this.backend,input);
		var expression = parser.parseChain();
		return new ng.parser.DynamicExpression(expression);
	}
	,__class__: ng.parser.DynamicParser
};
ng.parser.Expression = function() { };
ng.parser.Expression.__name__ = ["ng","parser","Expression"];
ng.parser.Expression.prototype = {
	isAssignable: function() {
		return false;
	}
	,isChain: function() {
		return false;
	}
	,'eval': function(scope) {
		throw "Cannot evaluate $this";
		return null;
	}
	,assign: function(scope,value) {
		throw "Cannot assign to $this";
		return null;
	}
	,bind: function(context,wrapper) {
		return ($_=new ng.parser.BoundExpression(this,context,wrapper),$bind($_,$_.call));
	}
	,accept: function(visitor) {
	}
	,toString: function() {
		return ng.parser.Unparser.unparse(this);
	}
	,__class__: ng.parser.Expression
};
ng.parser.DynamicExpression = function(expression) {
	this.expression = expression;
};
ng.parser.DynamicExpression.__name__ = ["ng","parser","DynamicExpression"];
ng.parser.DynamicExpression.__super__ = ng.parser.Expression;
ng.parser.DynamicExpression.prototype = $extend(ng.parser.Expression.prototype,{
	expression: null
	,isAssignable: function() {
		return this.expression.isAssignable();
	}
	,isChain: function() {
		return this.expression.isChain();
	}
	,accept: function(visitor) {
		this.expression.accept(visitor);
	}
	,toString: function() {
		return this.expression.toString();
	}
	,'eval': function(scope) {
		try {
			return this.expression["eval"](scope);
		} catch( e ) {
			throw e;
		}
	}
	,assign: function(scope,value) {
		try {
			return this.expression.assign(scope,value);
		} catch( e ) {
			throw e;
		}
	}
	,__class__: ng.parser.DynamicExpression
});
ng.parser.ParserBackend = function() { };
ng.parser.ParserBackend.__name__ = ["ng","parser","ParserBackend"];
ng.parser.ParserBackend.prototype = {
	isAssignable: function(expression) {
		return false;
	}
	,newChain: function(expressions) {
		return null;
	}
	,newFilter: function(expression,name,$arguments) {
		return null;
	}
	,newAssign: function(target,value) {
		return null;
	}
	,newConditional: function(condition,yes,no) {
		return null;
	}
	,newAccessScope: function(name) {
		return null;
	}
	,newAccessMember: function(object,name) {
		return null;
	}
	,newAccessKeyed: function(object,key) {
		return null;
	}
	,newCallScope: function(name,$arguments) {
		return null;
	}
	,newCallFunction: function(fn,$arguments) {
		return null;
	}
	,newCallMember: function(object,name,$arguments) {
		return null;
	}
	,newPrefix: function(operation,expression) {
		return null;
	}
	,newPrefixPlus: function(expression) {
		return expression;
	}
	,newPrefixMinus: function(expression) {
		return this.newBinaryMinus(this.newLiteralZero(),expression);
	}
	,newPrefixNot: function(expression) {
		return this.newPrefix("!",expression);
	}
	,newBinary: function(operation,left,right) {
		return null;
	}
	,newBinaryPlus: function(left,right) {
		return this.newBinary("+",left,right);
	}
	,newBinaryMinus: function(left,right) {
		return this.newBinary("-",left,right);
	}
	,newBinaryMultiply: function(left,right) {
		return this.newBinary("*",left,right);
	}
	,newBinaryDivide: function(left,right) {
		return this.newBinary("/",left,right);
	}
	,newBinaryModulo: function(left,right) {
		return this.newBinary("%",left,right);
	}
	,newBinaryTruncatingDivide: function(left,right) {
		return this.newBinary("~/",left,right);
	}
	,newBinaryLogicalAnd: function(left,right) {
		return this.newBinary("&&",left,right);
	}
	,newBinaryLogicalOr: function(left,right) {
		return this.newBinary("||",left,right);
	}
	,newBinaryEqual: function(left,right) {
		return this.newBinary("==",left,right);
	}
	,newBinaryNotEqual: function(left,right) {
		return this.newBinary("!=",left,right);
	}
	,newBinaryLessThan: function(left,right) {
		return this.newBinary("<",left,right);
	}
	,newBinaryGreaterThan: function(left,right) {
		return this.newBinary(">",left,right);
	}
	,newBinaryLessThanEqual: function(left,right) {
		return this.newBinary("<=",left,right);
	}
	,newBinaryGreaterThanEqual: function(left,right) {
		return this.newBinary(">=",left,right);
	}
	,newLiteralPrimitive: function(value) {
		return null;
	}
	,newLiteralArray: function(elements) {
		return null;
	}
	,newLiteralObject: function(keys,values) {
		return null;
	}
	,newLiteralNull: function() {
		return this.newLiteralPrimitive(null);
	}
	,newLiteralZero: function() {
		return this.newLiteralNumber(0);
	}
	,newLiteralBoolean: function(value) {
		return this.newLiteralPrimitive(value);
	}
	,newLiteralNumber: function(value) {
		return this.newLiteralPrimitive(value);
	}
	,newLiteralString: function(value) {
		return null;
	}
	,__class__: ng.parser.ParserBackend
};
ng.parser.CallMember = function(object,name,$arguments) {
	this.object = object;
	this.name = name;
	this["arguments"] = $arguments;
};
ng.parser.CallMember.__name__ = ["ng","parser","CallMember"];
ng.parser.CallMember.__super__ = ng.parser.Expression;
ng.parser.CallMember.prototype = $extend(ng.parser.Expression.prototype,{
	object: null
	,name: null
	,'arguments': null
	,accept: function(visitor) {
		visitor.visitCallMember(this);
	}
	,__class__: ng.parser.CallMember
});
ng.parser.EvalCallMemberFast0 = function(object,name,$arguments,fn) {
	ng.parser.CallMember.call(this,object,name,$arguments);
	this.fn = fn;
};
ng.parser.EvalCallMemberFast0.__name__ = ["ng","parser","EvalCallMemberFast0"];
ng.parser.EvalCallMemberFast0.__super__ = ng.parser.CallMember;
ng.parser.EvalCallMemberFast0.prototype = $extend(ng.parser.CallMember.prototype,{
	fn: null
	,'eval': function(scope) {
		return ng.parser.CallFast.evaluate0(this,this.object["eval"](scope));
	}
	,__class__: ng.parser.EvalCallMemberFast0
});
ng.parser.EvalCallMemberFast1 = function(object,name,$arguments,fn) {
	ng.parser.CallMember.call(this,object,name,$arguments);
	this.fn = fn;
};
ng.parser.EvalCallMemberFast1.__name__ = ["ng","parser","EvalCallMemberFast1"];
ng.parser.EvalCallMemberFast1.__super__ = ng.parser.CallMember;
ng.parser.EvalCallMemberFast1.prototype = $extend(ng.parser.CallMember.prototype,{
	fn: null
	,'eval': function(scope) {
		return ng.parser.CallFast.evaluate1(this,this.object["eval"](scope),this["arguments"][0]["eval"](scope));
	}
	,__class__: ng.parser.EvalCallMemberFast1
});
ng.parser.CallScope = function(name,$arguments) {
	this.name = name;
	this["arguments"] = $arguments;
};
ng.parser.CallScope.__name__ = ["ng","parser","CallScope"];
ng.parser.CallScope.__super__ = ng.parser.Expression;
ng.parser.CallScope.prototype = $extend(ng.parser.Expression.prototype,{
	name: null
	,'arguments': null
	,accept: function(visitor) {
		visitor.visitCallScope(this);
	}
	,__class__: ng.parser.CallScope
});
ng.parser.EvalCallScopeFast0 = function(name,$arguments,fn) {
	ng.parser.CallScope.call(this,name,$arguments);
	this.fn = fn;
};
ng.parser.EvalCallScopeFast0.__name__ = ["ng","parser","EvalCallScopeFast0"];
ng.parser.EvalCallScopeFast0.__super__ = ng.parser.CallScope;
ng.parser.EvalCallScopeFast0.prototype = $extend(ng.parser.CallScope.prototype,{
	fn: null
	,'eval': function(scope) {
		return ng.parser.CallFast.evaluate0(this,scope);
	}
	,__class__: ng.parser.EvalCallScopeFast0
});
ng.parser.EvalCallScopeFast1 = function(name,$arguments,fn) {
	ng.parser.CallScope.call(this,name,$arguments);
	this.fn = fn;
};
ng.parser.EvalCallScopeFast1.__name__ = ["ng","parser","EvalCallScopeFast1"];
ng.parser.EvalCallScopeFast1.__super__ = ng.parser.CallScope;
ng.parser.EvalCallScopeFast1.prototype = $extend(ng.parser.CallScope.prototype,{
	fn: null
	,'eval': function(scope) {
		return ng.parser.CallFast.evaluate1(this,scope,this["arguments"][0]["eval"](scope));
	}
	,__class__: ng.parser.EvalCallScopeFast1
});
ng.parser.DynamicParserBackend = function(filters,closures) {
	this.filters = filters;
	this.closures = closures;
};
ng.parser.DynamicParserBackend.__name__ = ["ng","parser","DynamicParserBackend"];
ng.parser.DynamicParserBackend.__super__ = ng.parser.ParserBackend;
ng.parser.DynamicParserBackend.prototype = $extend(ng.parser.ParserBackend.prototype,{
	filters: null
	,closures: null
	,isAssignable: function(expression) {
		return expression.isAssignable();
	}
	,newFilter: function(expression,name,$arguments) {
		var filter = this.filters.get(name);
		var allArguments = new Array();
		allArguments.push(expression);
		var _g = 0;
		while(_g < $arguments.length) {
			var arg = $arguments[_g];
			++_g;
			allArguments.push(arg);
		}
		return new ng.parser.EvalFilter(expression,name,$arguments,filter,allArguments);
	}
	,newChain: function(expressions) {
		return new ng.parser.EvalChain(expressions);
	}
	,newAssign: function(target,value) {
		return new ng.parser.EvalAssign(target,value);
	}
	,newConditional: function(condition,yes,no) {
		return new ng.parser.EvalConditional(condition,yes,no);
	}
	,newAccessKeyed: function(object,key) {
		return new ng.parser.EvalAccessKeyed(object,key);
	}
	,newCallFunction: function(fn,$arguments) {
		return new ng.parser.EvalCallFunction(fn,$arguments);
	}
	,newPrefixNot: function(expression) {
		return new ng.parser.EvalPrefixNot(expression);
	}
	,newBinary: function(operation,left,right) {
		return new ng.parser.EvalBinary(operation,left,right);
	}
	,newLiteralPrimitive: function(value) {
		return new ng.parser.EvalLiteralPrimitive(value);
	}
	,newLiteralArray: function(elements) {
		return new ng.parser.EvalLiteralArray(elements);
	}
	,newLiteralObject: function(keys,values) {
		return new ng.parser.EvalLiteralObject(keys,values);
	}
	,newLiteralString: function(value) {
		return new ng.parser.EvalLiteralString(value);
	}
	,newAccessScope: function(name) {
		return new ng.parser.EvalAccessScope(name);
	}
	,newAccessMember: function(object,name) {
		return new ng.parser.EvalAccessMember(object,name);
	}
	,newCallScope: function(name,$arguments) {
		return new ng.parser.EvalCallScope(name,$arguments);
	}
	,newCallMember: function(object,name,$arguments) {
		return new ng.parser.EvalCallMember(object,name,$arguments);
	}
	,computeCallConstructor: function(constructors,name,arity) {
		var fn = this.closures.lookupFunction(name,arity);
		if(fn == null) return null; else return constructors.get(arity);
	}
	,__class__: ng.parser.DynamicParserBackend
});
ng.parser.Token = function(index,text) {
	this.index = index;
	this.text = text;
};
ng.parser.Token.__name__ = ["ng","parser","Token"];
ng.parser.Token.prototype = {
	index: null
	,text: null
	,value: null
	,opKey: null
	,key: null
	,withOp: function(op) {
		this.opKey = op;
		return this;
	}
	,withGetterSetter: function(key) {
		this.key = key;
		return this;
	}
	,withValue: function(value) {
		this.value = value;
		return this;
	}
	,toString: function() {
		return "Token($text)";
	}
	,__class__: ng.parser.Token
};
ng.parser.DynamicParserImpl = function(lexer,backend,input) {
	this.index = 0;
	this.backend = backend;
	this.input = input;
	this.tokens = lexer.call(input);
};
ng.parser.DynamicParserImpl.__name__ = ["ng","parser","DynamicParserImpl"];
ng.parser.DynamicParserImpl.prototype = {
	backend: null
	,input: null
	,lexer: null
	,tokens: null
	,index: null
	,peek: function() {
		if(this.index < this.tokens.length) return this.tokens[this.index]; else return ng.parser.DynamicParserImpl.EOF;
	}
	,parseChain: function() {
		while(this.optional(";")) {
		}
		var expressions = new Array();
		while(this.index < this.tokens.length) {
			if(this.peek().text == ")" || this.peek().text == "}" || this.peek().text == "]") this.error("Unconsumed token " + this.peek().text);
			expressions.push(this.parseFilter());
			while(this.optional(";")) {
			}
		}
		if(expressions.length == 1) return expressions[0]; else return this.backend.newChain(expressions);
	}
	,parseFilter: function() {
		var result = this.parseExpression();
		while(this.optional("|")) {
			var name = this.peek().text;
			this.advance();
			var $arguments = [];
			while(this.optional(":")) $arguments.push(this.parseExpression());
			result = this.backend.newFilter(result,name,$arguments);
		}
		return result;
	}
	,parseExpression: function() {
		var start = this.peek().index;
		var result = this.parseConditional();
		while(this.peek().text == "=") {
			if(!this.backend.isAssignable(result)) {
				var end;
				if(this.index < this.tokens.length) end = this.peek().index; else end = this.input.length;
				var expression = this.input.substring(start,end);
				this.error("Expression " + expression + " is not assignable");
			}
			this.expect("=");
			result = this.backend.newAssign(result,this.parseConditional());
		}
		return result;
	}
	,parseConditional: function() {
		var start = this.peek().index;
		var result = this.parseLogicalOr();
		if(this.optional("?")) {
			var yes = this.parseExpression();
			if(!this.optional(":")) {
				var end;
				if(this.index < this.tokens.length) end = this.peek().index; else end = this.input.length;
				var expression = this.input.substring(start,end);
				this.error("Conditional expression " + expression + " requires all 3 expressions");
			}
			var no = this.parseExpression();
			result = this.backend.newConditional(result,yes,no);
		}
		return result;
	}
	,parseLogicalOr: function() {
		var result = this.parseLogicalAnd();
		while(this.optional("||")) result = this.backend.newBinaryLogicalOr(result,this.parseLogicalAnd());
		return result;
	}
	,parseLogicalAnd: function() {
		var result = this.parseEquality();
		while(this.optional("&&")) result = this.backend.newBinaryLogicalAnd(result,this.parseEquality());
		return result;
	}
	,parseEquality: function() {
		var result = this.parseRelational();
		while(true) if(this.optional("==")) result = this.backend.newBinaryEqual(result,this.parseRelational()); else if(this.optional("!=")) result = this.backend.newBinaryNotEqual(result,this.parseRelational()); else return result;
	}
	,parseRelational: function() {
		var result = this.parseAdditive();
		while(true) if(this.optional("<")) result = this.backend.newBinaryLessThan(result,this.parseAdditive()); else if(this.optional(">")) result = this.backend.newBinaryGreaterThan(result,this.parseAdditive()); else if(this.optional("<=")) result = this.backend.newBinaryLessThanEqual(result,this.parseAdditive()); else if(this.optional(">=")) result = this.backend.newBinaryGreaterThanEqual(result,this.parseAdditive()); else return result;
	}
	,parseAdditive: function() {
		var result = this.parseMultiplicative();
		while(true) if(this.optional("+")) result = this.backend.newBinaryPlus(result,this.parseMultiplicative()); else if(this.optional("-")) result = this.backend.newBinaryMinus(result,this.parseMultiplicative()); else return result;
	}
	,parseMultiplicative: function() {
		var result = this.parsePrefix();
		while(true) if(this.optional("*")) result = this.backend.newBinaryMultiply(result,this.parsePrefix()); else if(this.optional("%")) result = this.backend.newBinaryModulo(result,this.parsePrefix()); else if(this.optional("/")) result = this.backend.newBinaryDivide(result,this.parsePrefix()); else if(this.optional("~/")) result = this.backend.newBinaryTruncatingDivide(result,this.parsePrefix()); else return result;
	}
	,parsePrefix: function() {
		if(this.optional("+")) return this.backend.newPrefixPlus(this.parsePrefix()); else if(this.optional("-")) return this.backend.newPrefixMinus(this.parsePrefix()); else if(this.optional("!")) return this.backend.newPrefixNot(this.parsePrefix()); else return this.parseMemberOrCall();
	}
	,parseMemberOrCall: function() {
		var result = this.parsePrimary();
		while(true) if(this.optional(".")) {
			var name = this.peek().text;
			this.advance();
			if(this.optional("(")) {
				var $arguments = this.parseExpressionList(")");
				this.expect(")");
				result = this.backend.newCallMember(result,name,$arguments);
			} else result = this.backend.newAccessMember(result,name);
		} else if(this.optional("[")) {
			var key = this.parseExpression();
			this.expect("]");
			result = this.backend.newAccessKeyed(result,key);
		} else if(this.optional("(")) {
			var $arguments = this.parseExpressionList(")");
			this.expect(")");
			result = this.backend.newCallFunction(result,$arguments);
		} else return result;
	}
	,parsePrimary: function() {
		if(this.optional("(")) {
			var result = this.parseFilter();
			this.expect(")");
			return result;
		} else if(this.optional("null") || this.optional("undefined")) return this.backend.newLiteralNull(); else if(this.optional("true")) return this.backend.newLiteralBoolean(true); else if(this.optional("false")) return this.backend.newLiteralBoolean(false); else if(this.optional("[")) {
			var elements = this.parseExpressionList("]");
			this.expect("]");
			return this.backend.newLiteralArray(elements);
		} else if(this.peek().text == "{") return this.parseObject(); else if(this.peek().key != null) return this.parseQualified(); else if(this.peek().value != null) {
			var value = this.peek().value;
			this.advance();
			if(js.Boot.__instanceof(value,Float)) return this.backend.newLiteralNumber(value); else return this.backend.newLiteralString(value);
		} else if(this.index >= this.tokens.length) throw "Unexpected end of expression: " + this.input; else {
			this.error("Unexpected token " + this.peek().text);
			return null;
		}
	}
	,parseQualified: function() {
		var components = this.peek().key.split(".");
		this.advance();
		var $arguments = null;
		if(this.optional("(")) {
			$arguments = this.parseExpressionList(")");
			this.expect(")");
		}
		var result;
		if($arguments != null && components.length == 1) result = this.backend.newCallScope(components[0],$arguments); else result = this.backend.newAccessScope(components[0]);
		var _g1 = 1;
		var _g = components.length;
		while(_g1 < _g) {
			var i = _g1++;
			if($arguments != null && components.length == i + 1) result = this.backend.newCallMember(result,components[i],$arguments); else result = this.backend.newAccessMember(result,components[i]);
		}
		return result;
	}
	,parseObject: function() {
		var keys = [];
		var values = [];
		this.expect("{");
		if(this.peek().text != "}") do {
			var value = this.peek().value;
			keys.push(js.Boot.__instanceof(value,String)?value:this.peek().text);
			this.advance();
			this.expect(":");
			values.push(this.parseExpression());
		} while(this.optional(","));
		this.expect("}");
		return this.backend.newLiteralObject(keys,values);
	}
	,parseExpressionList: function(terminator) {
		var result = [];
		if(this.peek().text != terminator) do result.push(this.parseExpression()); while(this.optional(","));
		return result;
	}
	,optional: function(text) {
		if(this.peek().text == text) {
			this.advance();
			return true;
		} else return false;
	}
	,expect: function(text) {
		if(this.peek().text == text) this.advance(); else this.error("Missing expected " + text);
	}
	,advance: function() {
		this.index++;
	}
	,error: function(message) {
		var location;
		if(this.index < this.tokens.length) location = "at column " + (this.tokens[this.index].index + 1) + " in"; else location = "the end of the expression";
		throw "Parser Error: " + message + " " + location + " [" + this.input + "]";
	}
	,__class__: ng.parser.DynamicParserImpl
};
ng.parser.Eval = function() { };
ng.parser.Eval.__name__ = ["ng","parser","Eval"];
ng.parser.Chain = function(expressions) {
	this.expressions = expressions;
};
ng.parser.Chain.__name__ = ["ng","parser","Chain"];
ng.parser.Chain.__super__ = ng.parser.Expression;
ng.parser.Chain.prototype = $extend(ng.parser.Expression.prototype,{
	expressions: null
	,isChain: function() {
		return true;
	}
	,accept: function(visitor) {
		visitor.visitChain(this);
	}
	,__class__: ng.parser.Chain
});
ng.parser.EvalChain = function(expressions) {
	ng.parser.Chain.call(this,expressions);
};
ng.parser.EvalChain.__name__ = ["ng","parser","EvalChain"];
ng.parser.EvalChain.__super__ = ng.parser.Chain;
ng.parser.EvalChain.prototype = $extend(ng.parser.Chain.prototype,{
	'eval': function(scope) {
		var result = null;
		var length = this.expressions.length;
		var _g = 0;
		while(_g < length) {
			var i = _g++;
			var last = this.expressions[i]["eval"](scope);
			if(last != null) result = last;
		}
		return result;
	}
	,__class__: ng.parser.EvalChain
});
ng.parser.Filter = function(expression,name,$arguments) {
	this.expression = expression;
	this.name = name;
	this["arguments"] = $arguments;
};
ng.parser.Filter.__name__ = ["ng","parser","Filter"];
ng.parser.Filter.__super__ = ng.parser.Expression;
ng.parser.Filter.prototype = $extend(ng.parser.Expression.prototype,{
	expression: null
	,name: null
	,'arguments': null
	,accept: function(visitor) {
		visitor.visitFilter(this);
	}
	,__class__: ng.parser.Filter
});
ng.parser.EvalFilter = function(expression,name,$arguments,fn,allArguments) {
	ng.parser.Filter.call(this,expression,name,$arguments);
	this.allArguments = allArguments;
	this.fn = fn;
};
ng.parser.EvalFilter.__name__ = ["ng","parser","EvalFilter"];
ng.parser.EvalFilter.__super__ = ng.parser.Filter;
ng.parser.EvalFilter.prototype = $extend(ng.parser.Filter.prototype,{
	fn: null
	,allArguments: null
	,'eval': function(scope) {
		var fn = this.fn;
		var allArguments = this.allArguments;
		return fn.apply(scope,allArguments);
	}
	,__class__: ng.parser.EvalFilter
});
ng.parser.Assign = function(target,value) {
	this.target = target;
	this.value = value;
};
ng.parser.Assign.__name__ = ["ng","parser","Assign"];
ng.parser.Assign.__super__ = ng.parser.Expression;
ng.parser.Assign.prototype = $extend(ng.parser.Expression.prototype,{
	target: null
	,value: null
	,accept: function(visitor) {
		visitor.visitAssign(this);
	}
	,__class__: ng.parser.Assign
});
ng.parser.EvalAssign = function(target,value) {
	ng.parser.Assign.call(this,target,value);
};
ng.parser.EvalAssign.__name__ = ["ng","parser","EvalAssign"];
ng.parser.EvalAssign.__super__ = ng.parser.Assign;
ng.parser.EvalAssign.prototype = $extend(ng.parser.Assign.prototype,{
	'eval': function(scope) {
		return this.target.assign(scope,this.value["eval"](scope));
	}
	,__class__: ng.parser.EvalAssign
});
ng.parser.Conditional = function(condition,yes,no) {
	this.condition = condition;
	this.yes = yes;
	this.no = no;
};
ng.parser.Conditional.__name__ = ["ng","parser","Conditional"];
ng.parser.Conditional.__super__ = ng.parser.Expression;
ng.parser.Conditional.prototype = $extend(ng.parser.Expression.prototype,{
	condition: null
	,yes: null
	,no: null
	,accept: function(visitor) {
		visitor.visitConditional(this);
	}
	,__class__: ng.parser.Conditional
});
ng.parser.EvalConditional = function(condition,yes,no) {
	ng.parser.Conditional.call(this,condition,yes,no);
};
ng.parser.EvalConditional.__name__ = ["ng","parser","EvalConditional"];
ng.parser.EvalConditional.__super__ = ng.parser.Conditional;
ng.parser.EvalConditional.prototype = $extend(ng.parser.Conditional.prototype,{
	'eval': function(scope) {
		if(this.condition["eval"](scope) != null && this.condition["eval"](scope) != false) return this.yes["eval"](scope); else return this.no["eval"](scope);
	}
	,__class__: ng.parser.EvalConditional
});
ng.parser.Prefix = function(operation,expression) {
	this.operation = operation;
	this.expression = expression;
};
ng.parser.Prefix.__name__ = ["ng","parser","Prefix"];
ng.parser.Prefix.__super__ = ng.parser.Expression;
ng.parser.Prefix.prototype = $extend(ng.parser.Expression.prototype,{
	operation: null
	,expression: null
	,accept: function(visitor) {
		visitor.visitPrefix(this);
	}
	,__class__: ng.parser.Prefix
});
ng.parser.EvalPrefixNot = function(expression) {
	ng.parser.Prefix.call(this,"!",expression);
};
ng.parser.EvalPrefixNot.__name__ = ["ng","parser","EvalPrefixNot"];
ng.parser.EvalPrefixNot.__super__ = ng.parser.Prefix;
ng.parser.EvalPrefixNot.prototype = $extend(ng.parser.Prefix.prototype,{
	'eval': function(scope) {
		return this.expression["eval"](scope) == null || this.expression["eval"](scope) == false || this.expression["eval"](scope) == "" || this.expression["eval"](scope) == 0;
	}
	,__class__: ng.parser.EvalPrefixNot
});
ng.parser.Binary = function(operation,left,right) {
	this.operation = operation;
	this.left = left;
	this.right = right;
};
ng.parser.Binary.__name__ = ["ng","parser","Binary"];
ng.parser.Binary.__super__ = ng.parser.Expression;
ng.parser.Binary.prototype = $extend(ng.parser.Expression.prototype,{
	operation: null
	,left: null
	,right: null
	,accept: function(visitor) {
		visitor.visitBinary(this);
	}
	,__class__: ng.parser.Binary
});
ng.parser.EvalBinary = function(operation,left,right) {
	ng.parser.Binary.call(this,operation,left,right);
};
ng.parser.EvalBinary.__name__ = ["ng","parser","EvalBinary"];
ng.parser.EvalBinary.__super__ = ng.parser.Binary;
ng.parser.EvalBinary.prototype = $extend(ng.parser.Binary.prototype,{
	'eval': function(scope) {
		var left = this.left["eval"](scope);
		var _g = this.operation;
		switch(_g) {
		case "&&":
			return (js.Boot.__instanceof(left,Bool)?left:left != null && left != 0 && left != "") && (function($this) {
				var $r;
				var a = $this.right["eval"](scope);
				$r = js.Boot.__instanceof(a,Bool)?a:a != null && a != 0 && a != "";
				return $r;
			}(this));
		case "||":
			return (js.Boot.__instanceof(left,Bool)?left:left != null && left != 0 && left != "") || (function($this) {
				var $r;
				var a = $this.right["eval"](scope);
				$r = js.Boot.__instanceof(a,Bool)?a:a != null && a != 0 && a != "";
				return $r;
			}(this));
		}
		var right = this.right["eval"](scope);
		var _g = this.operation;
		switch(_g) {
		case "+":
			if(left != null && right != null) {
				if(js.Boot.__instanceof(left,String) && !js.Boot.__instanceof(right,String)) return left + right.toString(); else if(!js.Boot.__instanceof(left,String) && js.Boot.__instanceof(right,String)) return left.toString() + right; else return left + right;
			} else if(left != null) return left; else if(right != null) return right; else return null;
			break;
		case "-":
			return left - right;
		case "*":
			return left * right;
		case "/":
			return left / right;
		case "%":
			return left % right;
		case "==":
			return left == right;
		case "!=":
			return left != right;
		case "<":
			return left < right;
		case ">":
			return left > right;
		case "<=":
			return left <= right;
		case ">=":
			return left >= right;
		case "^":
			return left ^ right;
		case "&":
			return left & right;
		}
		throw "Internal error [" + this.operation + "] not handled";
	}
	,__class__: ng.parser.EvalBinary
});
ng.parser.Literal = function() { };
ng.parser.Literal.__name__ = ["ng","parser","Literal"];
ng.parser.Literal.__super__ = ng.parser.Expression;
ng.parser.Literal.prototype = $extend(ng.parser.Expression.prototype,{
	__class__: ng.parser.Literal
});
ng.parser.LiteralPrimitive = function(value) {
	this.value = value;
};
ng.parser.LiteralPrimitive.__name__ = ["ng","parser","LiteralPrimitive"];
ng.parser.LiteralPrimitive.__super__ = ng.parser.Literal;
ng.parser.LiteralPrimitive.prototype = $extend(ng.parser.Literal.prototype,{
	value: null
	,accept: function(visitor) {
		visitor.visitLiteralPrimitive(this);
	}
	,__class__: ng.parser.LiteralPrimitive
});
ng.parser.EvalLiteralPrimitive = function(value) {
	ng.parser.LiteralPrimitive.call(this,value);
};
ng.parser.EvalLiteralPrimitive.__name__ = ["ng","parser","EvalLiteralPrimitive"];
ng.parser.EvalLiteralPrimitive.__super__ = ng.parser.LiteralPrimitive;
ng.parser.EvalLiteralPrimitive.prototype = $extend(ng.parser.LiteralPrimitive.prototype,{
	'eval': function(scope) {
		return this.value;
	}
	,__class__: ng.parser.EvalLiteralPrimitive
});
ng.parser.LiteralString = function(value) {
	this.value = value;
};
ng.parser.LiteralString.__name__ = ["ng","parser","LiteralString"];
ng.parser.LiteralString.__super__ = ng.parser.Literal;
ng.parser.LiteralString.prototype = $extend(ng.parser.Literal.prototype,{
	value: null
	,accept: function(visitor) {
		visitor.visitLiteralString(this);
	}
	,__class__: ng.parser.LiteralString
});
ng.parser.EvalLiteralString = function(value) {
	ng.parser.LiteralString.call(this,value);
};
ng.parser.EvalLiteralString.__name__ = ["ng","parser","EvalLiteralString"];
ng.parser.EvalLiteralString.__super__ = ng.parser.LiteralString;
ng.parser.EvalLiteralString.prototype = $extend(ng.parser.LiteralString.prototype,{
	'eval': function(scope) {
		return this.value;
	}
	,__class__: ng.parser.EvalLiteralString
});
ng.parser.LiteralArray = function(elements) {
	this.elements = elements;
};
ng.parser.LiteralArray.__name__ = ["ng","parser","LiteralArray"];
ng.parser.LiteralArray.__super__ = ng.parser.Literal;
ng.parser.LiteralArray.prototype = $extend(ng.parser.Literal.prototype,{
	elements: null
	,accept: function(visitor) {
		visitor.visitLiteralArray(this);
	}
	,__class__: ng.parser.LiteralArray
});
ng.parser.EvalLiteralArray = function(elements) {
	ng.parser.LiteralArray.call(this,elements);
};
ng.parser.EvalLiteralArray.__name__ = ["ng","parser","EvalLiteralArray"];
ng.parser.EvalLiteralArray.__super__ = ng.parser.LiteralArray;
ng.parser.EvalLiteralArray.prototype = $extend(ng.parser.LiteralArray.prototype,{
	'eval': function(scope) {
		var res = [];
		var _g = 0;
		var _g1 = this.elements;
		while(_g < _g1.length) {
			var el = _g1[_g];
			++_g;
			res.push(el["eval"](scope));
		}
		return res;
	}
	,__class__: ng.parser.EvalLiteralArray
});
ng.parser.LiteralObject = function(keys,values) {
	this.keys = keys;
	this.values = values;
};
ng.parser.LiteralObject.__name__ = ["ng","parser","LiteralObject"];
ng.parser.LiteralObject.__super__ = ng.parser.Literal;
ng.parser.LiteralObject.prototype = $extend(ng.parser.Literal.prototype,{
	keys: null
	,values: null
	,accept: function(visitor) {
		visitor.visitLiteralObject(this);
	}
	,__class__: ng.parser.LiteralObject
});
ng.parser.EvalLiteralObject = function(keys,values) {
	ng.parser.LiteralObject.call(this,keys,values);
};
ng.parser.EvalLiteralObject.__name__ = ["ng","parser","EvalLiteralObject"];
ng.parser.EvalLiteralObject.__super__ = ng.parser.LiteralObject;
ng.parser.EvalLiteralObject.prototype = $extend(ng.parser.LiteralObject.prototype,{
	'eval': function(scope) {
		var map = { };
		var _g1 = 0;
		var _g = this.keys.length;
		while(_g1 < _g) {
			var i = _g1++;
			var field = this.keys[i];
			var value = this.values[i]["eval"](scope);
			var tmp;
			if(map.__properties__ && (tmp = map.__properties__["set_" + field])) map[tmp](value); else map[field] = value;
		}
		return map;
	}
	,__class__: ng.parser.EvalLiteralObject
});
ng.parser.EvalAcess = function() { };
ng.parser.EvalAcess.__name__ = ["ng","parser","EvalAcess"];
ng.parser.AccessScope = function(name) {
	this.name = name;
};
ng.parser.AccessScope.__name__ = ["ng","parser","AccessScope"];
ng.parser.AccessScope.__super__ = ng.parser.Expression;
ng.parser.AccessScope.prototype = $extend(ng.parser.Expression.prototype,{
	name: null
	,isAssignable: function() {
		return true;
	}
	,accept: function(visitor) {
		visitor.visitAccessScope(this);
	}
	,__class__: ng.parser.AccessScope
});
ng.parser.EvalAccessScope = function(name) {
	ng.parser.AccessScope.call(this,name);
	this.symbol = name;
};
ng.parser.EvalAccessScope.__name__ = ["ng","parser","EvalAccessScope"];
ng.parser.EvalAccessScope.__super__ = ng.parser.AccessScope;
ng.parser.EvalAccessScope.prototype = $extend(ng.parser.AccessScope.prototype,{
	symbol: null
	,'eval': function(scope) {
		return ng.parser.AccessReflective["eval"](this,scope);
	}
	,assign: function(scope,value) {
		return ng.parser.AccessReflective.assign(this,scope,scope,value);
	}
	,assignToNonExisting: function(scope,value) {
		return null;
	}
	,__class__: ng.parser.EvalAccessScope
});
ng.parser.EvalAccessScopeFast = function(name,getter,setter) {
	this.getter = getter;
	this.setter = setter;
	ng.parser.AccessScope.call(this,name);
};
ng.parser.EvalAccessScopeFast.__name__ = ["ng","parser","EvalAccessScopeFast"];
ng.parser.EvalAccessScopeFast.__super__ = ng.parser.AccessScope;
ng.parser.EvalAccessScopeFast.prototype = $extend(ng.parser.AccessScope.prototype,{
	getter: null
	,setter: null
	,'eval': function(scope) {
		return ng.parser.AccessFast["eval"](this,scope);
	}
	,assign: function(scope,value) {
		return ng.parser.AccessFast.assign(this,scope,scope,value);
	}
	,__class__: ng.parser.EvalAccessScopeFast
});
ng.parser.AccessMember = function(object,name) {
	this.object = object;
	this.name = name;
};
ng.parser.AccessMember.__name__ = ["ng","parser","AccessMember"];
ng.parser.AccessMember.__super__ = ng.parser.Expression;
ng.parser.AccessMember.prototype = $extend(ng.parser.Expression.prototype,{
	object: null
	,name: null
	,isAssignable: function() {
		return true;
	}
	,accept: function(visitor) {
		visitor.visitAccessMember(this);
	}
	,__class__: ng.parser.AccessMember
});
ng.parser.EvalAccessMember = function(object,name) {
	ng.parser.AccessMember.call(this,object,name);
	this.symbol = name;
};
ng.parser.EvalAccessMember.__name__ = ["ng","parser","EvalAccessMember"];
ng.parser.EvalAccessMember.__super__ = ng.parser.AccessMember;
ng.parser.EvalAccessMember.prototype = $extend(ng.parser.AccessMember.prototype,{
	symbol: null
	,'eval': function(scope) {
		return ng.parser.AccessReflective["eval"](this,this.object["eval"](scope));
	}
	,assign: function(scope,value) {
		return ng.parser.AccessReflective.assign(this,scope,this.object["eval"](scope),value);
	}
	,assignToNonExisting: function(scope,value) {
		var obj = { };
		obj[this.name] = value;
		return this.object.assign(scope,obj);
	}
	,__class__: ng.parser.EvalAccessMember
});
ng.parser.EvalAccessMemberFast = function(object,name,getter,setter) {
	ng.parser.AccessMember.call(this,object,name);
	this.getter = getter;
	this.setter = setter;
};
ng.parser.EvalAccessMemberFast.__name__ = ["ng","parser","EvalAccessMemberFast"];
ng.parser.EvalAccessMemberFast.__super__ = ng.parser.AccessMember;
ng.parser.EvalAccessMemberFast.prototype = $extend(ng.parser.AccessMember.prototype,{
	getter: null
	,setter: null
	,'eval': function(scope) {
		return ng.parser.AccessFast["eval"](this,this.object["eval"](scope));
	}
	,assign: function(scope,value) {
		return ng.parser.AccessFast.assign(this,scope,this.object["eval"](scope),value);
	}
	,__class__: ng.parser.EvalAccessMemberFast
});
ng.parser.AccessKeyed = function(object,key) {
	this.object = object;
	this.key = key;
};
ng.parser.AccessKeyed.__name__ = ["ng","parser","AccessKeyed"];
ng.parser.AccessKeyed.__super__ = ng.parser.Expression;
ng.parser.AccessKeyed.prototype = $extend(ng.parser.Expression.prototype,{
	object: null
	,key: null
	,isAssignable: function() {
		return true;
	}
	,accept: function(visitor) {
		visitor.visitAccessKeyed(this);
	}
	,__class__: ng.parser.AccessKeyed
});
ng.parser.EvalAccessKeyed = function(object,key) {
	ng.parser.AccessKeyed.call(this,object,key);
};
ng.parser.EvalAccessKeyed.__name__ = ["ng","parser","EvalAccessKeyed"];
ng.parser.EvalAccessKeyed.__super__ = ng.parser.AccessKeyed;
ng.parser.EvalAccessKeyed.prototype = $extend(ng.parser.AccessKeyed.prototype,{
	'eval': function(scope) {
		return ng.parser.Utils.getKeyed(this.object["eval"](scope),this.key["eval"](scope));
	}
	,assign: function(scope,value) {
		return ng.parser.Utils.setKeyed(this.object["eval"](scope),this.key["eval"](scope),value);
	}
	,__class__: ng.parser.EvalAccessKeyed
});
ng.parser.AccessReflective = function() { };
ng.parser.AccessReflective.__name__ = ["ng","parser","AccessReflective"];
ng.parser.AccessReflective["eval"] = function(self,holder) {
	if(ng.parser.Utils.isPrivate(holder,self.name)) throw "Cannot access private property";
	var field = self.name;
	var tmp;
	if(holder == null) return null; else if(holder.__properties__ && (tmp = holder.__properties__["get_" + field])) return holder[tmp](); else return holder[field];
};
ng.parser.AccessReflective.assign = function(self,scope,holder,value) {
	if(holder != null) {
		var field = self.name;
		var tmp;
		if(holder.__properties__ && (tmp = holder.__properties__["set_" + field])) holder[tmp](value); else holder[field] = value;
	} else self.assignToNonExisting(scope,value);
	return value;
};
ng.parser.AccessFast = function() { };
ng.parser.AccessFast.__name__ = ["ng","parser","AccessFast"];
ng.parser.AccessFast["eval"] = function(self,holder) {
	return null;
};
ng.parser.AccessFast.assign = function(self,scope,holder,value) {
	return null;
};
ng.parser.EvalCalls = function() { };
ng.parser.EvalCalls.__name__ = ["ng","parser","EvalCalls"];
ng.parser.EvalCallScope = function(name,$arguments) {
	ng.parser.CallScope.call(this,name,$arguments);
	this.symbol = name;
};
ng.parser.EvalCallScope.__name__ = ["ng","parser","EvalCallScope"];
ng.parser.EvalCallScope.__super__ = ng.parser.CallScope;
ng.parser.EvalCallScope.prototype = $extend(ng.parser.CallScope.prototype,{
	symbol: null
	,'eval': function(scope) {
		return ng.parser.CallReflective["eval"](this,scope,scope);
	}
	,__class__: ng.parser.EvalCallScope
});
ng.parser.EvalCallMember = function(object,name,$arguments) {
	ng.parser.CallMember.call(this,object,name,$arguments);
	this.symbol = name;
};
ng.parser.EvalCallMember.__name__ = ["ng","parser","EvalCallMember"];
ng.parser.EvalCallMember.__super__ = ng.parser.CallMember;
ng.parser.EvalCallMember.prototype = $extend(ng.parser.CallMember.prototype,{
	symbol: null
	,'eval': function(scope) {
		return ng.parser.CallReflective["eval"](this,scope,this.object["eval"](scope));
	}
	,__class__: ng.parser.EvalCallMember
});
ng.parser.CallFunction = function(fn,$arguments) {
	this.fn = fn;
	this["arguments"] = $arguments;
};
ng.parser.CallFunction.__name__ = ["ng","parser","CallFunction"];
ng.parser.CallFunction.__super__ = ng.parser.Expression;
ng.parser.CallFunction.prototype = $extend(ng.parser.Expression.prototype,{
	fn: null
	,'arguments': null
	,accept: function(visitor) {
		visitor.visitCallFunction(this);
	}
	,__class__: ng.parser.CallFunction
});
ng.parser.EvalCallFunction = function(fn,$arguments) {
	ng.parser.CallFunction.call(this,fn,$arguments);
};
ng.parser.EvalCallFunction.__name__ = ["ng","parser","EvalCallFunction"];
ng.parser.EvalCallFunction.__super__ = ng.parser.CallFunction;
ng.parser.EvalCallFunction.prototype = $extend(ng.parser.CallFunction.prototype,{
	'eval': function(scope) {
		var fn = this.fn["eval"](scope);
		if(ng.parser.Utils.isFunction(fn)) return ng.parser.Utils.relaxFnApply(fn,ng.parser.Utils.evalList(scope,this["arguments"])); else throw "" + fn + " is not a function";
		return null;
	}
	,__class__: ng.parser.EvalCallFunction
});
ng.parser.CallReflective = function() { };
ng.parser.CallReflective.__name__ = ["ng","parser","CallReflective"];
ng.parser.CallReflective["eval"] = function(self,scope,holder) {
	var $arguments = ng.parser.Utils.evalList(scope,self["arguments"]);
	var func;
	var field = self.name;
	var v = null;
	try {
		v = holder[field];
	} catch( e ) {
	}
	func = v;
	return func.apply(scope,$arguments);
};
ng.parser.CallFast = function() { };
ng.parser.CallFast.__name__ = ["ng","parser","CallFast"];
ng.parser.CallFast.evaluate0 = function(self,holder) {
	return self.fn(holder);
};
ng.parser.CallFast.evaluate1 = function(self,holder,a0) {
	return self.fn(holder,a0);
};
ng.parser._Lexer = {};
ng.parser._Lexer.Symbols = function() { };
ng.parser._Lexer.Symbols.__name__ = ["ng","parser","_Lexer","Symbols"];
ng.parser._Lexer.Symbols.isWhitespace = function(code) {
	return code >= 9 && code <= 32 || code == 160;
};
ng.parser._Lexer.Symbols.isIdentifierStart = function(code) {
	return 97 <= code && code <= 122 || 65 <= code && code <= 90 || code == 95 || code == 36;
};
ng.parser._Lexer.Symbols.isIdentifierPart = function(code) {
	return 97 <= code && code <= 122 || 65 <= code && code <= 90 || 48 <= code && code <= 57 || code == 95 || code == 36;
};
ng.parser._Lexer.Symbols.isDigit = function(code) {
	return 48 <= code && code <= 57;
};
ng.parser._Lexer.Symbols.isExponentStart = function(code) {
	return code == 101 || code == 69;
};
ng.parser._Lexer.Symbols.isExponentSign = function(code) {
	return code == 45 || code == 43;
};
ng.parser._Lexer.Symbols.unescape = function(code) {
	switch(code) {
	case 110:
		return 10;
	case 102:
		return 12;
	case 114:
		return 13;
	case 116:
		return 9;
	case 118:
		return 11;
	default:
		return code;
	}
};
ng.parser.Lexer = function() {
};
ng.parser.Lexer.__name__ = ["ng","parser","Lexer"];
ng.parser.Lexer.prototype = {
	call: function(text) {
		var scanner = new ng.parser.Scanner(text);
		var tokens = new Array();
		var token = scanner.scanToken();
		while(token != null) {
			tokens.push(token);
			token = scanner.scanToken();
		}
		return tokens;
	}
	,__class__: ng.parser.Lexer
};
ng.parser.Scanner = function(input) {
	this.index = -1;
	this.peek = 0;
	this.buffer = new Array();
	this.input = input;
	this.length = input.length;
	this.advance();
};
ng.parser.Scanner.__name__ = ["ng","parser","Scanner"];
ng.parser.Scanner.prototype = {
	input: null
	,length: null
	,buffer: null
	,peek: null
	,index: null
	,scanToken: function() {
		if(this.buffer.length > 0) return this.buffer.pop();
		while((function($this) {
			var $r;
			var code = $this.peek;
			$r = code >= 9 && code <= 32 || code == 160;
			return $r;
		}(this))) this.advance();
		if((function($this) {
			var $r;
			var code = $this.peek;
			$r = 97 <= code && code <= 122 || 65 <= code && code <= 90 || code == 95 || code == 36;
			return $r;
		}(this))) return this.scanIdentifier();
		if((function($this) {
			var $r;
			var code = $this.peek;
			$r = 48 <= code && code <= 57;
			return $r;
		}(this))) return this.scanNumber(this.index);
		var start = this.index;
		var _g = this.peek;
		switch(_g) {
		case 0:
			return null;
		case 46:
			this.advance();
			if((function($this) {
				var $r;
				var code = $this.peek;
				$r = 48 <= code && code <= 57;
				return $r;
			}(this))) return this.scanNumber(start); else return new ng.parser.Token(start,".");
			break;
		case 40:
			return this.scanCharacter(start,"(");
		case 41:
			return this.scanCharacter(start,")");
		case 123:
			return this.scanCharacter(start,"{");
		case 125:
			return this.scanCharacter(start,"}");
		case 91:
			return this.scanCharacter(start,"[");
		case 93:
			return this.scanCharacter(start,"]");
		case 44:
			return this.scanCharacter(start,",");
		case 58:
			return this.scanCharacter(start,":");
		case 59:
			return this.scanCharacter(start,";");
		case 39:
			return this.scanString();
		case 34:
			return this.scanString();
		case 43:
			return this.scanOperator(start,"+");
		case 45:
			return this.scanOperator(start,"-");
		case 42:
			return this.scanOperator(start,"*");
		case 47:
			return this.scanOperator(start,"/");
		case 37:
			return this.scanOperator(start,"%");
		case 94:
			return this.scanOperator(start,"^");
		case 63:
			return this.scanOperator(start,"?");
		case 60:
			return this.scanComplexOperator(start,61,"<","<=");
		case 62:
			return this.scanComplexOperator(start,61,">",">=");
		case 33:
			return this.scanComplexOperator(start,61,"!","!=");
		case 61:
			return this.scanComplexOperator(start,61,"=","==");
		case 38:
			return this.scanComplexOperator(start,38,"&","&&");
		case 124:
			return this.scanComplexOperator(start,124,"|","||");
		case 126:
			return this.scanComplexOperator(start,47,"~","~/");
		}
		var character = String.fromCharCode(this.peek);
		this.error("Unexpected character [" + character + "]");
		return null;
	}
	,scanCharacter: function(start,string) {
		this.advance();
		return new ng.parser.Token(start,string);
	}
	,scanOperator: function(start,string) {
		this.advance();
		return new ng.parser.Token(start,string).withOp(string);
	}
	,scanComplexOperator: function(start,code,one,two) {
		this.advance();
		var string = one;
		if(this.peek == code) {
			this.advance();
			string = two;
		}
		return new ng.parser.Token(start,string).withOp(string);
	}
	,scanIdentifier: function() {
		var start = this.index;
		var dot = -1;
		this.advance();
		while(true) {
			if(this.peek == 46) dot = this.index; else if(!(function($this) {
				var $r;
				var code = $this.peek;
				$r = 97 <= code && code <= 122 || 65 <= code && code <= 90 || 48 <= code && code <= 57 || code == 95 || code == 36;
				return $r;
			}(this))) break;
			this.advance();
		}
		if(dot == -1) {
			var string = this.input.substring(start,this.index);
			var result = new ng.parser.Token(start,string);
			if(Lambda.has(ng.parser.Scanner.OPERATORS,string)) result.withOp(string); else result.withGetterSetter(string);
			return result;
		}
		var end = this.index;
		while((function($this) {
			var $r;
			var code = $this.peek;
			$r = code >= 9 && code <= 32 || code == 160;
			return $r;
		}(this))) this.advance();
		if(this.peek == 40) {
			this.buffer.push(new ng.parser.Token(dot + 1,this.input.substring(dot + 1,end)));
			this.buffer.push(new ng.parser.Token(dot,"."));
			end = dot;
		}
		var string = this.input.substring(start,end);
		return new ng.parser.Token(start,string).withGetterSetter(string);
	}
	,scanNumber: function(start) {
		var simple = this.index == start;
		while(true) {
			if((function($this) {
				var $r;
				var code = $this.peek;
				$r = 48 <= code && code <= 57;
				return $r;
			}(this))) {
			} else if(this.peek == 46) simple = false; else if((function($this) {
				var $r;
				var code = $this.peek;
				$r = code == 101 || code == 69;
				return $r;
			}(this))) {
				this.advance();
				if((function($this) {
					var $r;
					var code = $this.peek;
					$r = code == 45 || code == 43;
					return $r;
				}(this))) this.advance();
				if(!(function($this) {
					var $r;
					var code = $this.peek;
					$r = 48 <= code && code <= 57;
					return $r;
				}(this))) this.error("Invalid exponent",-1);
				simple = false;
			} else break;
			this.advance();
		}
		var string = this.input.substring(start,this.index);
		var value;
		if(simple) value = Std.parseInt(string); else value = Std.parseFloat(string);
		return new ng.parser.Token(start,string).withValue(value);
	}
	,scanString: function() {
		var start = this.index;
		var quote = this.peek;
		this.advance();
		var buffer = new Array();
		var marker = this.index;
		while(this.peek != quote) if(this.peek == 92) {
			if(buffer == null) buffer = new Array();
			buffer.push(this.input.substring(marker,this.index));
			this.advance();
			var unescaped;
			if(this.peek == 117) {
				var hex = this.input.substring(this.index + 1,this.index + 5);
				unescaped = Std.parseInt("0x" + hex);
				var _g = 0;
				while(_g < 5) {
					var i = _g++;
					this.advance();
				}
			} else {
				var code = this.peek;
				switch(code) {
				case 110:
					unescaped = 10;
					break;
				case 102:
					unescaped = 12;
					break;
				case 114:
					unescaped = 13;
					break;
				case 116:
					unescaped = 9;
					break;
				case 118:
					unescaped = 11;
					break;
				default:
					unescaped = code;
				}
				this.advance();
			}
			buffer.push(String.fromCharCode(unescaped));
			marker = this.index;
		} else if(this.peek == 0) this.error("Unterminated quote"); else this.advance();
		var last = this.input.substring(marker,this.index);
		this.advance();
		var string = this.input.substring(start,this.index);
		var unescaped = last;
		if(buffer != null) {
			buffer.push(last);
			unescaped = buffer.join("");
		}
		return new ng.parser.Token(start,string).withValue(unescaped);
	}
	,advance: function() {
		if(++this.index >= this.length) this.peek = 0; else this.peek = HxOverrides.cca(this.input,this.index);
	}
	,error: function(message,offset) {
		if(offset == null) offset = 0;
		var position = this.index + offset;
		throw "Lexer Error: " + message + " at column " + position + " in expression [" + this.input + "]";
	}
	,__class__: ng.parser.Scanner
};
ng.parser.Syntax = function() { };
ng.parser.Syntax.__name__ = ["ng","parser","Syntax"];
ng.parser.Visitor = function() { };
ng.parser.Visitor.__name__ = ["ng","parser","Visitor"];
ng.parser.Visitor.prototype = {
	visit: function(expression) {
		return expression.accept(this);
	}
	,visitExpression: function(expression) {
		return null;
	}
	,visitChain: function(expression) {
		return this.visitExpression(expression);
	}
	,visitFilter: function(expression) {
		return this.visitExpression(expression);
	}
	,visitAssign: function(expression) {
		return this.visitExpression(expression);
	}
	,visitConditional: function(expression) {
		return this.visitExpression(expression);
	}
	,visitAccessScope: function(expression) {
		return this.visitExpression(expression);
	}
	,visitAccessMember: function(expression) {
		return this.visitExpression(expression);
	}
	,visitAccessKeyed: function(expression) {
		return this.visitExpression(expression);
	}
	,visitCallScope: function(expression) {
		return this.visitExpression(expression);
	}
	,visitCallFunction: function(expression) {
		return this.visitExpression(expression);
	}
	,visitCallMember: function(expression) {
		return this.visitExpression(expression);
	}
	,visitBinary: function(expression) {
		return this.visitExpression(expression);
	}
	,visitPrefix: function(expression) {
		return this.visitExpression(expression);
	}
	,visitLiteral: function(expression) {
		return this.visitExpression(expression);
	}
	,visitLiteralPrimitive: function(expression) {
		return this.visitLiteral(expression);
	}
	,visitLiteralString: function(expression) {
		return this.visitLiteral(expression);
	}
	,visitLiteralArray: function(expression) {
		return this.visitLiteral(expression);
	}
	,visitLiteralObject: function(expression) {
		return this.visitLiteral(expression);
	}
	,__class__: ng.parser.Visitor
};
ng.parser.BoundExpression = function(expression,context,wrapper) {
	this.expression = expression;
	this.context = context;
	this.wrapper = wrapper.call;
};
ng.parser.BoundExpression.__name__ = ["ng","parser","BoundExpression"];
ng.parser.BoundExpression.prototype = {
	expression: null
	,context: null
	,wrapper: null
	,call: function(locals) {
		var result = this.expression["eval"](locals);
		if(result == null) result = this.expression["eval"](this.context);
		return result;
	}
	,assign: function(value,locals) {
		return this.expression.assign(this.computeContext(locals),value);
	}
	,computeContext: function(locals) {
		if(locals == null) return this.context;
		if(this.wrapper != null) return this.wrapper(this.context,locals);
		throw "Locals $locals provided, but missing wrapper.";
	}
	,__class__: ng.parser.BoundExpression
};
ng.parser.Unparser = function() { };
ng.parser.Unparser.__name__ = ["ng","parser","Unparser"];
ng.parser.Unparser.unparse = function(expression) {
	return expression.toString();
};
ng.parser.Utils = function() { };
ng.parser.Utils.__name__ = ["ng","parser","Utils"];
ng.parser.Utils.getKeyed = function(object,key) {
	if(js.Boot.__instanceof(object,Array)) return object[key]; else if(js.Boot.__instanceof(object,Dynamic)) {
		var field = key;
		var tmp;
		if(object == null) return null; else if(object.__properties__ && (tmp = object.__properties__["get_" + field])) return object[tmp](); else return object[field];
	}
	throw "Attempted field access on a non-list, non-map";
};
ng.parser.Utils.setKeyed = function(object,key,value) {
	if(js.Boot.__instanceof(object,Array)) {
		var index = key;
		if(object.length <= index) object.length = index + 1;
		object[index] = value;
	} else if(js.Boot.__instanceof(object,Dynamic)) {
		var field = key;
		var tmp;
		if(object.__properties__ && (tmp = object.__properties__["set_" + field])) object[tmp](value); else object[field] = value;
	} else throw "Attempting to set a field on a non-list, non-map";
	return value;
};
ng.parser.Utils.toBool = function(a) {
	if(js.Boot.__instanceof(a,Bool)) return a;
	return a != null && a != 0 && a != "";
};
ng.parser.Utils.relaxFnApply = function(fn,args) {
	var argsLen = args.length;
	if(!ng.parser.Utils.isFunction(fn)) throw "Not a funciton";
	switch(argsLen) {
	case 5:
		return fn(args[0],args[1],args[2],args[3],args[4]);
	case 4:
		return fn(args[0],args[1],args[2],args[3]);
	case 3:
		return fn(args[0],args[1],args[2]);
	case 2:
		return fn(args[0],args[1]);
	case 1:
		return fn(args[0]);
	case 0:
		return fn();
	default:
		throw "Uknown function type, expecting 0 to 5 arguments";
	}
};
ng.parser.Utils.evalList = function(scope,list) {
	var length = list.length;
	var _g1 = ng.parser.Utils.evalListCache.length;
	var _g = length + 1;
	while(_g1 < _g) {
		var cacheLength = _g1++;
		ng.parser.Utils.evalListCache.push(new Array());
	}
	var result = ng.parser.Utils.evalListCache[length];
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		result[i] = list[i]["eval"](scope);
	}
	return result;
};
ng.parser.Utils.isFunction = function(f) {
	var type = typeof f;
	return type == "function";
};
ng.parser.Utils.isMap = function(m) {
	return m.set != null && m.get != null;
};
ng.parser.Utils.isPrivate = function(instance,fieldName) {
	return false;
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.prototype.__class__ = Array;
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
ng.parser.DynamicParserBackend.callScopeConstructors = (function($this) {
	var $r;
	var _g = new haxe.ds.IntMap();
	_g.set(0,function(n,a,c) {
		return new ng.parser.EvalCallScopeFast0(n,a,c.lookupFunction(n,0));
	});
	_g.set(1,function(n,a,c) {
		return new ng.parser.EvalCallScopeFast1(n,a,c.lookupFunction(n,1));
	});
	$r = _g;
	return $r;
}(this));
ng.parser.DynamicParserBackend.callMemberConstructors = (function($this) {
	var $r;
	var _g = new haxe.ds.IntMap();
	_g.set(0,function(o,n,a,c) {
		return new ng.parser.EvalCallMemberFast0(o,n,a,c.lookupFunction(n,0));
	});
	_g.set(1,function(o,n,a,c) {
		return new ng.parser.EvalCallMemberFast1(o,n,a,c.lookupFunction(n,1));
	});
	$r = _g;
	return $r;
}(this));
ng.parser.DynamicParserImpl.EOF = new ng.parser.Token(-1,null);
ng.parser._Lexer.Symbols._EOF = 0;
ng.parser._Lexer.Symbols._TAB = 9;
ng.parser._Lexer.Symbols._LF = 10;
ng.parser._Lexer.Symbols._VTAB = 11;
ng.parser._Lexer.Symbols._FF = 12;
ng.parser._Lexer.Symbols._CR = 13;
ng.parser._Lexer.Symbols._SPACE = 32;
ng.parser._Lexer.Symbols._BANG = 33;
ng.parser._Lexer.Symbols._DQ = 34;
ng.parser._Lexer.Symbols._DOLLAR = 36;
ng.parser._Lexer.Symbols._PERCENT = 37;
ng.parser._Lexer.Symbols._AMPERSAND = 38;
ng.parser._Lexer.Symbols._SQ = 39;
ng.parser._Lexer.Symbols._LPAREN = 40;
ng.parser._Lexer.Symbols._RPAREN = 41;
ng.parser._Lexer.Symbols._STAR = 42;
ng.parser._Lexer.Symbols._PLUS = 43;
ng.parser._Lexer.Symbols._COMMA = 44;
ng.parser._Lexer.Symbols._MINUS = 45;
ng.parser._Lexer.Symbols._PERIOD = 46;
ng.parser._Lexer.Symbols._SLASH = 47;
ng.parser._Lexer.Symbols._COLON = 58;
ng.parser._Lexer.Symbols._SEMICOLON = 59;
ng.parser._Lexer.Symbols._LT = 60;
ng.parser._Lexer.Symbols._EQ = 61;
ng.parser._Lexer.Symbols._GT = 62;
ng.parser._Lexer.Symbols._QUESTION = 63;
ng.parser._Lexer.Symbols._0 = 48;
ng.parser._Lexer.Symbols._9 = 57;
ng.parser._Lexer.Symbols._A = 65;
ng.parser._Lexer.Symbols._B = 66;
ng.parser._Lexer.Symbols._C = 67;
ng.parser._Lexer.Symbols._D = 68;
ng.parser._Lexer.Symbols._E = 69;
ng.parser._Lexer.Symbols._F = 70;
ng.parser._Lexer.Symbols._G = 71;
ng.parser._Lexer.Symbols._H = 72;
ng.parser._Lexer.Symbols._I = 73;
ng.parser._Lexer.Symbols._J = 74;
ng.parser._Lexer.Symbols._K = 75;
ng.parser._Lexer.Symbols._L = 76;
ng.parser._Lexer.Symbols._M = 77;
ng.parser._Lexer.Symbols._N = 78;
ng.parser._Lexer.Symbols._O = 79;
ng.parser._Lexer.Symbols._P = 80;
ng.parser._Lexer.Symbols._Q = 81;
ng.parser._Lexer.Symbols._R = 82;
ng.parser._Lexer.Symbols._S = 83;
ng.parser._Lexer.Symbols._T = 84;
ng.parser._Lexer.Symbols._U = 85;
ng.parser._Lexer.Symbols._V = 86;
ng.parser._Lexer.Symbols._W = 87;
ng.parser._Lexer.Symbols._X = 88;
ng.parser._Lexer.Symbols._Y = 89;
ng.parser._Lexer.Symbols._Z = 90;
ng.parser._Lexer.Symbols._LBRACKET = 91;
ng.parser._Lexer.Symbols._BACKSLASH = 92;
ng.parser._Lexer.Symbols._RBRACKET = 93;
ng.parser._Lexer.Symbols._CARET = 94;
ng.parser._Lexer.Symbols._UNDERSCORE = 95;
ng.parser._Lexer.Symbols._a = 97;
ng.parser._Lexer.Symbols._b = 98;
ng.parser._Lexer.Symbols._c = 99;
ng.parser._Lexer.Symbols._d = 100;
ng.parser._Lexer.Symbols._e = 101;
ng.parser._Lexer.Symbols._f = 102;
ng.parser._Lexer.Symbols._g = 103;
ng.parser._Lexer.Symbols._h = 104;
ng.parser._Lexer.Symbols._i = 105;
ng.parser._Lexer.Symbols._j = 106;
ng.parser._Lexer.Symbols._k = 107;
ng.parser._Lexer.Symbols._l = 108;
ng.parser._Lexer.Symbols._m = 109;
ng.parser._Lexer.Symbols._n = 110;
ng.parser._Lexer.Symbols._o = 111;
ng.parser._Lexer.Symbols._p = 112;
ng.parser._Lexer.Symbols._q = 113;
ng.parser._Lexer.Symbols._r = 114;
ng.parser._Lexer.Symbols._s = 115;
ng.parser._Lexer.Symbols._t = 116;
ng.parser._Lexer.Symbols._u = 117;
ng.parser._Lexer.Symbols._v = 118;
ng.parser._Lexer.Symbols._w = 119;
ng.parser._Lexer.Symbols._x = 120;
ng.parser._Lexer.Symbols._y = 121;
ng.parser._Lexer.Symbols._z = 122;
ng.parser._Lexer.Symbols._LBRACE = 123;
ng.parser._Lexer.Symbols._BAR = 124;
ng.parser._Lexer.Symbols._RBRACE = 125;
ng.parser._Lexer.Symbols._TILDE = 126;
ng.parser._Lexer.Symbols._NBSP = 160;
ng.parser.Scanner.OPERATORS = ["undefined","null","true","false","+","-","*","/","~/","%","^","=","==","!=","<",">","<=",">=","&&","||","&","|","!","?"];
ng.parser.Utils.evalListCache = new Array();
RunTests.main();
})();
