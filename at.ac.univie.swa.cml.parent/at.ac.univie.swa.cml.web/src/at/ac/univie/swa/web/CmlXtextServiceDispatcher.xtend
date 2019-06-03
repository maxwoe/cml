package at.ac.univie.swa.web

import com.google.inject.Inject
import javax.inject.Singleton
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.web.server.IServiceContext
import org.eclipse.xtext.web.server.InvalidRequestException
import org.eclipse.xtext.web.server.XtextServiceDispatcher

@Log
@Singleton
class CmlXtextServiceDispatcher extends XtextServiceDispatcher {

	@Inject
	GeneratorService2 generatorService;

	override protected getGeneratorService(IServiceContext context) throws InvalidRequestException {
		new ServiceDescriptor => [
			service = [
				try {
					/*getDocumentAccess(context).readOnly([state, cancelIndicator |
					 *     generatorService.compute(state, cancelIndicator)
					 ])*/
					generatorService.getResult(getDocumentAccess(context))
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
		]
	}

}
