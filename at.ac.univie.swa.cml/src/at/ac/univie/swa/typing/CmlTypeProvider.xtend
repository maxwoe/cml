package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CasePart
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
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NullLiteral
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.PeriodicTime
import at.ac.univie.swa.cml.RealLiteral
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.Return
import at.ac.univie.swa.cml.SelfExpression
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
//import at.ac.univie.swa.cml.SymbolReference
import at.ac.univie.swa.cml.TimeConstraint
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.cml.XorExpression
import com.google.inject.Inject
import at.ac.univie.swa.cml.MemberFeatureCall
import at.ac.univie.swa.cml.ElementReferenceExpression
import at.ac.univie.swa.cml.SymbolReference
import org.eclipse.xtext.naming.IQualifiedNameProvider

class CmlTypeProvider {
	@Inject extension CmlLib
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance
	@Inject extension IQualifiedNameProvider
	
	public static val STRING_TYPE = CmlFactory::eINSTANCE.createClass => [name = "String"]
	public static val INTEGER_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Integer"]
	public static val BOOLEAN_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Boolean"]
	public static val REAL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Real"]
	public static val DATETIME_TYPE = CmlFactory::eINSTANCE.createClass => [name = "DateTime"]
	public static val DURATION_TYPE = CmlFactory::eINSTANCE.createClass => [name = "Duration"]
	public static val NULL_TYPE = CmlFactory::eINSTANCE.createClass => [name = "null"]
	public static val VOID_TYPE = CmlFactory::eINSTANCE.createClass => [name = "void"]

	val ep = CmlPackage::eINSTANCE

	def Type typeFor(Expression e) {
		switch (e) {
			SelfExpression:
				return e.containingClass
			SuperExpression:
				return e.containingClass.superclassOrObject
			SymbolReference:
				return e.ref.type.inferType
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
			AdditiveExpression:
				e.left.typeFor
			MultiplicativeExpression:
				e.left.typeFor
			UnaryExpression:
				if (e.op == "-") {
					return e.operand.typeFor
				} else {
					return BOOLEAN_TYPE
				}
			AssignmentExpression:
				e.left.typeFor
			ElementReferenceExpression: 
				if (e.elementAccess) {
					return e.reference.typeFor.deriveVarType
				} else return e.reference.typeFor
			MemberFeatureCall: {
				if (e.elementAccess) {
					return e.member.inferType.deriveVarType
				}
				return e.member.inferType
			}
			
		}
	}
	
	def deriveVarType(Type t) {
		switch (t) {
			Class case t.isConformant(t.cmlCollectionClass),
			Class case t.isConformant(t.cmlArrayClass) : return t.typeVars.get(0).type
			Class case t.isConformant(t.cmlMapClass): return t.typeVars.get(1).type
		}
	}

	def Type expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature
		switch (c) {	
			//ElementReferenceExpression:
			//	c.reference.typeFor
			CasePart case f == ep.casePart_Case:
				c.containingSwitch.^switch.typeFor
			AssignmentExpression case f == ep.assignmentExpression_Right:
				c.left.typeFor
			case f == ep.repeatLoop_Condition,
			case f == ep.whileLoop_Condition,
			case f == ep.if_Condition:
				BOOLEAN_TYPE
			AdditiveExpression case f == ep.additiveExpression_Right:
				c.left.typeFor
			MultiplicativeExpression case f == ep.multiplicativeExpression_Right:
				c.left.typeFor
			VariableDeclaration:
				c.type.inferType
			Return:
				c.containingOperation.inferType
			PeriodicTime case f == ep.periodicTime_Start,
			PeriodicTime case f == ep.periodicTime_End,
			TimeConstraint case f == ep.timeConstraint_Reference:
				DATETIME_TYPE
			PeriodicTime case f == ep.periodicTime_Period,
			TimeConstraint case f == ep.timeConstraint_Timeframe:
				DURATION_TYPE
			Attribute case f == ep.attribute_InitExp:
				c.type.inferType
			case f == ep.if_ElseBlock,
			case f == ep.if_ThenBlock:	{
				var cc = c.eContainer
				switch(cc) {
					Attribute: cc.type.inferType
				}
			}				
			RelationalExpression case f == ep.relationalExpression_Right:
				c.left.typeFor
			EqualityExpression case f == ep.equalityExpression_Right:
				c.left.typeFor
			MemberFeatureCall case f == ep.memberFeatureCall_Args:
				try {
					(c.member as Operation).params.get(c.args.indexOf(e)).type.inferType
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
