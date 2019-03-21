package at.ac.univie.swa.scoping

import com.google.inject.Singleton
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy

@Singleton
class CmlResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

//	override createEObjectDescriptions(EObject e, IAcceptor<IEObjectDescription> acceptor) {
//		if (e instanceof Block) {
//			// don't index contents of a block
//			false
//		} else
//			super.createEObjectDescriptions(e, acceptor)
//	}

}