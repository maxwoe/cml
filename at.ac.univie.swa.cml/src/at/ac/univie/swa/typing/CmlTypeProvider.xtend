package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlFactory
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EnumerationLiteral
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.ImpliesExpression
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MemberSelection
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NullLiteral
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.RealLiteral
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.SelfExpression
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.XorExpression
import com.google.inject.Inject
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.TimeConstraint
import at.ac.univie.swa.cml.PeriodicTime
import at.ac.univie.swa.cml.SymbolReference
import at.ac.univie.swa.cml.Return
import at.ac.univie.swa.cml.VariableDeclaration

class CmlTypeProvider {
	@Inject extension CmlLib
	@Inject extension CmlModelUtil
	
	public static val STRING_TYPE = CmlFactory::eINSTANCE.createClass => [name = "String"]
	public static val INTEGER_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Integer"]
	public static val BOOLEAN_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Boolean"]
	public static val DATETIME_TYPE = CmlFactory::eINSTANCE.createClass => [name = "DateTime"]
	public static val DURATION_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Duration"]
	public static val REAL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Real"]
	public static val NULL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "null"]
	public static val VOID_TYPE = CmlFactory::eINSTANCE.createClass => [name = "void"]

	val ep = CmlPackage::eINSTANCE

	def Class typeFor(Expression e) {
		switch (e) {
			SelfExpression:
				return e.containingClass
			SuperExpression:
				return e.containingClass.superclassOrObject
			SymbolReference:  
				e.ref.type.typeOf
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
			EnumerationLiteral:
				return e.enumeration
			XorExpression,
			OrExpression,
			AndExpression,
			EqualityExpression,
			RelationalExpression,
			ImpliesExpression:
				return BOOLEAN_TYPE
			AdditiveExpression,
			MultiplicativeExpression:
				return INTEGER_TYPE
			UnaryExpression:
				if (e.op == "+" || e.op == "-") {
					return INTEGER_TYPE
				} else {
					return BOOLEAN_TYPE
				}
			MemberSelection:/* 
				if (e.coll !== null && e.member === null) {
					switch (e.coll) {
						case "size": return INTEGER_TYPE
						case "includes": return BOOLEAN_TYPE
						case "excludes": return BOOLEAN_TYPE
						case "count": return INTEGER_TYPE
						case "includesAll": return BOOLEAN_TYPE
						case "excludesAll": return BOOLEAN_TYPE
						case "isEmpty": return BOOLEAN_TYPE
						case "notEmpty": return BOOLEAN_TYPE
						case "sum": return INTEGER_TYPE
						case "exists": return BOOLEAN_TYPE
						case "forAll": return BOOLEAN_TYPE
						case "isUnique": return BOOLEAN_TYPE
						case "collect": return COLLECTION_TYPE
						case "select": return COLLECTION_TYPE
						case "reject": return COLLECTION_TYPE
						case "at": e.receiver.typeFor
					}
				} else if (e.coll === null && e.member !== null)*/
					e.member.typeOf
		}
	}

	def Class expectedType(Expression exp) {
		val container = exp.eContainer
		val feature = exp.eContainingFeature
		switch (container) {
			VariableDeclaration:
				container.type.typeOf
			Return:
				container.containingOperation.typeOf
			case feature == ep.ifStatement_Expression:
				BOOLEAN_TYPE
			PeriodicTime case feature == ep.periodicTime_Start,
			PeriodicTime case feature == ep.periodicTime_End,
			TimeConstraint case feature == ep.timeConstraint_Reference:
				DATETIME_TYPE
			PeriodicTime case feature == ep.periodicTime_Period,
			TimeConstraint case feature == ep.timeConstraint_Timeframe:
				DURATION_TYPE
			Attribute:
				container.type.typeOf
			RelationalExpression case feature == ep.relationalExpression_Right:
				container.left.typeFor
			EqualityExpression case feature == ep.equalityExpression_Right:
				container.left.typeFor
			MemberSelection case feature == ep.memberSelection_Args:
				// assume that it refers to a method and that there
				// is a parameter corresponding to the argument
				try {
					(container.member as Operation).params.get(container.args.indexOf(exp)).type.typeOf
				} catch (Throwable t) {
					null
				}
		}
	}

	def isPrimitive(Type c) {
		c instanceof Class && (c as Class).eResource === null
	}
	
	def getSuperclassOrObject(Class c) {
		c.superclass ?: getCmlObjectClass(c)
	}
	
}
