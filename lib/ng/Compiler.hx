package ng;

private typedef CompositeLinkFn = Dynamic;

private typedef TokenFn = {
  ?fn: Dynamic,
  ?scope: Dynamic,
  ?transclude: Bool,
  ?terminal: Bool,
  ?isolate: Bool,
  ?isolateScope: Dynamic
};

class Compiler {

  public static var previousCompileContext;

  public static function compile(nodes:js.html.NodeList, ?transcludeFn) {
    var compositeLinkToken = compileNodes(nodes, transcludeFn, nodes);

    return function publicLinkFn(scope, ?cloneConnectFn) {
      var linkNode = (cloneConnectFn != null) ? nodes : nodes;
      if (cloneConnectFn != null) cloneConnectFn(linkNode, scope);
      if (compositeLinkToken != null) compositeLinkToken.fn(scope, linkNode, linkNode);

      return linkNode;
    };

  }

  public static inline function debugger() {
    untyped __js__('debugger');
  }

  public static function compileNodes(nodeList:js.html.NodeList, transcludeFn, rootElement: Dynamic):TokenFn {
    var linkTokens = new Array<TokenFn>();
    var linkFnFound = false;
    var attrs = null;
    for (i in 0...nodeList.length) {

      var directives = collectDirectives(nodeList[i], [], attrs);
      var nodeLinkToken = (directives.length > 0) ?
        applyDirectivesToNode(directives, nodeList[i], attrs, transcludeFn, rootElement) :
        null;
      if (nodeLinkToken != null && nodeLinkToken.scope != null) {
        // nodeList[i].safeAddClass('ng-scope');
      }
      var childNodes;
      var childLinkToken = (nodeLinkToken != null && nodeLinkToken.terminal == true ||
        (childNodes = nodeList[i].childNodes) == null || 
        childNodes.length == 0)
        ? null
        : compileNodes(childNodes, (nodeLinkToken != null)?nodeLinkToken.transclude : transcludeFn, nodeList[i]);
      linkTokens.push(nodeLinkToken);
      linkTokens.push(childLinkToken);
      linkFnFound = linkFnFound || (nodeLinkToken != null) || (childLinkToken != null);
      previousCompileContext = null;
    }

    function compositeLinkFn(scope:Scope, nodeList:js.html.NodeList, rootElement, boundTransludeFn) {
      
      var stableNodeList = [];
      var childScope = null;
      var nodeListLength = nodeList.length;
      for (i in 0...nodeListLength) {
        stableNodeList.push(nodeList[i]);
      }

      var i = 0;
      var n = -1;
      while (i < linkTokens.length) {
        n++;
        var nodeLinkToken = linkTokens[i++];
        var childLinkToken = linkTokens[i++];
        if (nodeLinkToken != null) {
          if (nodeLinkToken.scope != null) {
            childScope = scope.createChild(false);
          } else {
            childScope = scope;
          }
          var childTranscludeFn = nodeLinkToken.transclude;
          if (childTranscludeFn != null || (boundTransludeFn == null && transcludeFn != null)) {
            var fn;
            if (childTranscludeFn != null) {
              fn = childTranscludeFn;
            } else {
              fn = transcludeFn;
            }
            nodeLinkToken.fn(childLinkToken.fn, childScope, stableNodeList[n], rootElement, 
              createBoundTransludeFn(scope, fn)
            );
          } else {
            var childFn = null;
            if (childLinkToken != null) childFn = childLinkToken.fn;
            nodeLinkToken.fn(childFn, childScope, stableNodeList[n], rootElement, boundTransludeFn);
          }

        } else if (childLinkToken != null) {
          childLinkToken.fn(scope, stableNodeList[n].childNodes, null, boundTransludeFn);
        }

        //n++;
      }
    }

    return (linkFnFound) ? { fn: compositeLinkFn } : null; 
  }

  /*
   * - linkFn- linking fn of a single directive
   * - nodeLinkFn - all linking fns for node
   * - childLinkFn - child nodes of node
   * - compositeLinkFn - everything
   */

