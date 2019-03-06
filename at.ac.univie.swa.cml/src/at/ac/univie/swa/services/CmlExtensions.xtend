package at.ac.univie.swa.services

/**
 * Extensions for model elements of a domain model.
 * Usage in Xtend files:
 * <pre>
 *   @Inject extension DomainModelExtensions
 * 
 *   // ...
 * 
 *     entity.structuralFeatures
 *     reference.structuralFeatures
 *     reference.entity
 * </pre>
 */
class CmlExtensions {

	/*def dispatch structuralFeatures(Entity it) {
		features.filter(typeof(StructuralFeature))
	}

	def dispatch Iterable<StructuralFeature> structuralFeatures(Reference it) {
		type.referenced.structuralFeatures
	}
	// (need to specify return type because of recursion)

	def dispatch Iterable<StructuralFeature> structuralFeatures(Attribute it) {
		emptyList
	}
	// (need to specify return type because common super type of List<T> and Iterable<T> is Object)


	// Returns the referenced Entity or null if type references something else (which is an error).
	def entity(Reference it) {
		if( type.referenced instanceof Entity) type.referenced as Entity else null
	}*/

}
