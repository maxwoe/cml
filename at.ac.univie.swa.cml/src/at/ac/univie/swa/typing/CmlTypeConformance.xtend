package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Type
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static at.ac.univie.swa.typing.CmlTypeProvider.*

class CmlTypeConformance {
	@Inject extension IQualifiedNameProvider
	@Inject extension CmlModelUtil

	def boolean isConformant(Type c1, Type c2) {
		switch (c1) {
			Class:
				switch (c2) {
//					Class case c1.conformsToSet && c2.conformsToSet,
//					Class case c1.conformsToBag && c2.conformsToBag,
//					Class case c1.conformsToArray && c2.conformsToArray:
//						return isConformant(c1.typeVars.get(0).type, c2.typeVars?.get(0).type)
//					Class case c1.conformsToMap && c2.conformsToMap:
//						return isConformant(c1.typeVars.get(0).type, c2.typeVars?.get(0).type) &&
//							isConformant(c1.typeVars.get(1).type, c2.typeVars?.get(1).type)
					Class:
						return c1 == NULL_TYPE || // null can be assigned to everything
						(conformToLibraryTypes(c1, c2)) || c1 == c2 ||
							c2.fullyQualifiedName.toString == CmlLib::LIB_ANY || c1.isSubclassOf(c2)
					default:
						false
				}
			default:
				false
		}
	}

	def conformToLibraryTypes(Class c1, Class c2) {
		(c1.conformsToString && c2.conformsToString) || 
		(c1.conformsToInteger && c2.conformsToInteger)       ||
		(c1.conformsToBoolean && c2.conformsToBoolean) ||
		(c1.conformsToReal && c2.conformsToReal) ||
		(c1.conformsToDateTime && c2.conformsToDateTime) ||
		(c1.conformsToDuration && c2.conformsToDuration) ||
		(c1.conformsToError && c2.conformsToError)
	}

	def conformsToVoid(Class c) {
		c == VOID_TYPE
	}
	
	def conformsToNull(Class c) {
		c == NULL_TYPE
	}
	
	def conformsToString(Class c) {
		c == STRING_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_STRING
	}

	def conformsToInteger(Class c) {
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
	
	def conformsToDateTime(Class c) {
		c == DATETIME_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_DATETIME
	}
	
	def conformsToDuration(Class c) {
		c == DURATION_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_DURATION
	}
	
	def conformsToError(Class c) {
		c == ERROR_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_ERROR
	}
	
	def conformsToParty(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_PARTY
	}
	
	def conformsToEnum(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ENUM
	}
	
	def conformsToAsset(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ASSET
	}
	
	def conformsToEvent(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_EVENT
	}
	
	def conformsToContract(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_CONTRACT
	}
	
	def conformsToSet(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_SET
	}
	
	def conformsToBag(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_BAG
	}
	
	def conformsToMap(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_MAP
	}
	
	def conformsToArray(Class c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ARRAY
	}
	
	def isSubclassOfContract(Class c) {
		c.classHierarchy.exists[conformsToContract]
	}
	
	def isSubclassOfParty(Class c) {
		c.classHierarchy.exists[conformsToParty]
	}
	
	def isSubclassOfAsset(Class c) {
		c.classHierarchy.exists[conformsToAsset]
	}
	
	def isSubclassOfEvent(Class c) {
		c.classHierarchy.exists[conformsToEvent]
	}
	
	def isSubclassOfEnum(Class c) {
		c.classHierarchy.exists[conformsToEnum]
	}
	
	def isSubclassOf(Class c1, Class c2) {
		c1.classHierarchy.contains(c2)
	}
}