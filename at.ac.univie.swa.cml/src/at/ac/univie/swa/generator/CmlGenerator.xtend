/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.generator

import at.ac.univie.swa.cml.CmlProgram
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CmlGenerator extends AbstractGenerator {
	
    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {    
        for (e : resource.allContents.toIterable.filter(CmlProgram)) {		
            fsa.generateFile(resource.URI.trimFileExtension + ".sol", e.compile)         
        }
    }
 
    def compile(CmlProgram c) '''
		pragma solidity >=0.4.22 <0.7.0;
		
	'''

}

