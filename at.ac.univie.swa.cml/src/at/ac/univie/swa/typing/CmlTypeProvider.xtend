package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Actor
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CallerExpression
import at.ac.univie.swa.cml.CasePart
import at.ac.univie.swa.cml.CastedExpression
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlFactory
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.Constraint
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EnsureStatement
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelection
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NestedExpression
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
import com.google.inject.Inject
import at.ac.univie.swa.cml.OtherOperatorExpression
import at.ac.univie.swa.cml.Closure
import at.ac.univie.swa.cml.Attribute

class CmlTypeProvider {
	@Inject extension CmlLib
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance

	public static val BOOLEAN_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Boolean"]
	public static val STRING_TYPE = CmlFactory::eINSTANCE.createClass => [name = "String"]
	public static val NUMBER_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Number"]
	public static val INTEGER_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Integer"]
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
				e.getCmlPartyClass
			ThisExpression:
				e.containingClass
			SuperExpression:
				e.containingClass.superclassOrObject
			SymbolReference:
				e.symbol.inferType
			NullLiteral:
				NULL_TYPE
			StringLiteral:
				STRING_TYPE
			BooleanLiteral:
				BOOLEAN_TYPE
			IntegerLiteral:
				INTEGER_TYPE
			RealLiteral:
				REAL_TYPE
			DateTimeLiteral:
				DATETIME_TYPE
			DurationLiteral:
				DURATION_TYPE
			OrExpression,
			AndExpression,
			EqualityExpression,
			RelationalExpression:
				BOOLEAN_TYPE
			AdditiveExpression: {
				val type = e.left.typeFor
				if (type.isConformant(INTEGER_TYPE))
					INTEGER_TYPE
				else if(type.isConformant(REAL_TYPE)) REAL_TYPE else UNDEFINED_TYPE
			}
			MultiplicativeExpression: {
				val type = e.left.typeFor
				if (type.isConformant(INTEGER_TYPE))
					INTEGER_TYPE
				else if(type.isConformant(REAL_TYPE)) REAL_TYPE else UNDEFINED_TYPE
			}
			UnaryExpression:
				switch (e.op) {
					case ('not'),
					case ('!'):
						BOOLEAN_TYPE
					case ('+'),
					case ('-'): {
						val type = e.operand.typeFor
						if (type.isConformant(INTEGER_TYPE))
							INTEGER_TYPE
						else if(type.isConformant(REAL_TYPE)) REAL_TYPE else UNDEFINED_TYPE
					}
				}
			AssignmentExpression:
				e.left.typeFor
			FeatureSelection:
				e.feature.inferType
			CastedExpression:
				e.type
			NestedExpression:
				e.child.typeFor
			OtherOperatorExpression: {
				val left = e.left
				val right = e.right
				if (e.op == "=>") {
					if (right instanceof Closure) {
						if (left instanceof SymbolReference) {
							val symbol = left.symbol
							if (symbol instanceof Class) {
								symbol
							}
						}
					}
				}
			}
			Attribute:
				e.expression.typeFor
			default:
				UNDEFINED_TYPE
		}
	}

	def Type expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature
		switch (c) {
			Actor case f == ep.actor_Party:
				c.getCmlPartyClass
			SymbolReference case f == ep.symbolReference_Args: {
				var symbol = c.symbol
				if (symbol instanceof Operation) {
					try {
						symbol.params.get(c.args.indexOf(e)).type
					} catch (Throwable t) {
						null // otherwise there is no specific expected type
					}
				} else if (symbol instanceof Class) {
					try {
						symbol.classHierarchyAttributes.values.get(c.args.indexOf(e)).type
					} catch (Throwable t) {
						null // otherwise there is no specific expected type
					}
				}
			}
			EnsureStatement case f == ep.ensureStatement_ThrowExpression:
				ERROR_TYPE
			ThrowStatement case f == ep.throwStatement_Expression:
				ERROR_TYPE
			AssignmentExpression case f == ep.assignmentExpression_Right:
				c.left.typeFor
			Constraint case f == ep.constraint_Expression,
			case f == ep.forStatement_Condition,
			case f == ep.doWhileStatement_Condition,
			case f == ep.whileStatement_Condition,
			case f == ep.ensureStatement_Condition,
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
			Attribute case f == ep.attribute_Expression:
				c.type.inferType
			CasePart case f == ep.casePart_Case:
				c.containingSwitch.declaration.typeFor
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
			NestedExpression:
				c.child.typeFor
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
			case "transaction": getCmlTransactionClass(c)
			case "enum": getCmlEnumClass(c)
			case "contract": getCmlContractClass(c)
			default: c.superclass ?: getCmlAnyClass(c)
		}

	}

}
