package at.ac.univie.swa

import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.EnumerationElement
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.NamedElement
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.SwitchStatement
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*
import at.ac.univie.swa.cml.SymbolReference

class CmlModelUtil {

	@Inject extension CmlLib

	def returnStatement(Operation o) {
		o.body.returnStatement
	}

	def returnStatement(Block b) {
		b.statements.filter(ReturnStatement).head
	}

	def classes(CmlProgram p) {
		p.declarations.filter(Class)
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
	
	def isConcept(Class c) {
		c.kind == "concept"
	}
	
	def isParty(Class c) {
		c.kind == "party"
	}
	
	def isAsset(Class c) {
		c.kind == "asset"
	}
	
	def isEvent(Class c) {
		c.kind == "event"
	}
	
	def isTransaction(Class c) {
		c.kind == "transaction"
	}
	
	def isEnum(Class c) {
		c.kind == "enum"
	}
	
	def isContract(Class c) {
		c.kind == "contract"
	}
	
	def clauses(Class c) {
		c.features.filter(Clause)
	}
	
	def enumElements(Class c) {
		c.features.filter(EnumerationElement)
	}
	
	def attributes(Class c) {
		c.features.filter(Attribute)
	}
	
	def operations(Class c) {
		c.features.filter(Operation)
	}
	
	def containingClass(EObject e) {
		e.getContainerOfType(Class)
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
	
	def containingClause(EObject e) {
		e.getContainerOfType(Clause)
	}
	
	def referencedSymbols(Operation o) {
		o.eAllOfType(SymbolReference).map[symbol]
	}
	
	def referencedOperations(Operation o) {
		o.referencedSymbols.filter(Operation).toSet
	}
	
	def referencedAttributes(Operation o) {
		o.referencedSymbols.filter(Attribute).toSet
	}
	
	def referencedClasses(Operation o) {
		o.referencedSymbols.filter(Class).toSet
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

	def featureAsString(Feature f) {
		f.name + if (f instanceof Operation)
			"(" + f.params.map[type.name].join(", ") + ")"
		else
			""
	}

	def featureAsStringWithType(Feature f) {
		f.featureAsString + " : " + f.inferType.name
	}

	def Class inferType(NamedElement ne) {
		switch (ne) {
			Attribute: ne.type
			Operation: ne.type ?: CmlTypeProvider.VOID_TYPE
			EnumerationElement: ne.containingClass
			VariableDeclaration: ne.type
			Class: ne
		}
	}
	
	def classHierarchy(Class c) {
		val visited = newLinkedHashSet()
		
		var current = c.superclass
		
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass
		}
		
		switch (c.kind) {
			case "party": visited.add(c.cmlPartyClass)
			case "asset": visited.add(c.cmlAssetClass)
			case "event": visited.add(c.cmlEventClass)
			case "transaction": visited.add(c.cmlTransactionClass)
			case "enum": visited.add(c.cmlEnumClass)
			case "contract": visited.add(c.cmlContractClass)
		}

		visited
	}

	def classHierarchyWithObject(Class c) {
		val visited = classHierarchy(c)

		val object = c.getCmlAnyClass
		if (object !== null)
			visited.add(object)

		visited
	}

	def classHierarchyOperations(Class c) {
		var hierarchy = newLinkedHashSet()
		hierarchy.add(c)
		hierarchy.addAll(c.classHierarchyWithObject)
		hierarchy.toList.reverseView.map[operations].flatten.toMap[name]
	}
	
	def classHierarchyAttributes(Class c) {
		var hierarchy = newLinkedHashSet()
		hierarchy.add(c)
		hierarchy.addAll(c.classHierarchyWithObject)
		hierarchy.toList.reverseView.map[attributes].flatten.toMap[name]
	}
	
}
