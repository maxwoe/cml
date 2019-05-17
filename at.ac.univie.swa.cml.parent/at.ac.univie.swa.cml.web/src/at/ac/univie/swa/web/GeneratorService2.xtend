package at.ac.univie.swa.web

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.web.server.generator.GeneratorResult
import org.eclipse.xtext.web.server.generator.GeneratorService
import org.eclipse.xtext.web.server.generator.IContentTypeProvider
import org.eclipse.xtext.web.server.model.IXtextWebDocument
import org.eclipse.emf.ecore.resource.ResourceSet

@Singleton
class GeneratorService2 extends GeneratorService {
	
	@Inject GeneratorDelegate2 generator
	
	@Inject IContentTypeProvider contentTypeProvider
	
	@Inject Provider<InMemoryFileSystemAccess> fileSystemAccessProvider
	
	@Inject Provider<ResourceSet> rs
	
	override compute(IXtextWebDocument it, CancelIndicator cancelIndicator) {
		val fileSystemAccess = fileSystemAccessProvider.get
		generator.generate(resource, rs.get, fileSystemAccess, [cancelIndicator])
		val result = new GeneratedArtifacts
		result.artifacts.addAll(fileSystemAccess.textFiles.entrySet.map[
			val contentType = contentTypeProvider.getContentType(key)
			new GeneratorResult(key, contentType, value.toString)
		])
		return result
	}
	
}