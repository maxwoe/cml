package at.ac.univie.swa.typing

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.linking.impl.DefaultLinkingService
import org.eclipse.xtext.linking.impl.IllegalNodeException
import org.eclipse.xtext.nodemodel.INode

class CmlLinkerService extends DefaultLinkingService {

	override getLinkedObjects(EObject context, EReference ref, INode node) throws IllegalNodeException {
		super.getLinkedObjects(context, ref, node)
	}

}
