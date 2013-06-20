package hxrm.analyzer;

import hxrm.parser.Tools;
import hxrm.analyzer.initializers.IInitializator;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;

class NodeScope {

	public var context : AnalyzerContext;

	public var type:Type;
	public var classType:ClassType;

	public var classFields:Map<String, ClassField>;

	public var initializers : Map<String, IInitializator>;
	
	public var children : Array<NodeScope>;

	public function new() {
	}

	inline public function getFieldByName(name : String) : ClassField {
		return classFields != null ? classFields.get(name) : null;
	}
}