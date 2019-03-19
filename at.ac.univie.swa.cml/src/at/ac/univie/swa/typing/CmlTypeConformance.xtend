package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Enumeration
import at.ac.univie.swa.cml.Type
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static at.ac.univie.swa.typing.CmlTypeProvider.*

class CmlTypeConformance {
	@Inject extension IQualifiedNameProvider
	@Inject extension CmlModelUtil

	def isConformant(Type c1, Type c2) {
		switch (c1) {
			Enumeration:
				return c1 == c2
			Class:
				switch (c2) {
					Enumeration:
						false
					Class:
						return c1 == NULL_TYPE || // null can be assigned to everything
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
		(c1.conformsToBoolean && c2.conformsToBoolean) ||
		(c1.conformsToReal && c2.conformsToReal)
	}

	def conformsToString(Class c) {
		c == STRING_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_STRING
	}

	def conformsToInt(Class c) {
		c == INTEGER_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_INTEGER
	}

	def conformsToBoolean(Class c) {
		c == BOOLEAN_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_BOOLEAN
	}
	
	def conformsToReal(Class c) {
		c == REAL_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_REAL
	}
	
	def conformsToParty(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_PARTY
	}
	
	def conformsToAsset(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ASSET
	}
	
	def conformsToEvent(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_EVENT
	}
	
	def conformsToDuration(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_DURATION
	}
	
	def conformsToDateTime(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_DATETIME
	}
	
	def conformsToContract(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_CONTRACT
	}

	def isSubclassOf(Class c1, Class c2) {
		c1.classHierarchy.contains(c2)
	}
}