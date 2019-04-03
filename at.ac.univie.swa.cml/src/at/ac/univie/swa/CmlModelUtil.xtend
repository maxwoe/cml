package at.ac.univie.swa

import at.ac.univie.swa.cml.Array
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.Collection
import at.ac.univie.swa.cml.Container
import at.ac.univie.swa.cml.EnumerationElement
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.Map
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.Primitive
import at.ac.univie.swa.cml.Return
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*

class CmlModelUtil {

	@Inject extension CmlLib
	@Inject extension CmlTypeProvider
	@Inject extension CmlTypeConformance

	def returnStatement(Operation o) {
		o.body.returnStatement
	}

	def returnStatement(Block b) {
		b.statements.filter(Return).head
	}

	def classes(CmlProgram p) {
		p.model.filter(Class)
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

	def featureAsString(Feature f) {
		f.name + if (f instanceof Operation)
			"(" + f.params.map[type.inferType.typeName].join(", ") + ")"
		else
			""
	}

	def featureAsStringWithType(Feature f) {
		f.featureAsString + " : " + f.inferType.typeName
	}

	def typeName(Type t) {
		switch (t) {
			Class:
				switch (t) {
					case t.isPrimitive: t.name
					case t.isConformant(t.mapClass),
					case t.isConformant(t.collectionClass): t.name + "<" + t.typeVar.name + ">"
					case t.isConformant(t.arrayClass): t.typeVar.name + "[]"
					default: t.name
				}
		}
	}

	def inferType(Feature f) {
		switch (f) {
			Attribute: inferType(f)
			Operation: inferType(f)
			EnumerationElement: f.cmlEnumClass
		}
	}

	def inferType(Attribute a) {
		inferType(a.type)
	}
	
	def inferType(Operation op) {
		switch (op.type) {
			Container: return inferType(op.type as Container)
			default: return CmlTypeProvider.VOID_TYPE
		}
	}
	
	def Class inferType(Container c) {
		switch (c) {
			Primitive:
				return c.type.toClass
			Collection:
				switch (c.collectionType) {
					case "Set": {
						var clazz = c.setClass
						clazz.typeVar = c.type.toClass
						return clazz
					}
					case "Bag": {
						var clazz = c.bagClass
						clazz.typeVar = c.type.toClass
						return clazz
					}
				}
			Array: {
				var clazz = c.arrayClass
				clazz.typeVar = c.type.toClass
				return clazz
			}
			Map:
				switch (c.mapType) {
					case "Map": {
						var clazz = c.mapClass
						clazz.typeVar = c.type.toClass
						return clazz
					}
				}
		}
	}
	
	def toClass(Type t) {
		if (t instanceof Class)
			return t
		else
			return CmlTypeProvider.NULL_TYPE
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

		switch (c.kind) {
			case "party": visited.add(c.cmlPartyClass)
			case "asset": visited.add(c.cmlAssetClass)
			case "event": visited.add(c.cmlEventClass)
			case "enum": visited.add(c.cmlEnumClass)
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
		c.classHierarchyWithObject.toList.reverseView.map[operations].flatten.toMap[name]
	}

	def classHierarchyFeatures(Class c) {
		c.classHierarchyWithObject.map[features].flatten
	}

}
