package at.ac.univie.swa.lib

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.naming.IQualifiedNameProvider
import at.ac.univie.swa.scoping.CmlIndex
import at.ac.univie.swa.cml.Class

import static extension at.ac.univie.swa.util.CmlModelUtil.*

class CmlLib {
	@Inject Provider<ResourceSet> resourceSetProvider;
	@Inject extension CmlIndex
	@Inject extension IQualifiedNameProvider

	public val static LIB_PACKAGE = "cml.lang"
	public val static LIB_OBJECT = LIB_PACKAGE + ".Object"
	public val static LIB_STRING = LIB_PACKAGE + ".String"
	public val static LIB_INTEGER = LIB_PACKAGE + ".Integer"
	public val static LIB_BOOLEAN = LIB_PACKAGE + ".Boolean"
	public val static LIB_COLLECTION = LIB_PACKAGE + ".Collection"
	public val static MAIN_LIB = "cml/lang/mainlib.cml"

	def loadLib() {
		val stream = getClass().getClassLoader().getResourceAsStream(MAIN_LIB)

		resourceSetProvider.get() => [ resourceSet |

			val resource = resourceSet.createResource(URI::createURI(MAIN_LIB))
			resource.load(stream, resourceSet.getLoadOptions())
		]
	}

	def getClassHierarchyWithObject(Class c) {
		var hierarchy = c.classHierarchy
		if (hierarchy.last?.fullyQualifiedName?.toString != LIB_OBJECT) {
			val cmlObjectClass = getCmlObjectClass(c)
			if (cmlObjectClass !== null)
				hierarchy += cmlObjectClass
		}
		hierarchy
	}

	def getSuperclassOrObject(Class c) {
		c.superClass ?: getCmlObjectClass(c)
	}

	def getCmlObjectClass(EObject context) {
		val desc = context.getVisibleClassesDescriptions.findFirst[qualifiedName.toString == LIB_OBJECT]

		if (desc === null)
			return null

		var o = desc.EObjectOrProxy
		if (o.eIsProxy)
			o = context.eResource.resourceSet.getEObject(desc.EObjectURI, true)

		return (o as Class)
	}
}