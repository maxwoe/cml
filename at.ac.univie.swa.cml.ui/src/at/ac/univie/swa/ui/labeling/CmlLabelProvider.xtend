/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.ui.labeling

import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Feature
import at.ac.univie.swa.cml.Operation
import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.viewers.StyledString
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class CmlLabelProvider extends DefaultEObjectLabelProvider {

	@Inject extension CmlModelUtil
	
	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	def text(Feature f) {
		new StyledString(f.featureAsString).append(new StyledString(" : " + f.typeOf.typeName,
			StyledString.DECORATIONS_STYLER))
	}

	def image(Operation o) {
		"methpub_obj.gif"
	}

	def image(Attribute a) {
		"field_public_obj.gif"
	}

	def image(Class c) {
		"sj_class_obj.gif"
	}
	
}
