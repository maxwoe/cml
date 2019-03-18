/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.validation

import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.EnumerationElement
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.MemberSelection
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.SelfExpression
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckType

import static extension at.ac.univie.swa.CmlModelUtil.*
import com.google.common.collect.HashMultimap
import at.ac.univie.swa.cml.NamedElement
import at.ac.univie.swa.cml.Model
import at.ac.univie.swa.CmlModelUtil

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CmlValidator extends AbstractCmlValidator {
	
//	public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					CmlPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}

//    @Check
//    def void checkNameStartsWithCapital(Entity entity) {
//        if (!Character.isUpperCase(entity.name.charAt(0))) {
//            warning("Name should start with a capital", 
//                CmlPackage.Literals.ENTITY__NAME)
//        }
//    }

	@Inject extension IQualifiedNameProvider
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeProvider
	@Inject extension CmlTypeConformance

	public static val HIERARCHY_CYCLE = "HIERARCHY_CYCLE_DETECTED"
	public static val DUPLICATE_CLASS = "DUPLICATE_CLASS" 
	public static val DUPLICATE_ELEMENT = "DUPLICATE_ELEMENT" 
	public static val WRONG_TYPE = "WRONG_TYPE"
	public static val PROPERTY_SELECTION_ON_METHOD = "FIELD_SELECTION_ON_METHOD"
	public static val WRONG_SUPER_USAGE = "WRONG_SUPER_USAGE"
	public static val WRONG_SELF_USAGE = "WRONG_SELF_USAGE"
	public static val MULTIPLICITY_INCONSISTENCY="MULTIPLICITY_INCONSISTENCY"
	public static val INVALID_ABSTRACT_OPERATION = "INVALID_ABSTRACT_OPERATION"
	public static val ABSTRACT_OP_INSIDE_NONABSTRACT_CLASS = "ABSTRACT_OP_INSIDE_NONABSTRACT_CLASS" 
	public static val INCOMPATIBLE_TYPES = "INCOMPATIBLE_TYPES"	
	public static val OPPOSITE_INCONSISTENCY = "OPPOSITE_INCONSISTENCY"
	public static val DECLARATION_WITHIN_BLOCK = "DECLARATION_WITHIN_BLOCK"
	
	@Check 
	def void checkClassHierarchy(Class c) {
		if (c.classHierarchy.contains(c)) {
			error("Cycle in hierarchy of Class '" + c.name + "'",
				CmlPackage::eINSTANCE.class_Superclass,
				HIERARCHY_CYCLE,
				c.superclass.name)
		}
	}

	@Check 
	def void checkNoDuplicateClasses(Model m) {
		checkNoDuplicateElements(m.classes, "class")
	}
	
	@Check 
	def void checkNoDuplicateEnumerations(Model m) {
		checkNoDuplicateElements(m.enumerations, "enumeration")
	}

	@Check 
	def void checkNoDuplicateFeatures(Class c) {
		checkNoDuplicateElements(c.attributes, "attribute")
		checkNoDuplicateElements(c.operations, "operation")
	}

	@Check 
	def void checkNoDuplicateLocals(Operation o) {
		checkNoDuplicateElements(o.args, "parameter")
	}

	@Check
	def void checkNoDuplicateEnumerationLiterals(Enumeration e) {
		checkNoDuplicateElements(e.elements, "parameter")
	}
	
	/*
	@Check
	def void checkCorrectPropertyType(Feature feature){
		switch(feature){
			Attribute: if(!(feature.typeDef.type.kind != null || feature.typeDef.type.ref instanceof Enumeration))
							error("Wrong type for Attribute '" + feature.name + "'. Should be an enumeration or a primitive type",
								CmlPackage::eINSTANCE.feature_Name,
								WRONG_TYPE)
			Reference: if(!(feature.typeDef.type.kind == null && feature.typeDef.type.ref instanceof Class))
							error("Wrong type for Reference '" + feature.name + "'. Should be a Class",
								CmlPackage::eINSTANCE.feature_Name,
								WRONG_TYPE)
		}
	}*/
	
	@Check
	def void checkMemberSelection(MemberSelection sel){
		if(sel !== null){
//			if(sel.coll != null && !sel.methodinvocation){
//				error("Collection Operation invocation without correct parentheses",
//					CmlPackage::eINSTANCE.memberSelection_Methodinvocation,
//					PROPERTY_SELECTION_ON_METHOD)
//			}
			if(sel.member !== null && sel.member instanceof Attribute && sel.methodinvocation)
				error("Operation invocation on Attribute '" + sel.member.name + "'",
					CmlPackage::eINSTANCE.memberSelection_Member,
					PROPERTY_SELECTION_ON_METHOD)
			if(sel.member !== null && sel.member instanceof Operation && !sel.methodinvocation)
				error("Property selection on the Operation '" + sel.member.name + "'",
					CmlPackage::eINSTANCE.memberSelection_Methodinvocation,
					PROPERTY_SELECTION_ON_METHOD)
		}
	}
/* 
	@Check
	def void checkCollectionType(AttributeType ctype){
		val boundsCondition = !(ctype.multiplicity.upperbound.isIsWildcard) && 
			ctype.multiplicity.lowerbound > ctype.multiplicity.upperbound.value
		val boundsConsistentWithCollection = ctype.collection == null ||
			(ctype.multiplicity.upperbound.isIsWildcard || 
				ctype.multiplicity.upperbound.value > 1)
		if(boundsCondition)
			error("Multiplicity bounds not correct", 
				CmlPackage::eINSTANCE.collectionType_Multiplicity,
				MULTIPLICITY_INCONSISTENCY)
		if(!boundsConsistentWithCollection)
			error("Multiplicity not consistent with collection declaration",
				CmlPackage::eINSTANCE.collectionType_Multiplicity,
				MULTIPLICITY_INCONSISTENCY)	
	}

	@Check
	def void checkOppositeReferences(Reference ref){
		val ctype = ref.collectionType
		if(ref.opposite != null){
			val opp = ref.opposite
			if(opp.opposite == null || opp.opposite != ref)
				error("Reference '" + ref.name + "' is not declared as opposite of '" 
					+ opp.name + "' in '" + ctype.type.typeOf.name + "'",
					CmlPackage::eINSTANCE.reference_Opposite,
					OPPOSITE_INCONSISTENCY)
			if(ref.isIsContainment && opp.isIsContainment)
				error("The containment reference '" + ref.name + "' cannot have a containment as opposite",
					CmlPackage::eINSTANCE.reference_Opposite,
					OPPOSITE_INCONSISTENCY)
			if(opp.isIsContainment && ctype.multiplicity != null && (ctype.multiplicity.lowerbound != 0 || ctype.multiplicity.upperbound.value != 1 || ctype.multiplicity.upperbound.isWildcard))
				error("Multiplicity should be [0..1] since '" + ref.name + 
					"' is the opposite of the containment reference '" + opp.name + "' in '" + opp.collectionType.type.typeOf.name + "'",
					CmlPackage::eINSTANCE.structuralProperty_CollectionType,
					OPPOSITE_INCONSISTENCY)
		}
	}*/

	@Check
	def void checkSuperAsReceiverOnly(SuperExpression e){
		if(e.eContainingFeature != CmlPackage::eINSTANCE.memberSelection_Receiver)
			error("'super' can only be used as a selection receiver (e.g., super.toString())",
				null, WRONG_SUPER_USAGE)
	}

	@Check
	def void checkSelfAsReceiverOnly(SelfExpression e){
		if(e.eContainingFeature != CmlPackage::eINSTANCE.memberSelection_Receiver)
			error("'self' can only be used as a selection receiver (e.g., super.toString())",
				null, WRONG_SELF_USAGE)
	}
	
	/*
	@Check
	def void checkAbstractOperationInAbstractClass(Operation op){
		if(op.isIsAbstract && op.body != null)
			error("Abstract operation '" + op.name + "' contains a body",
				CmlPackage::eINSTANCE.operation_Body,
				INVALID_ABSTRACT_OPERATION)
		if(op.isIsAbstract && !op.containingClass.isIsAbstract)
			error("Abstract operation '" + op.name + 
				"' inside the non-abstract class '" + op.containingClass.name + "'",
				CmlPackage::eINSTANCE.operation_IsAbstract,
				ABSTRACT_OP_INSIDE_NONABSTRACT_CLASS)	
	}*/
	
//	@Check
//	def void checkValidArgumentForCollectionOperation(MemberSelection sel){
//		if(sel.coll !== null && sel.coll === "at"){
//			if(sel.args === null)
//				error("Collection operation 'at' should have one argument of type integer",
//					CmlPackage::eINSTANCE.memberSelection_Args,
//					WRONG_TYPE)
//			if(sel.args !== null && sel.args.size > 1)
//				error("Collection operation 'at' should have only one argument of type integer",
//					CmlPackage::eINSTANCE.memberSelection_Args,
//					WRONG_TYPE)
//			if(sel.args !== null && !sel.args.isEmpty && sel.args.get(0).typeFor != CmlTypeProvider.INTEGER_TYPE)
//				error("Collection operation 'at' should have an argument of type integer",
//					CmlPackage::eINSTANCE.memberSelection_Args,
//					WRONG_TYPE)
//		}
//	}
	
	
	@Check
	def void checkCompatibleTypes(Expression exp) {
		val actualType   = exp.typeFor
		val expectedType = exp.expectedType
		if (expectedType === null || actualType === null)
			return; // nothing to check
		if (!actualType.isConformant(expectedType)) {
			/*error("Incompatible types. Expected '" + expectedType?.name
					+ "' but was '" + actualType?.name + "'", null,
					INCOMPATIBLE_TYPES);*/
					error("Incompatible types. Expected '" + expectedType.typeName
					+ "' but was '" + actualType.typeName + "'", null,
					INCOMPATIBLE_TYPES);
		}
	}
	
	/* 
	@Check
	def void checkCorrectReturnUse(ReturnStmt stmt){
		val returntype = stmt.containingOperation.type
		switch(returntype){
			VoidType:
				if(stmt.expression != null)
					error("Return statement should be empty within void return type operation '" + stmt.containingOperation.name + "'",
						CmlPackage::eINSTANCE.returnStmt_Expression,
						WRONG_TYPE)
			CollectionType:
				if(stmt.expression == null)
					error("Return statement should not be empty within operation '" + stmt.containingOperation.name + "'",
						null,
						WRONG_TYPE)	
		}
	}
	
	@Check
	def void checkNoDeclarationOutsideOfOperationBlock(VariableDeclaration decl){
		if(decl.containingBlock instanceof ConditionalBlock)
			error("Variable declaration allowed only in operations' top-level block", 
				CmlPackage::eINSTANCE.local_Name, 
				DECLARATION_WITHIN_BLOCK)
	}
	
	
	@Check
	def void checkCollectionLiteralWithSameType(CollectionLiteral lit){
	}*/
	
	def private void checkNoDuplicateElements(Iterable<? extends NamedElement> elements, String desc) {
		val multiMap = HashMultimap.create()

		for (e : elements)
			multiMap.put(e.name, e)

		for (entry : multiMap.asMap.entrySet) {
			val duplicates = entry.value
			if (duplicates.size > 1) {
				for (d : duplicates)
					error("Duplicate " + desc + " '" + d.name + "'", d, CmlPackage.eINSTANCE.namedElement_Name,
						DUPLICATE_ELEMENT)
			}
		}
	}
}
