package at.ac.univie.swa.typing

import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.Type
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static at.ac.univie.swa.typing.CmlTypeProvider.*

import static extension at.ac.univie.swa.util.CmlModelUtil.*
import at.ac.univie.swa.lib.CmlLib

class CmlTypeConformance {
	@Inject extension IQualifiedNameProvider

	def isConformant(Type c1, Type c2) {
		switch (c1) {
			Enumeration:
				return c1 == c2
			Class:
				switch (c2) {
					Enumeration:
						false
					Class:
						return c1 == nullType || // null can be assigned to everything
							(conformToLibraryTypes(c1, c2)) || 
							c1 == c2 ||
							c2.fullyQualifiedName.toString == CmlLib::LIB_OBJECT || 
							c1.isSubclassOf(c2)
					default: false
				}
			default: false
		}
	}

	def conformToLibraryTypes(Class c1, Class c2) {
		(c1.conformsToString && c2.conformsToString) || 
		(c1.conformsToInt && c2.conformsToInt)       ||
		(c1.conformsToBoolean && c2.conformsToBoolean)
	}

	def conformsToString(Class c) {
		c == stringType || 
		c.fullyQualifiedName.toString == CmlLib::LIB_STRING
	}

	def conformsToInt(Class c) {
		c == integerType || 
		c.fullyQualifiedName.toString == CmlLib::LIB_INTEGER
	}

	def conformsToBoolean(Class c) {
		c == booleanType || 
		c.fullyQualifiedName.toString == CmlLib::LIB_BOOLEAN
	}

	def isSubclassOf(Class c1, Class c2) {
		c1.classHierarchy.contains(c2)
	}
}