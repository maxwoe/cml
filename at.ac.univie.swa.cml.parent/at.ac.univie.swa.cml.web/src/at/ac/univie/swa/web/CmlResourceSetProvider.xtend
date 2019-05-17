package at.ac.univie.swa.web

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.web.server.IServiceContext
import org.eclipse.xtext.web.server.model.IWebResourceSetProvider
import at.ac.univie.swa.CmlLib

class CmlResourceSetProvider implements IWebResourceSetProvider {
	
	@Inject Provider<ResourceSet> rsp
	@Inject CmlLib cmlLib
	
	override get(String resourceId, IServiceContext serviceContext) {
		val resourceSet = rsp.get
		cmlLib.loadLib(resourceSet)
		return resourceSet
	}
}