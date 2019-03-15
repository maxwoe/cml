package at.ac.univie.swa.typing

import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.Array
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.AttributeType
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlFactory
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.Collection
import at.ac.univie.swa.cml.EnumerationLiteral
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.ImpliesExpression
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.LocalReference
import at.ac.univie.swa.cml.MemberSelection
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NullLiteral
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.Parameter
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.SelfExpression
import at.ac.univie.swa.cml.Simple
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VoidType
import at.ac.univie.swa.cml.XorExpression
import at.ac.univie.swa.lib.CmlLib
import com.google.inject.Inject

import static extension at.ac.univie.swa.util.CmlModelUtil.*

class CmlTypeProvider {
	@Inject extension CmlLib
	
	public static val stringType = CmlFactory::eINSTANCE.createClass => [name = "String"]
	public static val integerType = CmlFactory::eINSTANCE.createClass => [name = "Integer"]
	public static val booleanType = CmlFactory::eINSTANCE.createClass => [name = "Boolean"]
	public static val realType = CmlFactory::eINSTANCE.createClass => [name = "Real"]
	public static val nullType = CmlFactory::eINSTANCE.createClass => [name = "Null"]
	public static val voidType = CmlFactory::eINSTANCE.createClass => [name = "Void"]
	public static val collectionType = CmlFactory::eINSTANCE.createClass => [name = "Collection"]
	public static val arrayType = CmlFactory::eINSTANCE.createClass => [name = "Array"]

	val ep = CmlPackage::eINSTANCE

	def Type typeFor(Expression e) {
		switch (e) {
			SelfExpression:
				return e.containingClass
			SuperExpression:
				return e.containingClass.superclassOrObject
			LocalReference:
				return e.ref.typeDef.typeOf
			// NewInstanceExpression:
			// return e.type
			NullLiteral:
				return nullType
			StringLiteral:
				return stringType
			BooleanLiteral:
				return booleanType
			IntegerLiteral:
				return integerType
			// CollectionLiteral:
			// return typeFor(e.elements.head)
			EnumerationLiteral:
				return e.enumeration
			XorExpression,
			OrExpression,
			AndExpression,
			EqualityExpression,
			RelationalExpression,
			ImpliesExpression
			/* ,
			 * InstanceofExpression,
			 ComparativeExpression*/
			:
				return booleanType
			AdditiveExpression,
			MultiplicativeExpression:
				return integerType
			UnaryExpression:
				if (e.op == "+" || e.op == "-") {
					return integerType
				} else {
					return booleanType
				}
			MemberSelection:
				if (e.coll !== null && e.member === null) {
					switch (e.coll) {
						case "size": return integerType
						case "includes": return booleanType
						case "excludes": return booleanType
						case "count": return integerType
						case "includesAll": return booleanType
						case "excludesAll": return booleanType
						case "isEmpty": return booleanType
						case "notEmpty": return booleanType
						case "sum": return integerType
						case "exists": return booleanType
						case "forAll": return booleanType
						case "isUnique": return booleanType
						//case "collect": return ? // should return coll
						case "select": return e.receiver.typeFor // should return coll
						case "reject": return e.receiver.typeFor // should return coll
					}
				} else if (e.coll === null && e.member !== null)
					return e.member.type
		}
	}

	def Type expectedType(Expression exp) {
		val container = exp.eContainer
		val feature = exp.eContainingFeature
		switch (container) {
			/*AssignmentExpression case feature == ep.assignmentExpression_Right:
			 * 	container.left.typeFor
			 * BranchingStmt case feature == ep.branchingStmt_Expression:
			 booleanType*/
			RelationalExpression case feature == ep.relationalExpression_Right:
				container.left.typeFor
			EqualityExpression case feature == ep.equalityExpression_Right:
				container.left.typeFor
			MemberSelection case feature == ep.memberSelection_Args:
				// assume that it refers to a method and that there
				// is a parameter corresponding to the argument
				try {
					(container.member as Operation).args.get(container.args.indexOf(exp)).type
				} catch (Throwable t) {
					null
				}
		}
	}
	
	def dispatch Type type(Operation op) {
		switch (op.type) {
			VoidType: return nullType
			AttributeType: return (op.type as AttributeType).typeOf
		}
	}
	
	def dispatch Type type(Attribute a) {
		switch(a.typeDef) {
			Simple: a.typeDef.typeOf
			Collection: collectionType
			Array: arrayType
		}
	}

	def dispatch Type type(Parameter param) {
		return param.typeDef.typeOf
	}

	def isPrimitiveType(Type c) {
		c instanceof Class && (c as Class).eResource === null
	}

}
