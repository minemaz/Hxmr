package hxrm.generator.macro;

import hxrm.analyzer.NodeScope;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;

using StringTools;
using haxe.macro.Tools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TypeDefenitionGenerator
{
	
	public function new() 
	{
	}
	
	public function write(n:MXMLNode, type:String, file:String):TypeDefinition {

		trace('write:$type');
		var s = new NodeScope(n);
		trace(s);
		
		var pack = type.split(".");
		var name = pack.pop();
		
		var superTypeParams = [];
		for (tp in n.typeParams) {
			superTypeParams.push(getTypePath(s.getType(tp)));
		}
		trace(superTypeParams);
		var superClass:TypePath = getTypePath(s.type);
		trace(superClass);
		var params = [];
		var fields = [];
		
		return {
			pack: pack,
			name: name,
			pos: Context.makePosition( { min:0, max:0, file:file } ),
			meta: [],
			params: params,
			isExtern: false,
			kind: TDClass(superClass, null, false),
			fields:fields
		}
	}
	
	public function cleanCache():Void {
		
	}

	public function getTypePath(t:Type):TypePath {
		var ct = Context.toComplexType(t);
		trace(ct);
		if (ct == null) {
			trace("can't get CT of " + t); // TODO:
			return null;
		}
		switch (ct) {
			case TPath(p): return p;
			case _: trace(ct);  return null;
		}
	}
	
}