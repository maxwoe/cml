package at.ac.univie.swa

import at.ac.univie.swa.cml.Array
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Collection
import at.ac.univie.swa.cml.Container
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.Model
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.Primitive
import at.ac.univie.swa.cml.ReturnType
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.VoidType
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*
import at.ac.univie.swa.cml.Local

class CmlModelUtil {
	
	@Inject extension CmlLib

	def static attributes(Class c) {
		c.features.filter(Attribute)
	}

	/*def static classes(Model m) {
		m.types.filter(Class)
	}*

	/*def static declarations(Operation op){
		op.body.statements.filter(typeof(VariableDeclaration))
	}*/

	/*def static enumerations(Model m) {
		m.types.filter(Enumeration)
	}*/

	def static operations(Class c) {
		c.features.filter(Operation)
	}

	/*def static properties(Class c) {
		c.attributes //+ c.references
	}*/

	/*def static references(Class c) {
		c.features.filter(typeof(Reference))
	}*/

	/*def static containingBlock(Statement stmt){
		stmt.getContainerOfType(typeof(Block))
	}*/

	def static containingClass(EObject e) {
		e.getContainerOfType(Class)
	}

	/*def static containingDeclaration(Multiplicity m) {
		m.getContainerOfType(typeof(Feature))
	}*/

	def static containingEnumeration(EObject e) {
		e.getContainerOfType(Enumeration)
	}

	def static containingModel(EObject e) {
		e.getContainerOfType(Model)
	}

	def static containingOperation(EObject e) {
		e.getContainerOfType(Operation)
	}

	/*def static isLastStatementInBlock(Statement stmt, Block block){
		return (block.statements.last == stmt)
	}

	def static branchingStatementIterator(Operation op){
		return op.getAllContents(true).filter(typeof(BranchingStmt))
	}

	def Statement nextStatement(Statement stmt){
		return nextStatement(stmt, stmt.containingBlock)
	}

	def dispatch Statement nextStatement(Statement stmt, ConditionalBlock block){
		if(stmt.isLastStatementInBlock(block)){
			val containingStmt = block.getContainerOfType(typeof(BranchingStmt))
			return nextStatement(containingStmt, containingStmt.containingBlock)
		}else
			return block.statements.get(block.statements.indexOf(stmt)+1)
	}

	def dispatch Statement nextStatement(Statement stmt, Body block){
		if(stmt.isLastStatementInBlock(block))
			return null
		else
			return block.statements.get(block.statements.indexOf(stmt)+1)
	}
	
	def static nestedBranchingStatements(Operation operation){
		operation.body.statements.typeSelect(typeof(BranchingStmt))
	}*/
	
	
	
	/*
	def static Type typeOf(PrimitiveType ptype) {
		switch (ptype) {
			IntegerType: CmlTypeProvider.INTEGER_TYPE
			StringType: CmlTypeProvider.STRING_TYPE
			RealType: CmlTypeProvider.REAL_TYPE
			BooleanType: CmlTypeProvider.BOOLEAN_TYPE
		}
	}

	def static Type typeOf(TypeReference t) {
		var Type result
		if (t.ref !== null)
			result = t.ref
		if (t.kind !== null)
			result = typeOf(t.kind)
		return result
	}

	def static Type typeOf(ReturnType rtype) {
		if (rtype instanceof VoidType)
			return CmlTypeProvider.VOID_TYPE
		else
			return (rtype as Container).type
	}*/
/* 
	def static isUnique(Container container) {
		val coll = container.collection
		if (coll === null)
			return true
		else
			switch (coll) {
				Bag: return false
				Set: return true
				Sequence: return false
				OrderedSet: return true
			}
	}

	def static isUnique(ReturnType rtype) {
		switch (rtype) {
			VoidType: true
			Container: rtype.isUnique
		}
	}

	def static isOrdered(Container container) {
		val coll = container.collection
		if (coll === null)
			return false
		else
			switch (coll) {
				Bag: return false
				Set: return false
				Sequence: return true
				OrderedSet: return true
			}
	}

	def static isOrdered(ReturnType rtype) {
		switch (rtype) {
			VoidType: true
			Container: rtype.isUnique
		}
}*/
	
	def static memberAsStringWithType(Feature f) {
		f.memberAsString + " : " + f.typeName
	}

	def static memberAsString(Feature f) {
		switch (f) {
			Attribute: f.name
			Operation: f.name + "(" +
				f.argsTypesAsString + ")"
		}
	}
	
	def static argsTypesAsString(Operation o) {
		o.args.map[type.typeName].join(", ")
	}

	def static memberAsStringWithType(Attribute a) {
		a.memberAsString + " : " + a.typeName
	}
	
	def static typeAsString(Feature f) {
		switch (f) {
			Attribute: f.name
			Operation: f.name + "(" +
				f.argsTypesAsString + ")"
		}
	}
	
	def static typeName(Container c) {
		switch(c) {
			Primitive: typeName(c.type)
			Collection: c.collectionType.name + "<" + typeName(c.type) + ">"
			Array: typeName(c.type) + "[]"
		}
	}
	
	def static typeName(Type t) {
		switch(t) {
			Class: t.name
			Enumeration: t.name
		}
	}
	def static typeName(Primitive p) {
		typeName(p.type)
	}
	
	def static typeName(Attribute a) {
		typeName(a.type)
	}
	
	def static typeName(ReturnType rt) {
		switch (rt) {
			VoidType: "void"
			Container: typeName(rt.type)
		}
	}
	
	def static typeName(Operation o) {
		typeName(o.type)
	}
	
	def static typeName(Feature f) {
		switch(f) {
			Attribute: typeName(f)
			Operation: typeName(f)
		}
	}
	
	def static Type typeOf(Attribute a) {
		typeOf(a.type)
	}
	
	def static typeOf(Feature f) {
		switch(f) {
			Attribute: typeOf(f)
			Operation: typeOf(f)
		}
	}
	
	def static Type typeOf(Container container) {
		switch(container) {
			Primitive: container.type
			Collection: CmlTypeProvider.COLLECTION_TYPE
			Array: CmlTypeProvider.ARRAY_TYPE
		}
	}
	
	def static Type typeOf(Operation op) {
		switch (op.type) {
			VoidType: return CmlTypeProvider.NULL_TYPE
			Container: return (op.type as Container).typeOf
		}
	}
	
	def static Type typeOf(ReturnType rtype) {
		if (rtype instanceof VoidType)
			return CmlTypeProvider.VOID_TYPE
		else
			return typeOf(rtype as Container)
	}
	
	def static Type typeOf(Local l) {
		typeOf(l.type)
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
		
		switch(c.type) {
			case "party": visited.add(c.getCmlPartyClass)
			case "asset": visited.add(c.getCmlAssetClass)
			case "event": visited.add(c.getCmlEventClass)
		}
		
		val object = c.getCmlObjectClass
		if (object !== null)
			visited.add(object)
		
		println("hierarchy: " + visited)
		
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
