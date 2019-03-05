package at.ac.univie.swa;

import javax.inject.Inject;

import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.IQualifiedNameConverter;
import org.eclipse.xtext.naming.QualifiedName;

import at.ac.univie.swa.cml.Action;
import at.ac.univie.swa.cml.Attribute;

public class CmlQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {

	@Inject
	private IQualifiedNameConverter qnc;

	public QualifiedName qualifiedName(Attribute a) {

		Action action = EcoreUtil2.getContainerOfType(a, Action.class);

		if (action != null) {
			System.out.println("attr: " + a.getName());
			return qnc.toQualifiedName(action.getName()).append(qnc.toQualifiedName(a.getName()));
			/*for (Attribute attr : action.getArgs()) {
				
				
			}*/
		}

		return qnc.toQualifiedName(a.getName());
	}

}
