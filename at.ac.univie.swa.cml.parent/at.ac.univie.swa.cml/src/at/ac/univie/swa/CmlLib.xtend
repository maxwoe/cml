package at.ac.univie.swa

import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.scoping.CmlIndex
import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet

class CmlLib {
	@Inject extension CmlIndex

	public val static LIB_PACKAGE = "cml.lang"
	public val static LIB_ANY = LIB_PACKAGE + ".Any"
	public val static LIB_BOOLEAN = LIB_PACKAGE + ".Boolean"
	public val static LIB_STRING = LIB_PACKAGE + ".String"
	public val static LIB_NUMBER = LIB_PACKAGE + ".Number"
	public val static LIB_INTEGER = LIB_PACKAGE + ".Integer"
	public val static LIB_REAL = LIB_PACKAGE + ".Real"
	public val static LIB_DURATION = LIB_PACKAGE + ".Duration"
	public val static LIB_DATETIME = LIB_PACKAGE + ".DateTime"
	public val static LIB_ACCOUNT = LIB_PACKAGE + ".Account"
	public val static LIB_PARTY = LIB_PACKAGE + ".Party"
	public val static LIB_ASSET = LIB_PACKAGE + ".Asset"
	public val static LIB_TRANSACTION = LIB_PACKAGE + ".Transaction"
	public val static LIB_EVENT = LIB_PACKAGE + ".Event"
	public val static LIB_ENUM = LIB_PACKAGE + ".Enum"
	public val static LIB_CONTRACT = LIB_PACKAGE + ".Contract"
	public val static LIB_ERROR = LIB_PACKAGE + ".Error"

	public val static MAIN_LIB = "cml/lang/mainlib.cml"
	public val static SOLIDITY_GENERATOR_ANNOTATION = "cml/lang/sol-annotation.cml"
	
	public val static LIB_TOKEN = LIB_PACKAGE + ".Token"
	public val static LIB_PARTICIPANT = LIB_PACKAGE + ".Participant"
	public val static LIB_TOKEN_TRANSACTION = LIB_PACKAGE + ".TokenTransaction"
	
	public val static LIB_COLLECTION = LIB_PACKAGE + ".Collection"
	public val static LIB_ARRAY = LIB_PACKAGE + ".Array"
	public val static LIB_MAP = LIB_PACKAGE + ".OrderedMap"

	static final Logger LOG = Logger.getLogger(CmlLib);
	
	def loadMainLib(ResourceSet resourceSet) {
		resourceSet.loadLib(MAIN_LIB)
	}
	
	def loadSolidityGeneratorAnnotationLib(ResourceSet resourceSet) {
		resourceSet.loadLib(at.ac.univie.swa.CmlLib.SOLIDITY_GENERATOR_ANNOTATION)
	}
	
	def loadLib(ResourceSet resourceSet, String library) {
		val url = getClass().getClassLoader().getResource(library)
		val stream = url.openStream
		val urlPath = url.path
		val resource = resourceSet.createResource(URI.createFileURI(urlPath))
		LOG.debug("loading library " + urlPath)
		resource.load(stream, resourceSet.getLoadOptions())
	}

	def getCmlAnyClass(EObject context) {
		getCmlClass(context, LIB_ANY)
	}
	
	def getCmlPartyClass(EObject context) {
		getCmlClass(context, LIB_PARTY)
	}
	
	def getCmlAssetClass(EObject context) {
		getCmlClass(context, LIB_ASSET)
	}
	
	def getCmlTransactionClass(EObject context) {
		getCmlClass(context, LIB_TRANSACTION)
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
	
	def getCmlEnumClass(EObject context) {
		getCmlClass(context, LIB_ENUM)
	}
	
	def getCmlArrayClass(EObject context) {
		getCmlClass(context, LIB_ARRAY)
	}
	
	def getCmlMapClass(EObject context) {
		getCmlClass(context, LIB_MAP)
	}
	
	def getCmlCollectionClass(EObject context) {
		getCmlClass(context, LIB_COLLECTION)
	}
	
	def getCmlClass(EObject context, String qn) {
		val desc = context.getVisibleClassesDescriptions.findFirst[qualifiedName.toString == qn]

		if (desc === null)
			return null

		var o = desc.EObjectOrProxy
		if (o.eIsProxy)
			o = context.eResource.resourceSet.getEObject(desc.EObjectURI, true)

		return (o as CmlClass)
	}
	
}
