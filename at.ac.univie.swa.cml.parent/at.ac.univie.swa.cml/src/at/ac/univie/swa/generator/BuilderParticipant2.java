package at.ac.univie.swa.generator;

import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.builder.BuilderParticipant;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.builder.MonitorBasedCancelIndicator;
import org.eclipse.xtext.generator.GeneratorContext;
import org.eclipse.xtext.resource.IContainer;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.IResourceDescription.Delta;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider;

import com.google.inject.Inject;

public class BuilderParticipant2 extends BuilderParticipant {
	@Inject
	private ResourceDescriptionsProvider resourceDescriptionsProvider;

	@Inject
	private IContainer.Manager containerManager;

	@Inject(optional = true)
	private IGenerator3 generator;

	protected ThreadLocal<Boolean> buildSemaphor = new ThreadLocal<Boolean>();

	public void build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		buildSemaphor.set(false);
		super.build(context, monitor);
	}
	
	protected void handleChangedContents(Delta delta, IBuildContext context,
			EclipseResourceFileSystemAccess2 fileSystemAccess) throws CoreException {
		super.handleChangedContents(delta, context, fileSystemAccess);
		if (!buildSemaphor.get() && generator != null) {
			invokeGenerator(delta, context, fileSystemAccess);
		}
	}
	private void invokeGenerator(Delta delta, IBuildContext context, EclipseResourceFileSystemAccess2 access) {
		buildSemaphor.set(true);
		Resource resource = context.getResourceSet().getResource(delta.getUri(), true);
		if (shouldGenerate(resource, context)) {
			IResourceDescriptions index = resourceDescriptionsProvider.createResourceDescriptions();
			IResourceDescription resDesc = index.getResourceDescription(resource.getURI());
			List<IContainer> visibleContainers = containerManager.getVisibleContainers(resDesc, index);
			for (IContainer c : visibleContainers) {
				for (IResourceDescription rd : c.getResourceDescriptions()) {
					context.getResourceSet().getResource(rd.getURI(), true);
				}
			}

			MonitorBasedCancelIndicator cancelIndicator = new MonitorBasedCancelIndicator(
					new NullProgressMonitor()); //maybe use reflection to read from fsa
			GeneratorContext generatorContext = new GeneratorContext();
			generatorContext.setCancelIndicator(cancelIndicator);
			generator.doGenerate(resource, context.getResourceSet(), access, generatorContext);
		}
	}
}
