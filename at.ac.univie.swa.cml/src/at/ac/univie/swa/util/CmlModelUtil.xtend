package at.ac.univie.swa.util

import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.AttributeType
import at.ac.univie.swa.cml.Bag
import at.ac.univie.swa.cml.BooleanType
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.IntegerType
import at.ac.univie.swa.cml.Model
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrderedSet
import at.ac.univie.swa.cml.PrimitiveType
import at.ac.univie.swa.cml.RealType
import at.ac.univie.swa.cml.ReturnType
import at.ac.univie.swa.cml.Sequence
import at.ac.univie.swa.cml.Set
import at.ac.univie.swa.cml.StringType
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.TypeReference
import at.ac.univie.swa.cml.VoidType
import at.ac.univie.swa.typing.CmlTypeProvider
import org.eclipse.emf.ecore.EObject

import static extension org.eclipse.xtext.EcoreUtil2.*
import at.ac.univie.swa.lib.CmlLib
import com.google.inject.Inject

class CmlModelUtil {
	
	@Inject extension CmlLib

	def static attributes(Class c) {
		c.features.filter(typeof(Attribute))
	}

	def static classes(Model m) {
		m.types.filter(typeof(Class))
	}

	/*def static declarations(Operation op){
		op.body.statements.filter(typeof(VariableDeclaration))
	}*/

	def static enumerations(Model m) {
		m.types.filter(typeof(Enumeration))
	}

	def static operations(Class c) {
		c.features.filter(typeof(Operation))
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
		e.getContainerOfType(typeof(Class))
	}

	/*def static containingDeclaration(Multiplicity m) {
		m.getContainerOfType(typeof(Feature))
	}*/

	def static containingEnumeration(EObject e) {
		e.getContainerOfType(typeof(Enumeration))
	}

	def static containingModel(EObject e) {
		e.getContainerOfType(typeof(Model))
	}

	def static containingOperation(EObject e) {
		e.getContainerOfType(typeof(Operation))
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
	
	
	def static classHierarchy(Class c) {
		val visited = <Class>newArrayList()
		var current = c.superClass
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superClass
		}

		/*val object = c.cmlObjectClass
		if (object !== null)
			visited.add(object)*/

		return visited
	}

	def static Type typeOf(PrimitiveType ptype) {
		switch (ptype) {
			IntegerType: CmlTypeProvider.integerType
			StringType: CmlTypeProvider.stringType
			RealType: CmlTypeProvider.realType
			BooleanType: CmlTypeProvider.booleanType
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

	def static Type typeOf(AttributeType ctype) {
		return typeOf(ctype.type)
	}

	def static Type typeOf(ReturnType rtype) {
		if (rtype instanceof VoidType)
			return CmlTypeProvider.voidType
		else
			return typeOf((rtype as AttributeType).type)
	}

	def static isUnique(AttributeType ctype) {
		val coll = ctype.collection
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
			AttributeType: rtype.isUnique
		}
	}

	def static isOrdered(AttributeType ctype) {
		val coll = ctype.collection
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
			AttributeType: rtype.isUnique
		}
}

}
