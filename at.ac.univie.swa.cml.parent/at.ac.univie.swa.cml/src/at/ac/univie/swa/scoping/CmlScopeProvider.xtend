/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.scoping

import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Annotation
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Closure
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.FeatureSelectionExpression
import at.ac.univie.swa.cml.ForBasicStatement
import at.ac.univie.swa.cml.ForLoopStatement
import at.ac.univie.swa.cml.NewExpression
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OtherOperatorExpression
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.common.base.Predicate
import javax.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.SimpleScope

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CmlScopeProvider extends AbstractCmlScopeProvider {

	@Inject extension CmlTypeProvider
	@Inject extension CmlModelUtil
	//@Inject extension CmlTypeConformance

	override getScope(EObject context, EReference reference) {
		if (reference == CmlPackage.Literals.REFERENCE_EXPRESSION__REFERENCE) {
			return scopeForReference(context, reference)
		} else if (context instanceof FeatureSelectionExpression) {
			return scopeForFeatureSelection(context)
		} else if (reference == CmlPackage.Literals.ACTOR__PARTY || reference == CmlPackage.Literals.ACTION_QUERY__PARTY) {
			return scopeForAttributeRef(context, [Attribute a | a.type !== null /*/&& (a.inferType.conformsToParty || a.inferType.subclassOfParty)*/])
		} else if (reference == CmlPackage.Literals.EVENT_QUERY__EVENT) {
			return scopeForAttributeRef(context, [Attribute a | a.type !== null /*&& (a.inferType.conformsToEvent || a.inferType.subclassOfEvent)*/])
		} else if (reference == CmlPackage.Literals.ANNOTATION_ELEMENT__PARAM) {
			return scopeForAnnotationParamRef(context, reference)
		}
		super.getScope(context, reference)
	}

	def protected IScope scopeForReference(EObject context, EReference reference) {
		var container = context.eContainer

		return switch (container) {
			Closure: {
				var scope = IScope::NULLSCOPE
				var eContainer = container.eContainer
				switch (eContainer) {
					OtherOperatorExpression case eContainer.op == "=>": {
						var left = eContainer.left
						if (left instanceof NewExpression)
							if (left.type.inferType instanceof CmlClass) {
								for (c : left.type.inferType.classHierarchyWithRoot.toList.reverseView) {
									scope = Scopes::scopeFor(c.attributes, scope)
								}
								scope = Scopes.scopeFor(left.type.inferType.attributes, scope)
							}
					}
				}
				new SimpleScope(scopeForReference(container, reference), scope.allElements)
			}
			Operation:
				Scopes.scopeFor(container.params, scopeForReference(container, reference))
			Block:
				Scopes.scopeFor(container.statements.takeWhile[it != context].filter(VariableDeclaration),
					scopeForReference(container, reference))
			CmlClass: {
				var parentScope = IScope::NULLSCOPE
				for (c : container.classHierarchyWithRoot.toList.reverseView) {
					parentScope = Scopes::scopeFor(c.attributes + c.operations, parentScope)
				}
				parentScope = Scopes::scopeFor(container.attributes + container.operations, parentScope)
				new SimpleScope(scopeForReference(container, reference), parentScope.allElements)
			}
			ForLoopStatement:
				Scopes.scopeFor(#[container.declaration], scopeForReference(container, reference))
			ForBasicStatement:
				Scopes.scopeFor(#[container.declaration], scopeForReference(container, reference))
			CmlProgram:
				allClasses(container, reference)
			default:
				scopeForReference(container, reference)
		}
	}

	def protected IScope scopeForFeatureSelection(FeatureSelectionExpression fs) {
		return fs.receiver.typeFor.scopeForType(fs.opCall, fs.explicitStatic)
	}
	
	def protected IScope scopeForType(Type type, Boolean opCall, Boolean explicitStatic) {
		if (type === null || type.isPrimitive)
			return IScope.NULLSCOPE

		if (type instanceof CmlClass) {
			if (explicitStatic)
				return Scopes::scopeFor(type.enumElements)

			var parentScope = IScope::NULLSCOPE
			for (c : type.classHierarchyWithRoot.toList.reverseView) {
				parentScope = Scopes::scopeFor(c.selectedFeatures(opCall), parentScope)
			}
			return Scopes::scopeFor(type.selectedFeatures(opCall), parentScope)
		}
	}

	def selectedFeatures(CmlClass type, Boolean opCall) {
		if (opCall)
			type.operations + type.attributes
		else
			type.attributes + type.operations
	}
	
	def IScope scopeForAnnotationParamRef(EObject context, EReference reference) {
		return Scopes.scopeFor((context.eContainer as Annotation).declaration.features)
	}
	
	def IScope scopeForAttributeRef(EObject context, (Attribute)=>Boolean calledFunction) {
		var parentScope = IScope::NULLSCOPE
		for (c : context.containingClass.classHierarchyWithRoot.toList.reverseView) {
			parentScope = Scopes::scopeFor(c.attributes.filter[calledFunction.apply(it)], parentScope)
		}
		return Scopes::scopeFor(context.containingClass.attributes.filter[calledFunction.apply(it)], parentScope)
	}

	def allClasses(EObject context, EReference reference) {
		val IScope delegateScope = delegateGetScope(context, reference)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof CmlClass || obj instanceof Operation || obj instanceof Attribute)
					true
				else
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}
}
