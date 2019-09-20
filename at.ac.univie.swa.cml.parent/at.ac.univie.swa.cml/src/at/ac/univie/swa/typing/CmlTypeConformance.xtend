package at.ac.univie.swa.typing

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.Type
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static at.ac.univie.swa.typing.CmlTypeProvider.*

class CmlTypeConformance {
	@Inject extension IQualifiedNameProvider
	@Inject extension CmlModelUtil

	def boolean isConformant(Type c1, Type c2) {
		switch (c1) {
			CmlClass:
				switch (c2) {
					CmlClass:
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

	def conformToLibraryTypes(CmlClass c1, CmlClass c2) {
		(c1.conformsToBoolean && c2.conformsToBoolean) ||
		(c1.conformsToString && c2.conformsToString) || 
		(c1.conformsToInteger && c2.conformsToNumber) ||
		(c1.conformsToReal && c2.conformsToNumber) ||
		(c1.conformsToInteger && c2.conformsToInteger) ||
		(c1.conformsToReal && c2.conformsToReal) ||
		(c1.conformsToDateTime && c2.conformsToDateTime) ||
		(c1.conformsToDuration && c2.conformsToDuration) ||
		(c1.conformsToError && c2.conformsToError)
	}
	
	def conformsToLibraryType(CmlClass c) {
		c.conformsToBoolean ||  c.conformsToString || c.conformsToInteger || c.conformsToReal || c.conformsToDateTime ||
			c.conformsToDuration || c.conformsToError || c.conformsToNumber
	}
	
	def conformsToVoid(CmlClass c) {
		c == VOID_TYPE
	}
	
	def conformsToNull(CmlClass c) {
		c == NULL_TYPE
	}
	
	def conformsToBoolean(CmlClass c) {
		c == BOOLEAN_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_BOOLEAN
	}
	
	def conformsToString(CmlClass c) {
		c == STRING_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_STRING
	}
	
	def conformsToNumber(CmlClass c) {
		c == NUMBER_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_NUMBER
	}

	def conformsToInteger(CmlClass c) {
		c == INTEGER_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_INTEGER
	}
	
	def conformsToReal(CmlClass c) {
		c == REAL_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_REAL
	}
	
	def conformsToDateTime(CmlClass c) {
		c == DATETIME_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_DATETIME
	}
	
	def conformsToDuration(CmlClass c) {
		c == DURATION_TYPE || 
		c.fullyQualifiedName.toString == CmlLib::LIB_DURATION
	}
	
	def conformsToError(CmlClass c) {
		c == ERROR_TYPE || 
		c.fullyQualifiedName.toString ==CmlLib::LIB_ERROR
	}
	
	def conformsToParty(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_PARTY
	}
	
	def conformsToAsset(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ASSET
	}
	
	def conformsToEvent(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_EVENT
	}
		
	def conformsToContract(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_CONTRACT
	}
	
	def conformsToEnum(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ENUM
	}
	
	def conformsToAny(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_ANY
	}
	
	def conformsToToken(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_TOKEN
	}
	
	def conformsToTransaction(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_TRANSACTION
	}
	
	def conformsToTokenTransaction(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_TOKEN_TRANSACTION
	}
	
	def conformsToTokenHolder(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_TOKEN_HOLDER
	}
	
	def conformsToParticipant(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_PARTICIPANT
	}
	
	def subclassOfParty(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_PARTY)
	}
	
	def subclassOfAsset(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_ASSET)
	}
	
	def subclassOfEvent(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_EVENT)
	}
		
	def subclassOfContract(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_CONTRACT)
	}
	
	def subclassOfEnum(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_ENUM)
	}
	
	def subclassOfTransaction(CmlClass c) {
		c.isSubclassOf(CmlLib::LIB_TRANSACTION)
	}
	
	def conformsTo(CmlClass c, String fqn) {
		c.fullyQualifiedName.toString == fqn
	}
	
	def isSubclassOf(CmlClass c, String fqn) {
		c.classHierarchy.exists[fullyQualifiedName.toString == fqn]
	}
	
	def isSubclassOf(CmlClass c1, CmlClass c2) {
		c1.classHierarchy.contains(c2)
	}
	
	def conformsToMap(CmlClass c) {
		c.fullyQualifiedName.toString == CmlLib::LIB_MAP
	}
	
}