package at.ac.univie.swa.scoping

import at.ac.univie.swa.cml.Block
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor

@Singleton
class CmlResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	override createEObjectDescriptions(EObject e, IAcceptor<IEObjectDescription> acceptor) {
		if (e instanceof Block) {
			// don't index contents of a block
			false
		} else
			super.createEObjectDescriptions(e, acceptor)
	}

}