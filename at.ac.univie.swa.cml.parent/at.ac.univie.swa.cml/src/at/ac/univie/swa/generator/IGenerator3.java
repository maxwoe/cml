package at.ac.univie.swa.generator;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.IFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator2;
import org.eclipse.xtext.generator.IGeneratorContext;

public interface IGenerator3 extends IGenerator2 {
    public void doGenerate(Resource r, ResourceSet set, IFileSystemAccess2 fsa, IGeneratorContext context);
}
