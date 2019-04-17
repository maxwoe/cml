package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CallerExpression
import at.ac.univie.swa.cml.CastedExpression
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlFactory
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EnsureStatement
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelection
import at.ac.univie.swa.cml.ImpliesExpression
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NullLiteral
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.PeriodicTime
import at.ac.univie.swa.cml.RealLiteral
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.SymbolReference
import at.ac.univie.swa.cml.ThisExpression
import at.ac.univie.swa.cml.ThrowStatement
import at.ac.univie.swa.cml.TimeConstraint
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.cml.XorExpression
import com.google.inject.Inject

class CmlTypeProvider {
	@Inject extension CmlLib
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance
	
	public static val STRING_TYPE = CmlFactory::eINSTANCE.createClass => [name = "String"]
	public static val INTEGER_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Integer"]
	public static val BOOLEAN_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Boolean"]
	public static val REAL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Real"]
	public static val DATETIME_TYPE = CmlFactory::eINSTANCE.createClass => [name = "DateTime"]
	public static val DURATION_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Duration"]
	public static val NULL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "null"]
	public static val VOID_TYPE = CmlFactory::eINSTANCE.createClass => [name = "void"]
	public static val ERROR_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Error"]
	public static val UNDEFINED_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Undefined"]

	val ep = CmlPackage::eINSTANCE

	def Type typeFor(Expression e) {
		switch (e) {
			CallerExpression: 
				return e.getCmlPartyClass()
			ThisExpression:
				return e.containingClass
			SuperExpression:
				return e.containingClass.superclassOrObject
			SymbolReference: 
				return e.symbol.inferType				
			NullLiteral:
				return NULL_TYPE
			StringLiteral:
				return STRING_TYPE
			BooleanLiteral:
				return BOOLEAN_TYPE
			IntegerLiteral:
				return INTEGER_TYPE
			RealLiteral:
				return REAL_TYPE
			DateTimeLiteral:
				return DATETIME_TYPE
			DurationLiteral:
				return DURATION_TYPE
			XorExpression,
			OrExpression,
			AndExpression,
			EqualityExpression,
			RelationalExpression,
			ImpliesExpression:
				return BOOLEAN_TYPE
			AdditiveExpression: {
				val type = e.left.typeFor
				if (type.isConformant(INTEGER_TYPE))
					return INTEGER_TYPE
				else if(type.isConformant(REAL_TYPE)) return REAL_TYPE else return UNDEFINED_TYPE
			}
			MultiplicativeExpression: {
				val type = e.left.typeFor
				if (type.isConformant(INTEGER_TYPE))
					return INTEGER_TYPE
				else if(type.isConformant(REAL_TYPE)) return REAL_TYPE else return UNDEFINED_TYPE
			}
			UnaryExpression: 
				switch (e.op) {
					case ('not'),
					case ('!'):
						return BOOLEAN_TYPE
					case ('+'),
					case ('-'): {
						val type = e.operand.typeFor
						if(type.isConformant(INTEGER_TYPE)) return INTEGER_TYPE else if(type.
							isConformant(REAL_TYPE)) return REAL_TYPE else return UNDEFINED_TYPE
					}
				}
			AssignmentExpression:
				return e.left.typeFor
			FeatureSelection: 
				return e.feature.inferType
			CastedExpression:
				return e.type
			
		}
	}
	
//	def deriveVarType(Type t) {
//		switch (t) {
//			Class case /*t.isConformant(t.cmlCollectionClass)*/ t.conformsToSet,
//			Class case /*t.isConformant(t.cmlArrayClass)*/t.conformsToArray : return t.typeVars.get(0).type
//			Class case /*t.isConformant(t.cmlMapClass)*/ t.conformsToMap: return t.typeVars.get(1).type
//		}
//	}

	def Type expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature
		switch (c) {
			SymbolReference case f == ep.symbolReference_Args:
				try {
					(c.symbol as Operation).params.get(c.args.indexOf(e)).type
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			EnsureStatement case f == ep.ensureStatement_ThrowExpression:
				ERROR_TYPE
			ThrowStatement case f == ep.throwStatement_Expression:
				ERROR_TYPE
//			CasePart case f == ep.casePart_Case:
//				c.containingSwitch.^switch.typeFor
			AssignmentExpression case f == ep.assignmentExpression_Right:
				c.left.typeFor
//			case f == ep.repeatLoop_Condition,
//			case f == ep.whileLoop_Condition,
			case f == ep.ensureStatement_Expression,
			case f == ep.ifStatement_Condition:
				BOOLEAN_TYPE
			AdditiveExpression case f == ep.additiveExpression_Right:
				c.left.typeFor
			MultiplicativeExpression case f == ep.multiplicativeExpression_Right:
				c.left.typeFor
			VariableDeclaration:
				c.type
			ReturnStatement:
				c.containingOperation.type
			PeriodicTime case f == ep.periodicTime_Start,
			PeriodicTime case f == ep.periodicTime_End,
			TimeConstraint case f == ep.timeConstraint_Reference:
				DATETIME_TYPE
			PeriodicTime case f == ep.periodicTime_Period,
			TimeConstraint case f == ep.timeConstraint_Timeframe:
				DURATION_TYPE
			//Attribute case f == ep.attribute_InitExp:
			//	c.type.inferType			
			RelationalExpression case f == ep.relationalExpression_Right:
				c.left.typeFor
			EqualityExpression case f == ep.equalityExpression_Right:
				c.left.typeFor
			FeatureSelection case f == ep.featureSelection_Args: {
				// assume that it refers to a method and that there
				// is a parameter corresponding to the argument
				try {
					(c.feature as Operation).params.get(c.args.indexOf(e)).type
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			}
		}
	}

	def isPrimitive(Type c) {
		c instanceof Class && (c as Class).eResource === null
	}
	
	def getSuperclassOrObject(Class c) {
		switch (c.kind) {
			case "party": getCmlPartyClass(c)
			case "asset": getCmlAssetClass(c)
			case "event": getCmlEventClass(c)
			case "enum": getCmlEnumClass(c)
			case "contract": getCmlContractClass(c)
			default: c.superclass ?: getCmlAnyClass(c)
		}
		
	}
	
}
