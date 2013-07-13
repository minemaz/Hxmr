package hxrm.generator.extensions;

import hxrm.analyzer.initializers.IItor;
import haxe.macro.Context;
import haxe.macro.Type;
import hxrm.HxmrContext;
import hxrm.generator.GeneratorScope;
import haxe.macro.Context;
import hxrm.analyzer.NodeScope;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.BaseType;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;

class InitializersGeneratorExtension extends GeneratorExtensionBase {

	public override function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		if(scope.ctor == null) {
			return true;
		}
		
		processScope(context, scope, scope.context.node, scope.ctorExprs, "this");

		return false;
	}

	function processScope(context : HxmrContext, scope : GeneratorScope, nodeScope : NodeScope, exprs : Array<Expr>, forField : String) : Void {

        for (field in nodeScope.fields) {
            parseFieldInitializator(context, scope, field.name, field.type);
        }

        for (fieldName in nodeScope.initializers.keys()) {

            var res = parseBindingInitializator(context, scope, nodeScope, fieldName, nodeScope.initializers.get(fieldName), exprs);
            exprs.push(macro $i{forField}.$fieldName = $res);
        }
    }

    function parseFieldInitializator(context : HxmrContext, scope : GeneratorScope, fieldName : String, fieldType : Type) : Void {

        var fieldComplexType : ComplexType = Context.toComplexType(fieldType);

        var field : Field = {
            name : fieldName,
            doc : null,//"autogenerated NodeScope field " + initializator.type,
            access : [APublic],
            pos : scope.context.pos,
            kind : FVar(fieldComplexType)
        };
        scope.typeDefinition.fields.unshift(field);
    }

    function parseBindingInitializator(context:HxmrContext, scope:GeneratorScope, nodeScope : NodeScope, fieldName : String, iitor : IItor, exprs : Array<Expr>) : Expr {

        return switch(iitor) {
            case InitValue(itor):
                var value = getValue(scope, itor.value);
                macro $value;

            case InitArray(itor):
                var values : Array<Expr> = [];
                for(childInit in itor.value) {
                    values.push(parseBindingInitializator(context, scope, nodeScope, childInit.name, childInit.itor, exprs));
                }
                {
                    expr : EArrayDecl(values),
                pos : Context.currentPos()
                };

            case InitNodeScope(itor):
                var exprs : Array<Expr> = [];

                generateInitFunction(context, scope, fieldName, itor.value, exprs);

                var initFunctionName = generateInitializerName(fieldName);
                macro $i { initFunctionName } ();
        }
    }

    function generateInitFunction(context:HxmrContext, scope:GeneratorScope, fieldName : String, initScope : NodeScope, exprs : Array<Expr>) : Void {

        var funName = generateInitializerName(fieldName);
        for(field in scope.typeDefinition.fields) {
            if(field.name == funName) {
                return;
            }
        }

        exprs.push(macro if($i { fieldName } != null) return $i {fieldName});

        var ctor = {
            expr : ENew({
                    name : initScope.typeName.className,
                    pack : initScope.typeName.packageNameParts,
                    params : []
                },
                []
            ),
            pos : scope.context.pos
        }

        var assignTarget = macro $i {fieldName};
        exprs.push(macro $assignTarget = ${ctor});

        processScope(context, scope, initScope, exprs, fieldName);

        exprs.push(macro return $i { fieldName });

        var initFunction : Field = {
            name: funName,
            doc: null,//'"autogenerated NodeScope init function",
            access: [APrivate],
            pos: scope.context.pos,
            kind: FFun({
                args:[],
                ret:null,
                params:[],
                expr: {
                    expr : EBlock(exprs),
                    pos : scope.context.pos
                }
            })
        }
        scope.typeDefinition.fields.push(initFunction);
    }

    function getValue(scope : GeneratorScope, value : Dynamic) : Expr {
        try {
            return Context.parse(value, scope.context.pos);
        } catch (e:Dynamic) {
            trace(e);
            //TODO throw " can't parse value: " + e;
        }
        return null;
    }

    inline function generateInitializerName(fieldName : String) : String {
        return "init_" + fieldName;
    }

    function getBaseType(type : haxe.macro.Type) : BaseType {
        if(type == null) {
            throw "type is null!";
        }
        return switch(type) {
            case TAbstract( t, _ ):
                t.get();
            case TInst(t, _):
                t.get();
            case TDynamic(t):
                getBaseType(t);
            case TEnum(t, _):
                t.get();
            case _: throw "unknown base type of: " + type;
        }
    }

}
