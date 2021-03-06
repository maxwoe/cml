/*
 * generated by Xtext 2.17.1
 */
package at.ac.univie.swa

import at.ac.univie.swa.generator.CmlGenerator
import at.ac.univie.swa.generator.IGenerator3
import at.ac.univie.swa.scoping.CmlImportedNamespaceAwareLocalScopeProvider
import at.ac.univie.swa.scoping.CmlResourceDescriptionStrategy
import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class CmlRuntimeModule extends AbstractCmlRuntimeModule {

	def Class<? extends IDefaultResourceDescriptionStrategy> bindIDefaultResourceDescriptionStrategy() {
		CmlResourceDescriptionStrategy
	}
	
	override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
			CmlImportedNamespaceAwareLocalScopeProvider);
	}

	/*override bindILinkingService() {
		return CmlLinkerService
	}
	
	override bindILinker() {
		return CmlLinker
	}*/

	def Class<? extends IGenerator3> bindIGenerator3() {
		return CmlGenerator
	}
}