  public static function collectDirectives(node:js.html.Node, directives: Array<Dynamic>, attrs, ?maxPriority, ?ignoreDirective):Array<Dynamic> {
    var nodeType = node.nodeType;
    switch(nodeType) {
      case 3: // Element
        addTextInterpolateDirective(directives, node.nodeValue);
    }
    return directives;
  }

  static var startSymbol = '{{';
  static var endSymbol = '}}';
  public static function interpolate(text, mustHaveExpression) {
    var index = 0;
    var startIndex:Int = null;
    var endIndex:Int = null;
    var length = text.length;
    var parts = [];
    var hasInterpolation = false;
    while (index < length) {
      if ((startIndex = text.indexOf(startSymbol, index)) != -1 && 
            (endIndex = text.indexOf(endSymbol, startIndex + startSymbol.length)) != -1) {
        if (index != startIndex) parts.push({fn:null, exp: text.substring(index, startIndex)});
        
        var exp = text.substring(startIndex + startSymbol.length, endIndex);
        parts.push({
          fn: Parser.parse(exp).fn,
          exp: exp
        });
  
        index = endIndex + endSymbol.length;
        hasInterpolation = true;
      } else {
        if (index != length) {
          var exp = text.substring(index, length);
          parts.push({ fn: null, exp: exp});
        }
        index = length;
      }
    }
    if (parts.length == 0) {
      parts.push({
        fn: null,
        exp: ''
      });
    }
    if (!mustHaveExpression || hasInterpolation) {
      
      var fn = function (context) {
        var concat = [];
        for (part in parts) {
          if (part.fn != null) {
            concat.push(part.fn(context));
          } else if (part == null) {
            concat.push('');
          } else {
            concat.push(part.exp);
          }
        }
        return concat.join('');
      }
      return fn;
    }
    return null;
  }

  public static function addTextInterpolateDirective(directives, value):Void {
    var interpolateFn = interpolate(value, true);
    if (interpolateFn != null) {
      directives.push({
        compile: function () {
          return function (scope, node) {
            scope.watchFn(interpolateFn, function interpolateFnWatchAction(value) {
              node.nodeValue = value;
            });
          }
        }
      });
    }
  }

  public static function applyDirectivesToNode(directives:Array<Dynamic>, compileNode:js.html.Node, templateAttrs, transcludeFn, ?rootElement):TokenFn {
    var preLinkTokens = new Array<TokenFn>(), postLinkTokens = new Array<TokenFn>();
    var isolateScope = null;

    function addLinkTokens(pre:TokenFn, post:TokenFn, attrStart, attrEnd) {
      if (pre != null) {
        preLinkTokens.push(pre);
      }
      if (post != null) {
        postLinkTokens.push(post);
      }
    }

    for(directive in directives) {
      
      var attrStart = directive.start;
      var attrEnd = directive.end;

      if (directive.compile != null) {
        var linkToken = { fn: directive.compile(compileNode, templateAttrs, transcludeFn) };
        addLinkTokens(null, linkToken, attrStart, attrEnd);
      }
    }

    function nodeLinkFn(childLinkFn, scope, linkNode, rootElement, boundTranscludeFn) {
      var attrs = null;
      if (compileNode == linkNode) {
        attrs = templateAttrs;
      } else {
        // attrs = shallowCopy ...
      }

      // PRELINKING

      for (linkToken in preLinkTokens) {
        linkToken.fn((linkToken.isolateScope) ? isolateScope : scope, linkNode, attrs);
      }

      // RECURSION
      // We only pass the isolate scope, if the isolate directive has a template,
      // otherwise the child elements do not belong to the isolate directive.
      var scopeToChild = scope;
      // if (newIsolateScopeDirective && (newIsolateScopeDirective.template || newIsolateScopeDirective.templateUrl === null)) {
      //   scopeToChild = isolateScope;
      // }
      if (childLinkFn != null) {
        childLinkFn(scopeToChild, linkNode.childNodes, null, boundTranscludeFn);
      }


      // POSTLINKING

      for (linkToken in postLinkTokens) {
        linkToken.fn((false) ? isolateScope : scope, compileNode, attrs);
      }
    }
    return {
      fn: nodeLinkFn
    };
  }

  public static function createBoundTransludeFn(scope, childTranscludeFn) {
    return childTranscludeFn;
  }

}