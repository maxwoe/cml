package at.ac.univie.swa.scoping

import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

class CmlImportedNamespaceAwareLocalScopeProvider extends ImportedNamespaceAwareLocalScopeProvider{
	
	//@Inject extension IQualifiedNameProvider
	
	override getImplicitImports(boolean ignoreCase) {
		newArrayList(new ImportNormalizer(
			QualifiedName::create("cml", "lang"),
			true,
			ignoreCase
		))
	}
	
	/* 
	override protected List<ImportNormalizer> internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val resolvers = super.internalGetImportedNamespaceResolvers(context, ignoreCase)
		if (context instanceof Model) {
			val fqn = context.fullyQualifiedName
			if (fqn !== null) {
				// all the external classes with the same package of this program
				// will be automatically visible in this program, without an import
				resolvers += new ImportNormalizer(
					fqn,
					true, // use wildcards
					ignoreCase
				)
			}
		}
		return resolvers
	}*/
	
}