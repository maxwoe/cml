/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.validation

import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Annotation
import at.ac.univie.swa.cml.AnnotationDeclaration
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.AtomicAction
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.ClauseQuery
import at.ac.univie.swa.cml.Closure
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.Deontic
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelectionExpression
import at.ac.univie.swa.cml.NamedElement
import at.ac.univie.swa.cml.NewExpression
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OtherOperatorExpression
import at.ac.univie.swa.cml.ReferenceExpression
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.TemporalPrecedence
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.scoping.CmlIndex
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.common.collect.HashMultimap
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckType

import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CmlValidator extends AbstractCmlValidator {

	@Inject extension IQualifiedNameProvider
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeProvider
	@Inject extension CmlTypeConformance
	@Inject extension CmlIndex

	protected static val ISSUE_CODE_PREFIX = "cml.lang."
	public static val HIERARCHY_CYCLE = ISSUE_CODE_PREFIX + "HierarchyCycle"
	public static val FIELD_SELECTION_ON_METHOD = ISSUE_CODE_PREFIX + "FieldSelectionOnMethod"
	public static val METHOD_INVOCATION_ON_FIELD = ISSUE_CODE_PREFIX + "MethodInvocationOnField"
	public static val UNREACHABLE_CODE = ISSUE_CODE_PREFIX + "UnreachableCode"
	public static val MISSING_FINAL_RETURN = ISSUE_CODE_PREFIX + "MissingFinalReturn"
	public static val DUPLICATE_ELEMENT = ISSUE_CODE_PREFIX + "DuplicateElement"
	public static val INCOMPATIBLE_TYPES = ISSUE_CODE_PREFIX + "IncompatibleTypes"
	public static val INVALID_ARGS = ISSUE_CODE_PREFIX + "InvalidArgs"
	public static val DUPLICATE_CLASS = ISSUE_CODE_PREFIX + "DuplicateClass"
	public static val WRONG_SUPER_USAGE = ISSUE_CODE_PREFIX + "WrongSuperUsage"
	public static val OPPOSITE_INCONSISTENCY = ISSUE_CODE_PREFIX + "OppositeInconsistency"
	public static val WRONG_SYMBOL_USAGE = ISSUE_CODE_PREFIX + "WrongSymbolUsage"
	public static val INVALID_ATTRIBUTE_DECLARATION = ISSUE_CODE_PREFIX + "NamespaceAttributeWithoutConstantDeclaration"
	public static val INVALID_INSTANTIATION = ISSUE_CODE_PREFIX + "InvalidInstantiation"
	public static val MISSING_INITZIALIZATION = ISSUE_CODE_PREFIX + "MissingInitialization"
	public static val INVALID_ASSIGNMENT = ISSUE_CODE_PREFIX + "InvalidAssignment"
	public static val WRONG_USAGE = ISSUE_CODE_PREFIX + "WrongUsage"
	// public static val REDUCED_ACCESSIBILITY = ISSUE_CODE_PREFIX + "ReducedAccessibility"
	// public static val MISSING_IDENTITY_DEFINITION = ISSUE_CODE_PREFIX + "MissingIdentityDefinition"
	// public static val WRONG_METHOD_OVERRIDE = ISSUE_CODE_PREFIX + "WrongMethodOverride"
	// public static val MEMBER_NOT_ACCESSIBLE = ISSUE_CODE_PREFIX + "MemberNotAccessible"
	
	@Check
	def void checkNameStartsWithCapital(CmlClass c) {
		if (!Character.isUpperCase(c.name.charAt(0))) {
			warning("Name should start with a capital", CmlPackage.Literals.NAMED_ELEMENT__NAME)
		}
	}

	@Check
	def void checkClassHierarchy(CmlClass c) {
		if (c.classHierarchy.contains(c)) {
			error("Cycle in hierarchy of CmlClass '" + c.name + "'", CmlPackage::eINSTANCE.cmlClass_Superclass,
				HIERARCHY_CYCLE, c.superclass.inferType.name)
		}
	}

	@Check
	def void checkSuperclass(CmlClass c) {
		val expectedType = c.resolveImplClass
		val actualType = c.superclass.inferType
		if (expectedType === null || actualType === null)
			return; // nothing to check
		if (!actualType.isConformant(expectedType)) {
			error("'" + c.name + "' must extend '" + c.kind + "'", CmlPackage::eINSTANCE.cmlClass_Superclass,
			INCOMPATIBLE_TYPES, c.superclass.inferType.name)
		}
	}

	@Check
	def void checkNoDuplicateClasses(CmlProgram cmlp) {
		checkNoDuplicateElements(cmlp.classes, "class")
		checkNoDuplicateElements(cmlp.attributes, "attribute")
		//checkNoDuplicateElements(cmlp.operations, [signature], "operation")
	}

	@Check
	def void checkNoDuplicateFeatures(CmlClass c) {
		checkNoDuplicateElements(c.attributes, "attribute")
		checkNoDuplicateElements(c.operations, "operation")
		checkNoDuplicateElements(c.clauses, "clause")
		checkNoDuplicateElements(c.enumElements, "enumeration literal")
	}

	@Check
	def void checkNoDuplicateSymbols(Operation o) {
		checkNoDuplicateElements(o.params, "parameter")
		checkNoDuplicateElements(o.body.getAllContentsOfType(VariableDeclaration), "variable")
	}

	// perform this check only on file save
	@Check(CheckType.NORMAL)
	def checkDuplicateClassesInFiles(CmlProgram p) {
		val externalClasses = p.getVisibleExternalClassesDescriptions
		for (c : p.classes) {
			val className = c.fullyQualifiedName
			if (externalClasses.containsKey(className)) {
				error("The type " + c.name + " is already defined", c, CmlPackage.eINSTANCE.namedElement_Name,
					DUPLICATE_CLASS)
			}
		}
	}

	@Check
	def void checkFeatureSelection(FeatureSelectionExpression fse) {
		val feature = fse.feature

		if (feature instanceof Attribute && fse.opCall)
			error("Method invocation on a field", CmlPackage.eINSTANCE.featureSelectionExpression_OpCall,
				METHOD_INVOCATION_ON_FIELD)
		else if (feature instanceof Operation && !fse.opCall)
			error(
				"Field selection on a method",
				CmlPackage.eINSTANCE.featureSelectionExpression_Feature,
				FIELD_SELECTION_ON_METHOD
			)
	}

	@Check
	def void checkUnreachableCode(Block block) {
		val statements = block.statements
		for (var i = 0; i < statements.length - 1; i++) {
			if (statements.get(i) instanceof ReturnStatement) {
				error("Unreachable code", statements.get(i + 1), null, UNREACHABLE_CODE)
				return
			}
		}
	}
	
	@Check
	def void checkDeonticMustTemporalConstraintRequirements(Clause c) {
		if (c.action.deontic.equals(Deontic.MUST) && c.constraint.temporal.precedence.equals(TemporalPrecedence.AFTER) && c.constraint.temporal.timeframe === null) {
			error("Modality 'must' and temporal precedence 'after' requires a timeframe to be specified with 'within'", null,
				WRONG_USAGE)
		}
	}
	
	@Check
	def void checkClauseQueryReference(ClauseQuery cq) {
		if (!cq.clause.action.deontic.equals(Deontic.MUST))
			error("Referred clause must use the deontic modality 'must'", CmlPackage.eINSTANCE.clauseQuery_Clause, WRONG_USAGE)

	}
	
	@Check
	def void checkDeonticMustDefinesTemporalConstraint(Clause c) {
		if (c.action.deontic.equals(Deontic.MUST) && c.constraint.temporal === null) {
			error("Deontic modality 'must' requires a temporal constraint to be specified with 'due'", null, WRONG_USAGE)
		}
	}
	
	@Check
	def void checkMethodEndsWithReturn(Operation o) {
		if (o.returnStatement === null && !o.inferType.conformsToVoid) {
			error("Method must end with a return statement", CmlPackage.eINSTANCE.operation_Body, MISSING_FINAL_RETURN)
		}
	}

	@Check
	def void checkCorrectReturnUse(ReturnStatement stmnt) {
		val returntype = stmnt.containingOperation.inferType
		switch (returntype) {
			case returntype.conformsToVoid:
				if (stmnt.expression !== null)
					error(
						"Return statement should be empty within void return type operation '" +
							stmnt.containingOperation.name + "'", CmlPackage::eINSTANCE.returnStatement_Expression,
						INCOMPATIBLE_TYPES)
			default:
				if (stmnt.expression === null && returntype !== null)
					error("Return statement should not be empty within operation '" + stmnt.containingOperation.name +
						"'", null, INCOMPATIBLE_TYPES)
		}
	}

	@Check
	def void checkSuperUsage(SuperExpression se) {
		if (se.eContainingFeature != CmlPackage.eINSTANCE.featureSelectionExpression_Receiver)
			error("'super' can be used only as feature selection receiver", null, WRONG_SUPER_USAGE)
	}

	@Check
	def void checkConformance(Expression exp) {
		val actualType = exp.typeFor
		val expectedType = exp.expectedType
		if (expectedType === null || actualType === null)
			return; // nothing to check
		if (!actualType.isConformant(expectedType)) {
			error(
				"Incompatible types. Expected '" + (expectedType as CmlClass).fullyQualifiedName + "' but was '" +
					(actualType as CmlClass).fullyQualifiedName + "'", null, INCOMPATIBLE_TYPES);
		}
	}
	
	@Check
	def void checkAssignment(ReferenceExpression re) {
		val assignment = re.getContainerOfType(AssignmentExpression)
		if (assignment !== null) {
			val left = assignment.left
			if (left instanceof ReferenceExpression) {
				val attribute = left.reference
				if (attribute instanceof Attribute) {
					if (attribute.constant) {
						error("The constant attribute '" + attribute.name + "' cannot be assigned", null,
							INVALID_ASSIGNMENT)
					}
				}
			}
		}
	}	

	@Check
	def void checkClosureConstructorArguments(Expression exp) {
		if (exp.eContainer instanceof Block && exp.eContainer.eContainer instanceof Closure &&
			exp.eContainer.eContainer.eContainer instanceof OtherOperatorExpression) {
			val otherOpExp = exp.getContainerOfType(OtherOperatorExpression)
			if (otherOpExp.op == "=>") {
				val left = otherOpExp.left
				if (left instanceof ReferenceExpression) {
					val type = left.reference.inferType
					if (type instanceof CmlClass) {
						if (exp instanceof AssignmentExpression) {
							val expLeft = exp.left
							if (expLeft instanceof ReferenceExpression) {
								val expRef = expLeft.reference
								if (expRef instanceof Attribute) {
									if (!type.classHierarchyAttributes.values.exists[it == expRef]) {
										error("Couldn't resolve reference to attribute '" + expRef.name + "'", null,
											OPPOSITE_INCONSISTENCY)
									}
								} else
									error("Is not a valid reference", null, INVALID_ARGS)
							} else
								error("Is not a valid reference", null, INVALID_ARGS)
						} else
							error("Is not a valid assignment declaration", null, INVALID_ARGS)
					}
				}
			}
		}
	}

	@Check
	def void checkClosureConstructorArguments(OtherOperatorExpression exp) {
		val left = exp.left
		val right = exp.right
		if (exp.op == "=>") {
			if (right instanceof Closure) {
				if (left instanceof ReferenceExpression) {
					val type = left.reference.inferType
					if (type instanceof CmlClass) {
						if (type.abstract)
							error("Cannot instantiate the type '" + type.name + "'",
								CmlPackage.eINSTANCE.otherOperatorExpression_Op, INVALID_INSTANTIATION)
						if ((right.expression as Block).expressions.size != type.classHierarchyAttributes.size) {
							error(
								"Invalid number of arguments: expected " + type.classHierarchyAttributes.size +
									" but was " + (right.expression as Block).expressions.size,
								CmlPackage.eINSTANCE.otherOperatorExpression_Op, INVALID_ARGS)
						}
					}
				}
			}
		}
	}

	@Check
	def void checkAttributeDeclaration(Attribute a) {
		if (a.containingClass === null && !a.constant &&
			!(a.eContainer instanceof Operation || a.eContainer instanceof AnnotationDeclaration) ||
			!a.containingClass.contract && a.expression !== null) {
			error("Invalid attribute declaration", null, INVALID_ATTRIBUTE_DECLARATION)
		}
	}

	@Check
	def void checkConstantDeclaration(Attribute a) {
		if (a.constant && a.expression === null)
			error("The blank constant attribute '" + a.name + "' may not have been initialized", null,
				MISSING_INITZIALIZATION)
	}
	
	
	@Check
	def void checkContractMethodArguments(Attribute a) {
		val allActions = a.eContainer.containingClass.clauses.flatMap[action.compoundAction.eAllOfType(AtomicAction).map[operation]].toSet
		if (allActions.contains(a.eContainer) && a.eContainer.containingClass !== null && !a.inferType.subclassOfTransaction)
			error("The attribute '" + a.name + "' is not a transaction", null,
				INVALID_ARGS)
	}

	@Check
	def void checkMethodInvocationArguments(FeatureSelectionExpression fse) {
		val operation = fse.feature
		if (operation instanceof Operation) {
			if (operation.params.size != fse.args.size) {
				error("Invalid number of arguments: expected " + operation.params.size + " but was " + fse.args.size,
					CmlPackage.eINSTANCE.featureSelectionExpression_Feature, INVALID_ARGS)
			}
		}
	}
	
	@Check
	def void checkAnnotationArguments(Annotation a) {
		val declaration = a.declaration
		if (declaration instanceof AnnotationDeclaration) {
			if (a.args.size != declaration.features.size) {
				error("Invalid number of arguments: expected " + a.args.size + " but was " + declaration.features.size,
					CmlPackage.eINSTANCE.annotation_Args, INVALID_ARGS)
			}
		}
	}

	@Check
	def void checkMethodInvocationArguments(ReferenceExpression re) {
		val operation = re.reference
		if (operation instanceof Operation) {
			if (re.args.size != operation.params.size) {
				error("Invalid number of arguments: expected " + operation.params.size + " but was " + re.args.size,
					CmlPackage.eINSTANCE.referenceExpression_Reference, INVALID_ARGS)
			}
		}
	}

	@Check
	def void checkConstructorArguments(NewExpression ne) {
		val class = ne.type.inferType
		if (class instanceof CmlClass) {
			if (class.abstract)
				error("Cannot instantiate the type '" + ne.type.inferType.name + "'",
					CmlPackage.eINSTANCE.newExpression_Type, INVALID_INSTANTIATION)
			if (class.classHierarchyAttributes.size != ne.args.size) {
				error("Invalid number of arguments: expected " + class.classHierarchyAttributes.size + " but was " +
					ne.args.size, CmlPackage.eINSTANCE.newExpression_Type, INVALID_ARGS)
			}
		}
	}
	
	def private void checkNoDuplicateElements(Iterable<? extends NamedElement> elements, String desc) {
		checkNoDuplicateElements(elements, [NamedElement e | e.name], desc)
	}

	def private void checkNoDuplicateElements(Iterable<? extends NamedElement> elements, (NamedElement)=>String calledFunction, String desc) {
		val multiMap = HashMultimap.create()

		for (e : elements)
			multiMap.put(calledFunction.apply(e), e)

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
