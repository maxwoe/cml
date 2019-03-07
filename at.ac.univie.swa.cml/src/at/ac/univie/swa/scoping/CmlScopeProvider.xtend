/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.scoping

import at.ac.univie.swa.cml.Action
import at.ac.univie.swa.cml.AtomicAction
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.CmlPackage
import at.ac.univie.swa.cml.ComplexTypeRef
import at.ac.univie.swa.cml.DotExpression
import at.ac.univie.swa.cml.DotExpressionStart
import at.ac.univie.swa.cml.Entity
import at.ac.univie.swa.cml.Party
import at.ac.univie.swa.cml.SimpleType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CmlScopeProvider extends AbstractCmlScopeProvider {

	// private static final Logger logger = Logger.getLogger(CmlScopeProvider.getName());
	// @Inject extension CmlExtensions
	override getScope(EObject context, EReference reference) {

		println(context.class);
		
		if (reference == CmlPackage.Literals.ATOMIC_ACTION__ACTION) {
			if (context instanceof AtomicAction) {
				val clause = EcoreUtil2.getContainerOfType(context, Clause)
				if (clause !== null && clause.actor !== null && clause.actor.party !== null) {
					val allActions = EcoreUtil2.getAllContentsOfType(clause.actor.party, Action)
					return Scopes.scopeFor(allActions)
					//return Scopes.scopeFor(allActions.filter[context.args.size == args.size])
				}
			}
		}

		if (reference == CmlPackage.Literals.ATOMIC_ACTION__ARGS) {
			if (context instanceof AtomicAction) {
				if (context !== null && context.action !== null) {
					val args = EcoreUtil2.getAllContentsOfType(context.action, Attribute)
					return Scopes.scopeFor(args);
				}
			}
		}
		
		if (reference == CmlPackage.Literals.ATOMIC_ACTION__PRE_CONDITION) {
			if (context instanceof AtomicAction) {
				if (context !== null && context.action !== null) {
					val args = EcoreUtil2.getAllContentsOfType(context.action, Attribute)
					return Scopes.scopeFor(args);
				}
			}
		}
		
		if (reference == CmlPackage.Literals.DOT_EXPRESSION_START__REF) {
			
			/*if (context instanceof AtomicAction) {
				var result = IScope.NULLSCOPE
				val rootElement = EcoreUtil2.getRootContainer(context)
				val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
				result = Scopes.scopeFor(parties, result)
				result = Scopes.scopeFor(context.args, result);
				return result;
			}*/
			
			if (context instanceof DotExpressionStart) {
				/*var result = IScope.NULLSCOPE
				val rootElement = EcoreUtil2.getRootContainer(context)
				val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
				result = Scopes.scopeFor(parties.filter[context.action == type.actions], result)
				result = Scopes.scopeFor(context.args, result);
				
				val attributes = EcoreUtil2.getAllContentsOfType(rootElement, Attribute)
				return Scopes.scopeFor(attributes);*/
				
				//val args = EcoreUtil2.getAllContentsOfType(context.action, Attribute)
				val aa = EcoreUtil2.getContainerOfType(context, AtomicAction)
				if(aa !== null)
					return Scopes.scopeFor(aa.args);
			}
		}
		
		
//		if (reference == CmlPackage.Literals.EXPRESSION__REF) {
//
//			/*if (context instanceof AtomicAction) {
//			 * 	var result = IScope.NULLSCOPE
//			 * 	val rootElement = EcoreUtil2.getRootContainer(context)
//			 * 	val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
//			 * 	result = Scopes.scopeFor(parties, result)
//			 * 	result = Scopes.scopeFor(context.args, result);
//			 * 	return result;
//			 }*/
//			if (context instanceof AtomicAction) {
//				/*var result = IScope.NULLSCOPE
//				 * val rootElement = EcoreUtil2.getRootContainer(context)
//				 * val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
//				 * result = Scopes.scopeFor(parties.filter[context.action == type.actions], result)
//				 * result = Scopes.scopeFor(context.args, result);
//				 * 
//				 * val attributes = EcoreUtil2.getAllContentsOfType(rootElement, Attribute)
//				 return Scopes.scopeFor(attributes);*/
//				val args = EcoreUtil2.getAllContentsOfType(context.action, Attribute)
//				return Scopes.scopeFor(args, [Attribute attr|return QualifiedName.create(attr.name)], IScope.NULLSCOPE);
//			}
//		}
		
		//if (reference == CmlPackage.Literals.ATOMIC_ACTION__PRE_CONDITION) {
		if (reference == CmlPackage.Literals.ATOMIC_ACTION__PRE_CONDITION) {	
			/*if (context instanceof AtomicAction) {
				var result = IScope.NULLSCOPE
				val rootElement = EcoreUtil2.getRootContainer(context)
				val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
				result = Scopes.scopeFor(parties, result)
				result = Scopes.scopeFor(context.args, result);
				return result;
			}*/
			
//			if (context instanceof AtomicAction) {
//				/*var result = IScope.NULLSCOPE
//				val rootElement = EcoreUtil2.getRootContainer(context)
//				val parties = EcoreUtil2.getAllContentsOfType(rootElement, Party)
//				result = Scopes.scopeFor(parties.filter[context.action == type.actions], result)
//				result = Scopes.scopeFor(context.args, result);
//				
//				val attributes = EcoreUtil2.getAllContentsOfType(rootElement, Attribute)
//				return Scopes.scopeFor(attributes);*/
//				
//				//val args = EcoreUtil2.getAllContentsOfType(context.action, Attribute)
//				//	return Scopes.scopeFor(args, [Attribute attr | return QualifiedName.create("haha" + attr.name)], IScope.NULLSCOPE);
//					
//            if (context.args !== null) {
//					val result = newArrayList
//					for (i : context.args) {
//						result.add(EObjectDescription.create(QualifiedName.create(context.action.name, i.name), i))
//
//					}
//					println(result)
//					return new SimpleScope(IScope.NULLSCOPE, result)
//				}
//			}
			
			
		}
		
		if (reference == CmlPackage.Literals.DOT_EXPRESSION__TAIL) {
			
			if (context instanceof DotExpression) {
				val head = context.head;
				switch (head) {
					DotExpressionStart:
						switch (head.ref) {
							Attribute: {
								if((head.ref as Attribute).typeDef !== null && 
									(head.ref as Attribute).typeDef !== null)
								{
								val type = (head.ref as Attribute).typeDef;
								switch (type) {
									SimpleType: return Scopes::scopeFor(type.eContents)
									ComplexTypeRef: {
										val ref = type.ref
										switch (ref) {
											Party:	return Scopes::scopeFor(ref.attributes)
											Entity: return Scopes::scopeFor(ref.attributes)
											default: return IScope.NULLSCOPE
										}
									}
									default: return IScope.NULLSCOPE
								}}
							}
							Party: return Scopes::scopeFor((head.ref as Party).attributes)
							default: return IScope.NULLSCOPE
						}
					DotExpression: {
						val tail = head.tail
						switch (tail) {
							Attribute: {
								val type = (head.tail as Attribute).typeDef
								switch (type) {
									SimpleType: {
										return Scopes::scopeFor(type.eContents)
									}
									ComplexTypeRef: {
										val ref = type.ref
										switch (ref) {
											Party:	return Scopes::scopeFor(ref.attributes)
											Entity: return Scopes::scopeFor(ref.attributes)
											default: return IScope.NULLSCOPE
										}
									}
									default: return IScope.NULLSCOPE
								}
							}
							default: return IScope.NULLSCOPE
						}
					}
					default: return IScope.NULLSCOPE
				}
			}
		}

		super.getScope(context, reference)
	}
}
