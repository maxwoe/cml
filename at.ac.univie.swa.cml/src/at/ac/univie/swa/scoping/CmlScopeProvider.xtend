/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.scoping

import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.MemberSelection
import at.ac.univie.swa.cml.Operation
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

	override getScope(EObject context, EReference reference) {
		if (reference == CmlPackage.Literals.SYMBOL_REFERENCE__SYMBOL) {
			return scopeForSymbolRef(context, reference)
		} else if (context instanceof MemberSelection) {
			return scopeForMemberSelection(context)
		}

		return super.getScope(context, reference)
	}

	def protected IScope scopeForSymbolRef(EObject context, EReference reference) {
		var container = context.eContainer

		return switch (container) {
			Operation:
				Scopes.scopeFor(container.params, scopeForSymbolRef(container, reference))
			Block:
				Scopes.scopeFor(container.statements.takeWhile[it != context].filter(VariableDeclaration),
					scopeForSymbolRef(container, reference))
			Class: {
				var parentScope = IScope::NULLSCOPE
				for (c : container.classHierarchyWithObject.toArray().reverseView) {
					parentScope = Scopes::scopeFor((c as Class).attributes + (c as Class).operations, parentScope)
				}
				parentScope = Scopes::scopeFor(container.attributes + container.operations, parentScope)
				new SimpleScope(scopeForSymbolRef(container, reference), parentScope.allElements)
			}
//			ForLoop:
//				Scopes.scopeFor(#[container.declaration], scopeForSymbolRef(container) )
			CmlProgram:
				allClasses(container, reference)
			default:
				scopeForSymbolRef(container, reference)
		}
	}

	def protected IScope scopeForMemberSelection(MemberSelection mfc) {
		var type = mfc.receiver.typeFor

		if (type === null || type.isPrimitive)
			return IScope.NULLSCOPE

		if (type instanceof Class) {
			if (mfc.explicitStatic)
				return Scopes::scopeFor(type.enumElements)

			var parentScope = IScope::NULLSCOPE
			for (c : type.classHierarchyWithObject.toArray().reverseView) {
				parentScope = Scopes::scopeFor((c as Class).selectedFeatures(mfc), parentScope)
			}
			return Scopes::scopeFor(type.selectedFeatures(mfc), parentScope)
		}
	}

	def selectedFeatures(Class type, MemberSelection mfc) {
		if (mfc.methodinvocation)
			type.operations + type.attributes
		else
			type.attributes + type.operations
	}

	def allClasses(EObject context, EReference reference) {
		val IScope delegateScope = delegateGetScope(context, reference)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof Class)
					true
				else
					false
			}

		}
		new FilteringScope(delegateScope, filter)
	}
}
