/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa

import at.ac.univie.swa.scoping.CmlImportedNamespaceAwareLocalScopeProvider
import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class CmlRuntimeModule extends AbstractCmlRuntimeModule {
	
	override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider)
		.annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE))
		.to(CmlImportedNamespaceAwareLocalScopeProvider);
	}
	/* 
	override bindIGlobalScopeProvider() {
        ImportUriGlobalScopeProvider
        //ResourceSetGlobalScopeProvider
    }*/
    
	/*
    override configureIScopeProviderDelegate(Binder binder) {
        binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE))
            .to(SimpleLocalScopeProvider);

    }*/
    
    /*override bindIQualifiedNameProvider() {
		CmlQualifiedNameProvider
	}*/


	/*override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE))
		.to(MyDslImportedNamespaceAwareLocalScopeProvider) 

	}*/
	/* */
}
