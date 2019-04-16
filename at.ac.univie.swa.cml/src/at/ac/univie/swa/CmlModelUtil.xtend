package at.ac.univie.swa

import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.EnumerationElement
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.NamedElement
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.cml.ReturnStatement

class CmlModelUtil {

	@Inject extension CmlLib
	@Inject extension CmlTypeProvider
	@Inject extension CmlTypeConformance

	def returnStatement(Operation o) {
		o.body.returnStatement
	}

	def returnStatement(Block b) {
		b.statements.filter(ReturnStatement).head
	}

	def classes(CmlProgram p) {
		p.declarations.filter(Class)
	}
	
	def parties(CmlProgram p) {
		p.classes.filter[kind=="party"]
	}
	
	def assets(CmlProgram p) {
		p.classes.filter[kind=="asset"]
	}
	
	def events(CmlProgram p) {
		p.classes.filter[kind=="event"]
	}
	
	def enums(CmlProgram p) {
		p.classes.filter[kind=="enum"]
	}
	
	def contracts(CmlProgram p) {
		p.classes.filter[kind=="contract"]
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
	
//	def containingSwitch(EObject e) {
//		e.getContainerOfType(Switch)
//	}
	
	def containingAttribute(EObject e) {
		e.getContainerOfType(Attribute)
	}
	
	def containingClause(EObject e) {
		e.getContainerOfType(Clause)
	}

	def featureAsString(Feature f) {
		f.name + if (f instanceof Operation)
			"(" + f.params.map[type.name].join(", ") + ")"
		else
			""
	}

	def featureAsStringWithType(Feature f) {
		f.featureAsString + " : " //+ f.inferType.typeName
	}

//	def typeName(Type t) {
//		switch (t) {
//			Class:
//				switch (t) {
//					case t.isPrimitive: t.name
//					case t.conformsToMap,
//					case t.conformsToSet,
//					case t.conformsToBag: t.name + "<" + t.typeVars.map[type?.name].join(", ") + ">"
//					case t.conformsToArray: t.typeVars.get(0).type.name + "[]"
//					default: t.name
//				}
//		}
//	}
//
	/*def Class inferType(Feature f) {
		switch (f) {
			Attribute: inferType(f)
			Operation: inferType(f)
			EnumerationElement: f.cmlEnumClass
		}
	}*/

	def Class inferType(NamedElement s) {
		switch (s) {
			Attribute: s.type
			Operation: s.type
			EnumerationElement: s.containingClass
			VariableDeclaration: s.type
			Class: s
		}
	}
	
	/*def inferType(Operation op) {
		switch (op.type) {
			Class: op.type
			default: return CmlTypeProvider.VOID_TYPE
		}
	}*/
//	
//	def Class inferType(Container c) {
//		switch (c) {
//			Primitive:
//				return c.type.toClass
//			/*Collection: {
//				var clazz = c.collectionType.toClass
//				switch (clazz) {
//					case clazz.conformsToSet: {
//						clazz.typeVars.get(0).type = c.type.toClass
//						clazz.superclass.typeVars.get(0).type = c.type.toClass
//						return clazz
//					}
//					case clazz.conformsToBag: {
//						clazz.typeVars.get(0).type = c.type.toClass
//						clazz.superclass.typeVars.get(0).type = c.type.toClass
//						return clazz
//					}
//				}
//			}
//			Array: {
//				var clazz = c.cmlArrayClass
//				clazz.typeVars.get(0).type = c.type.toClass
//				return clazz
//			}
//			Map: {
//				var clazz = c.mapType.toClass
//				switch (clazz) {
//					case clazz.conformsToMap: {
//						clazz.typeVars.get(0).type = c.key.toClass
//						clazz.typeVars.get(1).type = c.type.toClass
//						return clazz
//					}
//				}
//			}*/
//			default:
//				CmlTypeProvider.NULL_TYPE
//		}
//	}
//	
//	def toClass(TypeRef t) {
//		switch(t) {
//			Type:
//				switch(t) {
//					Class: t
//					default: CmlTypeProvider.NULL_TYPE
//				}
//			TypeVar: t.type
//			default: CmlTypeProvider.NULL_TYPE
//		}
//	}

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
			case "enum": visited.add(c.cmlEnumClass)
			case "contract": visited.add(c.cmlContractClass)
		}

		visited
	}

	def classHierarchyWithObject(Class c) {
		val visited = classHierarchy(c)

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
	
	def classHierarchyAttributes(Class c) {
		c.classHierarchyWithObject.toList.reverseView.map[attributes].flatten.toMap[name]
	}

	def classHierarchyFeatures(Class c) {
		c.classHierarchyWithObject.map[features].flatten
	}

}
