package at.ac.univie.swa.scoping;

import javax.inject.Inject;

import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.IQualifiedNameConverter;
import org.eclipse.xtext.naming.QualifiedName;

import at.ac.univie.swa.cml.Attribute;
import at.ac.univie.swa.cml.Operation;

public class CmlQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {

	@Inject
	private IQualifiedNameConverter qnc;

	public QualifiedName qualifiedName(Attribute a) {

		Operation operation = EcoreUtil2.getContainerOfType(a, Operation.class);

		if (operation != null) {
			System.out.println("attr: " + a.getName());
			return qnc.toQualifiedName(operation.getName()).append(qnc.toQualifiedName(a.getName()));
			/*for (Attribute attr : action.getArgs()) {
				
				
			}*/
		}

		return qnc.toQualifiedName(a.getName());
	}

}
