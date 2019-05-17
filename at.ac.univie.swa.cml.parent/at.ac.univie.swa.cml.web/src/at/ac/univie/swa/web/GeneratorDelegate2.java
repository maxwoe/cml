package at.ac.univie.swa.web;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.GeneratorContext;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.IGeneratorContext;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.inject.Inject;

import at.ac.univie.swa.generator.IGenerator3;

public class GeneratorDelegate2 implements IGenerator, IGenerator3 {
	
	@Inject(optional = true)
	private IGenerator legacyGenerator;
	
	@Inject(optional = true)
	private IGenerator3 generator;
	
	public IGenerator getLegacyGenerator() {
		return legacyGenerator;
	}
	
	public void generate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		try {
			beforeGenerate(input, fsa, context);
			doGenerate(input, fsa, context);
		} finally {
			afterGenerate(input, fsa, context);
		}
	}
	
	public void generate(Resource input, ResourceSet set, IFileSystemAccess2 fsa, IGeneratorContext context) {
		try {
			beforeGenerate(input, fsa, context);
			doGenerate(input, set, fsa, context);
		} finally {
			afterGenerate(input, fsa, context);
		}
	}

	@Override
	public void doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		if (generator != null) {
			generator.doGenerate(input, fsa, context);
		} else if (getLegacyGenerator() != null) {
			getLegacyGenerator().doGenerate(input, fsa);
		}
	}

	@Override
	public void beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		if (generator != null) {
			generator.beforeGenerate(input, fsa, context);
		}
	}

	@Override
	public void afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		if (generator != null) {
			generator.afterGenerate(input, fsa, context);
		}
	}

	@Override
	public void doGenerate(Resource input, IFileSystemAccess fsa) {
		IFileSystemAccess2 casted = (IFileSystemAccess2) fsa;
		GeneratorContext context = new GeneratorContext();
		context.setCancelIndicator(CancelIndicator.NullImpl);
		try {
			beforeGenerate(input, casted, context);
			doGenerate(input, casted, context);
		} finally {
			afterGenerate(input, casted, context);
		}
	}

	@Override
	public void doGenerate(Resource r, ResourceSet set, IFileSystemAccess2 fsa, IGeneratorContext context) {
		if (generator != null) {
			generator.doGenerate(r, set, fsa, context);
		} else if (getLegacyGenerator() != null) {
			getLegacyGenerator().doGenerate(r, fsa);
		}
	}
	
}
