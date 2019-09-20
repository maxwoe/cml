package at.ac.univie.swa.linking

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer
import org.eclipse.xtext.linking.lazy.LazyLinker

class CmlLinker extends LazyLinker {

	/**
	 * Logger
	 */
	static final Logger log = Logger.getLogger(CmlLinker);
	
	override beforeModelLinked(EObject model, IDiagnosticConsumer diagnosticsConsumer) {
		log.debug("beforeModelLinked")
		super.beforeModelLinked(model, diagnosticsConsumer)
		
	}

	override afterModelLinked(EObject model, IDiagnosticConsumer diagnosticsConsumer) {
		log.debug("afterModelLinked")
		super.afterModelLinked(model, diagnosticsConsumer)
	}
	
}
