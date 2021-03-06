/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.ui.contentassist

import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.NamedElement
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.viewers.StyledString

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class CmlProposalProvider extends AbstractCmlProposalProvider {

	@Inject extension CmlModelUtil

	override getStyledDisplayString(EObject element, String qualifiedNameAsString, String shortName) {
		// TODO resolve proxy
		if (!element.eIsProxy) {
			if (element instanceof Feature) {
				new StyledString(element.featureAsStringWithType).append(
					new StyledString(" - " + (element.eContainer as NamedElement).name, StyledString.QUALIFIER_STYLER))
			}
		} else
			super.getStyledDisplayString(element, qualifiedNameAsString, shortName)
	}

}
