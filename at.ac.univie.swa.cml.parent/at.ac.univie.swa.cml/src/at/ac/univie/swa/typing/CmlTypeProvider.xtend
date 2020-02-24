package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Actor
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.Annotation
import at.ac.univie.swa.cml.AnnotationElement
import at.ac.univie.swa.cml.ArrayAccessExpression
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CasePart
import at.ac.univie.swa.cml.CastedExpression
import at.ac.univie.swa.cml.Closure
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.CmlFactory
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelectionExpression
import at.ac.univie.swa.cml.ForLoopStatement
import at.ac.univie.swa.cml.GeneralConstraint
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NestedExpression
import at.ac.univie.swa.cml.NewExpression
import at.ac.univie.swa.cml.NullLiteral
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.OtherOperatorExpression
import at.ac.univie.swa.cml.PeriodicTime
import at.ac.univie.swa.cml.RealLiteral
import at.ac.univie.swa.cml.ReferenceExpression
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.TemporalConstraint
import at.ac.univie.swa.cml.ThisExpression
import at.ac.univie.swa.cml.ThrowStatement
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.TypeVariable
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VariableDeclaration
import com.google.inject.Inject
import org.eclipse.xtext.EcoreUtil2

class CmlTypeProvider {
	@Inject extension CmlLib
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance

	public static val BOOLEAN_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Boolean"]
	public static val STRING_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "String"]
	public static val NUMBER_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Number"]
	public static val INTEGER_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Integer"]
	public static val REAL_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Real"]
	public static val DATETIME_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "DateTime"]
	public static val DURATION_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Duration"]
	public static val NULL_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "null"]
	public static val VOID_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "void"]
	public static val ERROR_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Error"]
	public static val UNDEFINED_TYPE = CmlFactory::eINSTANCE.createCmlClass => [name = "Undefined"]

	val ep = CmlPackage::eINSTANCE

	def Type typeFor(Expression e) {
		switch (e) {
			ThisExpression:
				e.containingClass
			SuperExpression:
				e.containingClass.superclassOrObject.inferType
			ReferenceExpression: {
				if(e.reference instanceof TypeVariable) {
					val forLoopStatement =  EcoreUtil2.getContainerOfType(e, ForLoopStatement)
					forLoopStatement.forExpression.resolveArrayRefAttrType
				} else e.reference.inferType(e)
			}
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
			FeatureSelectionExpression:
				e.feature.inferType(e)
			CastedExpression:
				e.type.inferType
			NestedExpression:
				e.child.typeFor
			OtherOperatorExpression: {
				val left = e.left
				val right = e.right
				if (e.op == "=>") {
					if (right instanceof Closure) {
						if (left instanceof ReferenceExpression) {
							val symbol = left.reference
							if (symbol instanceof CmlClass) {
								symbol
							}
						}
					}
				}
			}
			Attribute:
				e.expression.typeFor
			NewExpression:
				e.type.inferType
			ArrayAccessExpression: {
				val array = e.array
				array.resolveArrayRefAttrType
			}
			default:
				UNDEFINED_TYPE
		}
	}

	def Type expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature
		switch (c) {
			//Actor case f == ep.actor_Party:
			//	c.getCmlPartyClass
			ReferenceExpression case f == ep.referenceExpression_Args: {
				val reference = c.reference
				if (reference instanceof Operation) {
					try {
						reference.params.get(c.args.indexOf(e)).inferType
					} catch (Throwable t) {
						null // otherwise there is no specific expected type
					}
				}
			}
			NewExpression: {
				val type = c.type
				if (type instanceof CmlClass) {
					try {
						type.classHierarchyAttributes.values.get(c.args.indexOf(e)).inferType
					} catch (Throwable t) {
						null // otherwise there is no specific expected type
					}
				}
			}
			ThrowStatement case f == ep.throwStatement_Expression:
				ERROR_TYPE
			AssignmentExpression case f == ep.assignmentExpression_Right:
				c.left.typeFor
			GeneralConstraint case f == ep.generalConstraint_Expression,
			case f == ep.forBasicStatement_Condition,
			case f == ep.doWhileStatement_Condition,
			case f == ep.whileStatement_Condition,
			case f == ep.ifStatement_Condition:
				BOOLEAN_TYPE
			AdditiveExpression case f == ep.additiveExpression_Right:
				c.left.typeFor
			MultiplicativeExpression case f == ep.multiplicativeExpression_Right:
				c.left.typeFor
			VariableDeclaration:
				c.inferType(e)
			ReturnStatement:
				c.containingOperation.inferType(e)
			PeriodicTime case f == ep.periodicTime_Start,
			PeriodicTime case f == ep.periodicTime_End,
			TemporalConstraint case f == ep.temporalConstraint_Reference:
				DATETIME_TYPE
			PeriodicTime case f == ep.periodicTime_Period,
			TemporalConstraint case f == ep.timeframe_Window:
				DURATION_TYPE
			Attribute case f == ep.attribute_Expression:
				c.inferType(e)
			CasePart case f == ep.casePart_Case:
				c.containingSwitch.declaration.typeFor
			RelationalExpression case f == ep.relationalExpression_Right:
				c.left.typeFor
			EqualityExpression case f == ep.equalityExpression_Right:
				c.left.typeFor
			FeatureSelectionExpression case f == ep.featureSelectionExpression_Args: {
				// assume that it refers to a method and that there
				// is a parameter corresponding to the argument
				try {
					(c.feature as Operation).params.get(c.args.indexOf(e)).inferType(e)
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			}
			AnnotationElement case f == ep.annotationElement_Value: {
				try {
					(c.eContainer as Annotation).declaration.features.findFirst[it.name == c.param.name].inferType(e)
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			}
			ArrayAccessExpression case f == ep.arrayAccessExpression_Indexes: {
				try {
					val type = (c.typeFor as CmlClass)
					if (type.identifiable) {
						type.resolveIdentifierType
					} else {
						INTEGER_TYPE
					}
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			}
			ArrayAccessExpression:
				c.array.typeFor
			NestedExpression:
				c.child.typeFor
			ForLoopStatement case f == ep.forLoopStatement_ForExpression:
				c.cmlCollectionClass
		}
	}

	def getSuperclassOrObject(CmlClass c) {
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
