package hxrm.parser;
class QName {

	public static inline var HAXE_ID_GLUE : String = ".";
	public static inline var QUALIFIED_ID_GLUE : String = ":";
	public static inline var ASTERISK : String = "*";

	public var namespace : String;
	public var localPart : String;
	
	public function new(namespace : String, localPart : String) {
		this.namespace = namespace == null ? ASTERISK : namespace;
		this.localPart = localPart;
	}

	public function toString() : String {
		return '$namespace$QUALIFIED_ID_GLUE$localPart';
	}

	public function toHaxeTypeId() : String {
		return if(namespace == ASTERISK) localPart;
				else '$namespace.$localPart';
	}

	public function hashCode() : Int {
		var haxeTypeId : String = toHaxeTypeId();
		
		var hash = 5381;
		for( i in 0...haxeTypeId.length) {
			hash = ((hash<<5)+hash)+haxeTypeId.charCodeAt(i);
		}
		return hash;
	}
}