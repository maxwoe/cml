package at.ac.univie.swa

import at.ac.univie.swa.cml.Array
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.Collection
import at.ac.univie.swa.cml.Container
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.Primitive
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*

class CmlModelUtil {
	
	@Inject extension CmlLib

	def attributes(Class c) {
		c.features.filter(Attribute)
	}

	def operations(Class c) {
		c.features.filter(Operation)
	}
	
	def containingClass(EObject e) {
		e.getContainerOfType(Class)
	}

	def containingEnumeration(EObject e) {
		e.getContainerOfType(Enumeration)
	}

	def containingCmlProgram(EObject e) {
		e.getContainerOfType(CmlProgram)
	}

	def containingOperation(EObject e) {
		e.getContainerOfType(Operation)
	}

	def featureAsString(Feature f) {
		f.name +
		if (f instanceof Operation)
			"(" + f.params.map[type.typeName].join(", ") + ")"
		else ""
	}

	def featureAsStringWithType(Feature f) {
		f.featureAsString + " : " + f.typeOf.typeName
	}
	
	def typeName(Container c) {
		switch(c) {
			Primitive: typeName(c.type)
			Collection: c.collectionType.name + "<" + typeName(c.type) + ">"
			Array: typeName(c.type) + "[]"
		}
	}
	
	def typeName(Type t) {
		switch(t) {
			Class: t.name
			Enumeration: t.name
		}
	}

	def typeOf(Feature f) {
		switch(f) {
			Attribute: typeOf(f)
			Operation: typeOf(f)
		}
	}
	
	def typeOf(Attribute a) {
		typeOf(a.type)
	}	
	
	def typeOf(Container c) {
		switch(c) {
			Primitive: c.type
			Collection: {
				switch (c.collectionType.name) {
					case "Set" : c.setClass
					case "Bag" : c.bagClass
				}
			}
			Array: c.arrayClass
		}
	}
	
	def typeOf(Operation op) {
		switch (op.type) {
			Container: return typeOf(op.type as Container)
			default: return CmlTypeProvider.VOID_TYPE
		}
	}
	
	def classHierarchy(Class c) {
		val visited = newLinkedHashSet()

		var current = c.superclass
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass
		}
		
		visited
	}
	
	def classHierarchyWithObject(Class c) {
		val visited = classHierarchy(c)
		
		switch(c.kind) {
			case "party": visited.add(c.cmlPartyClass)
			case "asset": visited.add(c.cmlAssetClass)
			case "event": visited.add(c.cmlEventClass)
			case "contract": visited.add(c.cmlContractClass)
		}
		
		val object = c.getCmlObjectClass
		if (object !== null)
			visited.add(object)
		
		visited
	}

	def classHierarchyOperations(Class c) {
		// reverse the list so that methods in subclasses
		// will be added later to the map, thus overriding
		// the one already present in the superclasses
		// if the methods have the same name
		c.classHierarchyWithObject.toList.reverseView.
			map[operations].flatten.toMap[name]
	}

	def classHierarchyFeatures(Class c) {
		c.classHierarchyWithObject.map[features].flatten
	}
	
}
