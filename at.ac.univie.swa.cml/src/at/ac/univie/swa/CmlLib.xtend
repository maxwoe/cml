package at.ac.univie.swa

import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.scoping.CmlIndex
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet

class CmlLib {
	@Inject Provider<ResourceSet> resourceSetProvider;
	@Inject extension CmlIndex

	public val static LIB_PACKAGE = "cml.lang"
	public val static LIB_OBJECT = LIB_PACKAGE + ".Object"
	public val static LIB_STRING = LIB_PACKAGE + ".String"
	public val static LIB_INTEGER = LIB_PACKAGE + ".Integer"
	public val static LIB_BOOLEAN = LIB_PACKAGE + ".Boolean"
	public val static LIB_REAL = LIB_PACKAGE + ".Real"
	public val static LIB_DURATION = LIB_PACKAGE + ".Duration"
	public val static LIB_DATETIME = LIB_PACKAGE + ".DateTime"
	public val static LIB_PARTY = LIB_PACKAGE + ".Party"
	public val static LIB_ASSET = LIB_PACKAGE + ".Asset"
	public val static LIB_EVENT = LIB_PACKAGE + ".Event"
	public val static LIB_ENUM = LIB_PACKAGE + ".Enum"
	public val static LIB_CONTRACT = LIB_PACKAGE + ".Contract"
	public val static LIB_COLLECTION = LIB_PACKAGE + ".Collection"
	public val static LIB_SET = LIB_PACKAGE + ".Set"
	public val static LIB_BAG = LIB_PACKAGE + ".Bag"
	public val static LIB_ARRAY = LIB_PACKAGE + ".Array"
	public val static MAIN_LIB = "cml/lang/mainlib.cml"

	def loadLib() {
		val stream = getClass().getClassLoader().getResourceAsStream(MAIN_LIB)

		resourceSetProvider.get() => [ resourceSet |

			val resource = resourceSet.createResource(URI::createURI(MAIN_LIB))
			resource.load(stream, resourceSet.getLoadOptions())
		]
	}

	def getCmlObjectClass(EObject context) {
		getCmlClass(context, LIB_OBJECT)
	}
	
	def getCmlPartyClass(EObject context) {
		getCmlClass(context, LIB_PARTY)
	}
	
	def getCmlAssetClass(EObject context) {
		getCmlClass(context, LIB_ASSET)
	}
	
	def getCmlEventClass(EObject context) {
		getCmlClass(context, LIB_EVENT)
	}
	
	def getCmlContractClass(EObject context) {
		getCmlClass(context, LIB_CONTRACT)
	}
	
	def getCmlDateTimeClass(EObject context) {
		getCmlClass(context, LIB_DATETIME)
	}
	
	def getCmlDurationClass(EObject context) {
		getCmlClass(context, LIB_DURATION)
	}
	
	def getSetClass(EObject context) {
		getCmlClass(context, LIB_SET)
	}
	
	def getBagClass(EObject context) {
		getCmlClass(context, LIB_BAG)
	}
	
	def getArrayClass(EObject context) {
		getCmlClass(context, LIB_ARRAY)
	}
	
	def getCmlEnumClass(EObject context) {
		getCmlClass(context, LIB_ENUM)
	}
	
	def getCmlClass(EObject context, String qn) {
		val desc = context.getVisibleClassesDescriptions.findFirst[qualifiedName.toString == qn]

		if (desc === null)
			return null

		var o = desc.EObjectOrProxy
		if (o.eIsProxy)
			o = context.eResource.resourceSet.getEObject(desc.EObjectURI, true)

		return (o as Class)
	}

}
