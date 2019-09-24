package at.ac.univie.swa

import at.ac.univie.swa.cml.Annotation
import at.ac.univie.swa.cml.AnnotationDeclaration
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.EnumerationElement
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.GenericArrayTypeReference
import at.ac.univie.swa.cml.NamedElement
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.ParameterizedTypeReference
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.SwitchStatement
import at.ac.univie.swa.cml.ReferenceExpression
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.TypeReference
import at.ac.univie.swa.cml.TypeVariable
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static extension org.eclipse.xtext.EcoreUtil2.*

class CmlModelUtil {

	@Inject extension CmlLib
	@Inject extension CmlTypeConformance
	@Inject extension IQualifiedNameProvider

	def returnStatement(Operation o) {
		o.body.returnStatement
	}

	def returnStatement(Block b) {
		b.statements.filter(ReturnStatement).head
	}

	def classes(CmlProgram p) {
		p.declarations.filter(CmlClass)
	}
	
	def operations(CmlProgram p) {
		p.declarations.filter(Operation)
	}
	
	def attributes(CmlProgram p) {
		p.declarations.filter(Attribute)
	}
	
	def concepts(CmlProgram p) {
		p.classes.filter[concept]
	}
	
	def parties(CmlProgram p) {
		p.classes.filter[party]
	}
	
	def assets(CmlProgram p) {
		p.classes.filter[asset]
	}
	
	def events(CmlProgram p) {
		p.classes.filter[event]
	}
	
	def transactions(CmlProgram p) {
		p.classes.filter[transaction]
	}

	def enums(CmlProgram p) {
		p.classes.filter[enum]
	}
	
	def contracts(CmlProgram p) {
		p.classes.filter[contract]
	}
	
	def isConcept(CmlClass c) {
		c.kind == "concept"
	}
	
	def isParty(CmlClass c) {
		c.kind == "party"
	}
	
	def isAsset(CmlClass c) {
		c.kind == "asset"
	}
	
	def isEvent(CmlClass c) {
		c.kind == "event"
	}
	
	def isTransaction(CmlClass c) {
		c.kind == "transaction"
	}
	
	def isEnum(CmlClass c) {
		c.kind == "enum"
	}
	
	def isContract(CmlClass c) {
		c.kind == "contract"
	}
	
	def clauses(CmlClass c) {
		c.features.filter(Clause)
	}
	
	def enumElements(CmlClass c) {
		c.features.filter(EnumerationElement)
	}
	
	def attributes(CmlClass c) {
		c.features.filter(Attribute)
	}
	
	def operations(CmlClass c) {
		c.features.filter(Operation)
	}
	
	def containingClass(EObject e) {
		e.getContainerOfType(CmlClass)
	}

	def containingCmlProgram(EObject e) {
		e.getContainerOfType(CmlProgram)
	}

	def containingOperation(EObject e) {
		e.getContainerOfType(Operation)
	}
	
	def containingSwitch(EObject e) {
		e.getContainerOfType(SwitchStatement)
	}
	
	def containingAttribute(EObject e) {
		e.getContainerOfType(Attribute)
	}
	
	def containingAnnotationDeclaration(EObject e) {
		e.getContainerOfType(AnnotationDeclaration)
	}
	
	def containingAnnotation(EObject e) {
		e.getContainerOfType(Annotation)
	}
	
	def containingClause(EObject e) {
		e.getContainerOfType(Clause)
	}
	
	def references(Operation o) {
		o.eAllOfType(ReferenceExpression).map[reference]
	}
	
	def referencedOperations(Operation o) {
		o.references.filter(Operation).toSet
	}
	
	def referencedAttributes(Operation o) {
		o.references.filter(Attribute).toSet
	}
	
	def referencedClasses(Operation o) {
		o.references.filter(CmlClass).toSet
	}
	
	def variableDeclarations(Operation o) {
		o.eAllOfType(VariableDeclaration)
	}
	
	def isStatic(Attribute a) {
		a.eContainer instanceof CmlProgram
	}
	
	def isStatic(Operation o) {
		o.eContainer instanceof CmlProgram
	}
	
	def containedInMainLib(Operation o) {
		o.eContainer.fullyQualifiedName.toString == CmlLib::LIB_PACKAGE
	}

	def featureAsString(Feature f) {
		f.name + if (f instanceof Operation)
			"(" + f.params.map[inferType.typeName].join(", ") + ")"
		else
			""
	}

	def featureAsStringWithType(Feature f) {
		f.featureAsString + " : " + f.inferType.typeName
	}
	
	def typeName(Type t) {
		switch (t) {
			CmlClass:
				switch (t) {
					case t.conformsToMap: t.name + "<" + t.typeVars.map[inferType.name].join(", ") + ">"
					default: t.name
				}
		}
	}
	
	def CmlClass inferType(TypeReference tr) {
		switch(tr) {
			ParameterizedTypeReference : tr.type.inferType
			GenericArrayTypeReference : //tr.componentType.inferType
										tr.cmlArrayClass
		}
	}

	def CmlClass inferType(EObject e) {
		switch (e) {
			Type: e as CmlClass
			TypeVariable: e.cmlAnyClass
			default: CmlTypeProvider.NULL_TYPE
		}
	}
	
	def CmlClass inferType(NamedElement ne) {
		switch (ne) {
			Attribute: ne.type.inferType
			Operation: ne.type !== null ? ne.type.inferType : CmlTypeProvider.VOID_TYPE
			EnumerationElement: ne.containingClass
			VariableDeclaration: ne.type.inferType
			CmlClass: ne
			default: CmlTypeProvider.NULL_TYPE
		}
	}
	
	def resolveImplClass(CmlClass c) {
		switch (c) {
			case c.isParty: c.cmlPartyClass
			case c.isAsset: c.cmlAssetClass
			case c.isEvent: c.cmlEventClass
			case c.isTransaction: c.cmlTransactionClass
			case c.isEnum: c.cmlEnumClass
			case c.isContract: c.cmlContractClass
		}
	}
	
	def classHierarchy(CmlClass c) {
		val visited = newLinkedHashSet()
		
		var current = c.superclass.inferType
		
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass.inferType
		}
		
		current = c.inferType.resolveImplClass
		
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass.inferType
		}
		
		visited
	}

	def classHierarchyWithRoot(CmlClass c) {
		val visited = classHierarchy(c)

		val any = c.getCmlAnyClass
		if (any !== null)
			visited.add(any)

		visited
	}

	def classHierarchyOperations(CmlClass c) {
		var hierarchy = newLinkedHashSet()
		hierarchy.add(c)
		hierarchy.addAll(c.classHierarchyWithRoot)
		hierarchy.toList.reverseView.map[operations].flatten.toMap[name]
	}
	
	def classHierarchyAttributes(CmlClass c) {
		var hierarchy = newLinkedHashSet()
		hierarchy.add(c)
		hierarchy.addAll(c.classHierarchyWithRoot)
		hierarchy.toList.reverseView.map[attributes].flatten.toMap[name]
	}
	
	def isPrimitive(Type t) {
		t instanceof CmlClass && (t as CmlClass).eResource === null
	}
	
}
