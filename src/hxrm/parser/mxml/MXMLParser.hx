package hxrm.parser.mxml;

import hxrm.parser.mxml.attributes.NamespaceAttributeMatcher;
import hxrm.parser.mxml.attributes.IAttributeMatcher;
import hxrm.parser.Tools;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class MXMLParser
{
	public function new() 
	{
	}
	
	// TODO Should it realy be a field?
	var xml:Xml;
	
	public function parse(data:String):Null<MXMLNode> {
		
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			throw new ParserError(UNKNOWN_DATA_FORMAT, { pos : { to : 0 , from : 0 } });
		}
		
		return parseRootNode(xml); // haxe.xml.Fast ?
	}
	
	function parseRootNode(node : Xml):Null<MXMLNode>  {
		var firstElement = node.firstElement();
		
		if (firstElement == null) {
			throw new ParserError(EMPTY_DATA, { pos : { to : 0 , from : 0 } });
		}
		
		return parseNode(firstElement);
	}

	// root - первый нод в xml
	function parseNode(xmlNode : Xml):Null<MXMLNode>  {
	
		// do magic here
		var n = new MXMLNode();
		n.name = QName.fromString(xmlNode.nodeName);

		parseAttributes(xmlNode, n);
		parseChildren(xmlNode, n);

		return n;
	}
	
	function parseChildren(xmlNode:Xml, n:MXMLNode) {
		//TODO inner property setters
		for (c in xmlNode.elements()) {
			n.children.push(parseNode(c));
		}
	}
	
	function parseAttributes(xmlNode:Xml, n:MXMLNode) {
		for (attributeName in xmlNode.attributes()) {
			
			var attributeQName = QName.fromString(attributeName);
			var value = xmlNode.get(attributeName);
			
			//TODO support for external matchers
			var matchers : Array<IAttributeMatcher> = [new NamespaceAttributeMatcher()];
			var matchersIterator : Iterator<IAttributeMatcher> = matchers.iterator();

			if(!matchersIterator.hasNext() || !matchersIterator.next().matchAttribute(attributeQName, value, n, matchersIterator)) {
				n.values.set(attributeQName, value);
			}
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
}