/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.generator

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndCompoundAction
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.Antecedent
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.AtomicAction
import at.ac.univie.swa.cml.Attribute
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CallerExpression
import at.ac.univie.swa.cml.CastedExpression
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.CompoundAction
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DoWhileStatement
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EnsureStatement
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelection
import at.ac.univie.swa.cml.ForStatement
import at.ac.univie.swa.cml.IfStatement
import at.ac.univie.swa.cml.Import
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NestedCompoundAction
import at.ac.univie.swa.cml.NestedExpression
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrCompoundAction
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.PostfixExpression
import at.ac.univie.swa.cml.RealLiteral
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.ReturnStatement
import at.ac.univie.swa.cml.SeqCompoundAction
import at.ac.univie.swa.cml.Statement
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.SuperExpression
import at.ac.univie.swa.cml.SwitchStatement
import at.ac.univie.swa.cml.SymbolReference
import at.ac.univie.swa.cml.ThisExpression
import at.ac.univie.swa.cml.ThrowStatement
import at.ac.univie.swa.cml.TimeConstraint
import at.ac.univie.swa.cml.Type
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.cml.WhileStatement
import at.ac.univie.swa.cml.XorCompoundAction
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CmlGenerator extends AbstractGenerator2 {

	public final boolean DECOMPOSE_STRUCTS = true  
	
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance
	@Inject extension CmlTypeProvider
	Iterable<CmlProgram> allResources;

	override doGenerate(Resource resource, ResourceSet input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		allResources = input.resources.map(r|r.allContents.toIterable.filter(CmlProgram)).flatten

		copyResource("Escrow.sol", fsa)
		copyResource("Ownable.sol", fsa)
		copyResource("PullPayment.sol", fsa)
		copyResource("SafeMath.sol", fsa)
		copyResource("Secondary.sol", fsa)

		for (p : resource.allContents.toIterable.filter(CmlProgram)) {
			if (!p.contracts.empty)
				fsa.generateFile(resource.URI.trimFileExtension.segmentsList.drop(3).join("/") + ".sol", p.compile)
		}
	}

	def copyResource(String resourceName, IFileSystemAccess2 fsa) {
		var url = getClass().getClassLoader().getResource("resources/openzeppelin/" + resourceName)
		var inputStream = url.openStream
		try {
			fsa.generateFile("lib/" + resourceName, inputStream)
		} finally {
			inputStream.close();
		}
	}

	def compile(CmlProgram program) '''
		pragma solidity >=0.4.22 <0.7.0;
		�FOR contract : program.contracts�
			import "./lib/Ownable.sol";
			import "./lib/PullPayment.sol";
			
			contract �contract.name� is Ownable, PullPayment {
			
���				�contract.compileStates�
				�contract.compileEnums�
				�contract.compileStructs�
				�contract.compileEvents�
				�"/*\n * State variables\n */\n"�
				�contract.compileAttributes�
				uint _contractStart;
				mapping(bytes4 => bool) _callSuccessMonitor;
				
				�"/*\n * Constructor\n */\n"�
				�contract.compileConstructor�
���				�contract.compileSetupStates�

				�"/*\n * Functions\n */\n"�
				�contract.compileFunctions�
				�contract.compileEventFunctions�
				// Fallback function
				function() external payable {}
				
				�"/*\n * Modifiers\n */\n"�
				modifier onlyBy(address _account) { 
					require(msg.sender == _account, "Sender not authorized."); _;
				}
				
				modifier when(bool _condition) {
				       require(_condition); _;
				}
				
				modifier onlyAfter(uint _time, uint _duration, bool _within) {
					if(!_within)
						require(now > _time + _duration, "Function called too early.");
					else require(_time + _duration > now && now > _time, "Function not called within expected timeframe."); _;
				}
				
				modifier onlyBefore(uint _time, uint _duration, bool _within) {
					if(!_within)
						require(now < _time - _duration, "Function called too late.");
					else require(_time - _duration < now && now < _time, "Function not called within expected timeframe."); _;
				}
				
				modifier postCall() {
				    _; _callSuccessMonitor[msg.sig] = true;
				}
				   
			}
		�ENDFOR�
	   '''

	def compileEventFunctions(Class c) '''
		�FOR e : c.attributes.filter[type.conformsToEvent] SEPARATOR "\n" AFTER "\n"�
			�e.compileEventAsFunction�
		�ENDFOR�
	'''

	def compileFunctions(Class c) '''
		�FOR cl : c.clauses�
			�FOR aa : cl.action.compoundAction.eAllOfType(AtomicAction) SEPARATOR "\n" AFTER "\n"�
				�aa.operation.compile(aa.containingClause)�
			�ENDFOR�
		�ENDFOR�
	'''

	def String compileEnums(Class c) '''
		�FOR a : c.gatherEnums BEFORE "/*\n * Enums\n */\n" SEPARATOR "" AFTER "\n"�
			�a.compileEnum�
		�ENDFOR�
	'''
	
	def Set<Class> gatherEnums(Class c) {
		var set = newLinkedHashSet
		for(class : c.attributes.map[type]) {
			if(class.conformsToEnum || class.subclassOfEnum)
				set.add(class)
			set.addAll(gatherEnums(class))
		}
		set
	}
	
	def String compileStructs(Class c) '''
		�FOR entry : c.gatherStructs BEFORE "/*\n * Structs\n */\n" SEPARATOR "\n" AFTER "\n"�
			�entry.compile�
		�ENDFOR�
	'''
	
	def Set<Class> gatherStructs(Class c) {
		var set = newLinkedHashSet
		for(class : c.attributes.filter[type.conformsToAsset || type.subclassOfAsset || type.subclassOfParty].map[type]) {
			set.add(class)
			set.addAll(gatherStructs(class))
		}
		set
	}
	
	def compileAttributes(Class c) '''
		�FOR a : c.attributes.filter[!type.conformsToEnum && !type.subclassOfEnum]�
			�a.compile�;
		�ENDFOR�
	'''

	def compileEvents(Class c) '''
		�FOR e : c.attributes.filter[type.conformsToEvent] BEFORE "/*\n * Events\n */\n" AFTER "\n"�
			event �e.type.name.toFirstUpper�();
		�ENDFOR�
	'''

	def compileConstructor(Class c) {
		val initOperation = c.operations.findFirst[name == "init"]
		if (initOperation !== null)
			initOperation.compileInitConstructor
		else
			c.compileStandardConstructor
	}

	def compileInitConstructor(Operation o) '''	
		constructor(�o.params.compileOperationParams�) �FOR a : o.compileAnnotations SEPARATOR ' '��a��ENDFOR�
		{
			�FOR s : o.body?.statements ?: emptyList�
				�compileStatement(s)�
			�ENDFOR�
			_contractStart = now;
���			setupStates();
		}
	'''

	def compileStandardConstructor(Class c) '''
		constructor() public {
			_contractStart = now;
���			setpStates();
		}
    '''

	def compileStates(Class c) '''
		�FOR s : c.clauses.indexed�
			bytes32 constant STATE�s.key� = "�s.value.name�";
		�ENDFOR�
		bytes32[] states = [�FOR s : c.clauses.indexed SEPARATOR ", "�STATE�s.key��ENDFOR�];
		
	'''

	def compileSetupStates(Class c) '''
		function setupStates() internal {
		    setStates(states);
		    
			�FOR i : c.clauses.indexed�
				�FOR j : i.value.action.compoundAction.eAllOfType(AtomicAction)�
					allowFunction(STATE�i.key�, this.�j.operation.name�.selector);    		
					�ENDFOR�
				�ENDFOR�
			}
	'''

	def String compile(CompoundAction ca) {
		switch (ca) {
			XorCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " || " + right
			}
			OrCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " || " + right
			}
			SeqCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " then " + right
			}
			AndCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " && " + right
			}
			NestedCompoundAction: {
				"(" + ca.child.compile + ")"
			}
			AtomicAction:
				ca.operation.name
		}
	}
	
	def compile(Attribute a) '''
		�(a.type as Type).compile� �a.name�'''

	def compile(Class c) '''
		struct �c.name.toFirstUpper� {
			�FOR a : c.classHierarchyAttributes.values�
				�a.compile�;
	   		�ENDFOR�
		}
	'''

	def compile(Operation o, Clause c) '''	
		// @notice function for clause �c.name�
		function �o.name�(�o.params.compileOperationParams�) �FOR a : o.compileAnnotations SEPARATOR ' '��a��ENDFOR�
			�FOR m : o.deriveModifiers(c).entrySet SEPARATOR ' '�
				�m.key�(�m.value.join(", ")�)
			�ENDFOR�
			�IF o.type !== null�returns (�o.type.compileOperationReturn�)�ENDIF�
		{
			�FOR s : o.body?.statements ?: emptyList�
				�compileStatement(s)�
			�ENDFOR�
		}
	'''
	
	def HashMap<Attribute, String> decompose(Class c, String prefix) {
		var map = newLinkedHashMap
		for(entry : c.classHierarchyAttributes.entrySet) {
			if(entry.value.type.conformsToLibraryType) {
				var name = ""
				if (prefix.nullOrEmpty)
					name = entry.value.name
				else name = prefix + entry.value.name.toFirstUpper
				map.put(entry.value, name)
			}
			else map.putAll(decompose(entry.value.type, entry.value.name))
		}
		map
	}
	
	def compileOperationParams(List<Attribute> attributes) '''
		�FOR a : attributes SEPARATOR ', '�
			�IF !a.type.conformsToLibraryType && DECOMPOSE_STRUCTS�		
			�FOR da : a.type.decompose("").entrySet SEPARATOR ', '�
			�da.key.compile��ENDFOR��ELSE��a.compile�
			�ENDIF�
		�ENDFOR�'''
		
	def compileOperationReturn(Class c) '''
		�IF !c.conformsToLibraryType && DECOMPOSE_STRUCTS�
			�FOR a : c.decompose("").keySet SEPARATOR ', '��(a.type as Type).compile��ENDFOR��ELSE��(c as Type).compile��ENDIF�'''

	def List<String> compileAnnotations(Operation o) {
		var list = newArrayList
		list.add("public")
		if (o.containsDepositOperation)
			list.add("payable")
		list
	}

	def containsDepositOperation(Operation o) {
		o.body?.statements?.filter(FeatureSelection)?.filter[opCall && feature instanceof Operation]?.map[feature]?.
			findFirst[containingClass.conformsToParty && name == "deposit"] !== null
	}

	def deriveModifiers(Operation o, Clause c) {
		var modifiers = new LinkedHashMap<String, List<String>>();
		var party = c.actor.party
		var tc = c.antecedent.temporal
		var gc = c.antecedent.general
		if (party.name != "anyone")
			modifiers.put("onlyBy", #[party.name])
		if (tc !== null) {
			if (tc.reference instanceof Expression) {
				if (tc.timeframe === null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper,
						#[(tc.reference as Expression).compile, "0", "false"])
				if (tc.closed == false && tc.timeframe !== null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper,
						#[(tc.reference as Expression).compile, tc.timeframe.compile, "false"])
				if (tc.closed == true && tc.timeframe !== null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper,
						#[(tc.reference as Expression).compile, tc.timeframe.compile, "true"])
			}
		}
		if (gc !== null)
			modifiers.put("when", #[gc.expression.compile])
		modifiers.put("postCall", emptyList)
		modifiers
	}

	def compileBlock(Block block) '''
		{	
			�FOR s : block.statements�
				�s.compileStatement�
			�ENDFOR�
		}
	'''
	
	def String compileReturn(Expression exp) {
		if (DECOMPOSE_STRUCTS) {
			switch (exp) {
				SymbolReference: {
					val symbol = exp.symbol
					switch (symbol) {
						Class case exp.opCall ==
							true: '''�FOR arg : exp.args SEPARATOR ', '��arg.compileReturn��ENDFOR�'''
						VariableDeclaration: '''�FOR a : symbol.type.decompose("").keySet SEPARATOR ', '��symbol.name�.�a.name��ENDFOR�'''
						Attribute: '''�FOR a : symbol.type.decompose("").keySet SEPARATOR ', '��symbol.name�.�a.name��ENDFOR�'''
					}
				}
				default:
					exp.compile
			}
		} else
			exp.compile
	}

	def String compileStatement(Statement s) {
		switch (s) {
			VariableDeclaration: '''�(s.type as Type).compile� �IF !s.expression.eAllOfType(SymbolReference).filter[typeFor instanceof Class && opCall].empty�memory �ENDIF��s.name� = �s.expression.compile�;'''
			ReturnStatement:
				"return (" + s.expression.compileReturn + ");"
			IfStatement: '''
				if (�s.condition.compile�)
				�s.thenBlock.compileBlock�
				�IF s.elseBlock !== null�
					else
					�s.elseBlock.compileBlock�
				�ENDIF�
			'''
			SwitchStatement: '''
				�FOR c : s.cases.indexed�
					�IF c.key == 0�if �ELSE�else if�ENDIF�(�s.declaration.compile� == �c.value.^case.compile�)
					�c.value.thenBlock.compileBlock�
				�ENDFOR�
				�IF s.^default�
					else
					�s.defaultBlock.compileBlock�
				�ENDIF�
			'''
			DoWhileStatement: '''
				do
				�s.block.compileBlock�
				while (�s.condition.compile�);
			'''
			WhileStatement: '''
				while (�s.condition.compile�)
				�s.block.compileBlock�
			'''
			ForStatement: '''
				for (�s.declaration.compileStatement� �s.condition.compile�; �s.progression.compile�)
				�s.block.compileBlock�
			'''
			EnsureStatement: '''require(�s.condition.compile��IF s.throwExpression !== null�, �s.throwExpression.compile��ENDIF�);'''
			ThrowStatement: '''revert(�s.expression?.compile�);'''
			default:
				(s as Expression).compile + ";"
		}
	}

	def compileEventAsFunction(Attribute a) '''
		// @notice trigger event �a.type.name�
		function �a.name.toFirstLower�Event() public
		{
			�a.name� = true;
			emit �a.type.name.toFirstUpper�();
		}
	'''

	def compileEnum(Class c) '''
		enum �c.name.toFirstUpper� { �FOR e : c.enumElements SEPARATOR ', '��e.name��ENDFOR� } �c.name.toFirstUpper� �c.name.toFirstLower�;
	'''

	def compile(Type t) {
		switch (t) {
			Class:
				switch (t) {
					case t.conformsToInteger: "uint"
					case t.conformsToBoolean: "bool"
					case t.conformsToString: "bytes32"
					case t.conformsToReal: "uint"
					case t.conformsToDateTime: "uint"
					case t.conformsToDuration: "uint"
					case t.conformsToEnum: t.name
					case t.conformsToAsset: t.name
					case t.conformsToParty: "address payable"
					case t.conformsToEvent: "bool"
					default: t.name
				}
		}
	}

	def compile(Antecedent a, Clause c) '''
		// @notice modifier for clause �c.name�
		modifier guard() {
			�IF a.temporal !== null�require(�a.temporal.compile�)�ENDIF�;
			require(�a.general.expression.compile�); _;
		}
	'''

	def compileModifier(Expression e) '''
		// @notice modifier for function �e.containingOperation.name�
		modifier guard_�e.containingOperation.name�() {
			require(�e.compile�); _;
		}
	'''

	def compile(TimeConstraint tc) {
		var modifiers = new LinkedHashMap<String, List<String>>();
		if (tc.closed == false && tc.timeframe === null) {
			if (tc.precedence == "after" && tc.reference instanceof Expression)
				modifiers.put("onlyAfter", #[(tc.reference as Expression).compile, "0"])
			if (tc.precedence == "before" && tc.reference instanceof Expression)
				modifiers.put("onlyBefore", #[(tc.reference as Expression).compile, "0"])
		}
	}

	def retrieveImport(Iterable<CmlProgram> resources, Import i) {
		if (i.importedNamespace !== CmlLib::LIB_PACKAGE)
			resources.findFirst[name == i.copy.importedNamespace.replace(".*", "")]
	}

	def gatherImportedResources(CmlProgram program) {
		var list = newArrayList
		for (import : program.imports) {
			list += this.allResources.retrieveImport(import)
		}
		list
	}

	def String compile(Expression exp) {

		switch (exp) {
			AssignmentExpression: '''�(exp.left.compile)� = �(exp.right.compile)�'''
			OrExpression: '''�(exp.left.compile)� || �(exp.right.compile)�'''
			AndExpression: '''�(exp.left.compile)� && �(exp.right.compile)�'''
			EqualityExpression: {
				if (exp.op == '==')
					'''�(exp.left.compile)� == �(exp.right.compile)�'''
				else
					'''�(exp.left.compile)� != �(exp.right.compile)�'''
			}
			RelationalExpression: {
				val left = exp.left.compile
				val right = exp.right.compile

				switch (exp.op) {
					case '<': '''�left� < �right�'''
					case '>': '''�left� > �right�'''
					case '>=': '''�left� >= �right�'''
					case '<=': '''�left� <= �right�'''
					default:
						""
				}
			}
			AdditiveExpression: {
				if (exp.op == '+')
					'''�(exp.left.compile)� + �(exp.right.compile)�'''
				else
					'''�(exp.left.compile)� - �(exp.right.compile)�'''
			}
			MultiplicativeExpression: {
				val left = exp.left.compile
				val right = exp.right.compile
				if (exp.op == '*')
					'''�left� * �right�'''
				else
					'''�left� / �right�'''
			}
			UnaryExpression: {
				switch (exp.op) {
					case '+': ''' +�(exp.operand.compile)�'''
					case '-': ''' -�(exp.operand.compile)�'''
					case '!',
					case 'not': ''' !�(exp.operand.compile)�'''
					default:
						""
				}
			}
			PostfixExpression: {
				if (exp.op == '++')
					'''�(exp.operand.compile)�++'''
				else
					'''�(exp.operand.compile)�--'''
			}
			CastedExpression: '''�exp.target.compile�'''
			NestedExpression: '''(�exp.child.compile�)'''
			RealLiteral: '''�exp.value�'''
			IntegerLiteral: '''�exp.value�'''
			BooleanLiteral: '''�exp.value�'''
			StringLiteral: '''"�exp.value�"'''
			SuperExpression: '''super'''
			ThisExpression: '''this''' // concept doesn't exist in the same manner in solidity
			DateTimeLiteral: '''�exp.value�'''
			DurationLiteral: '''�exp.value� �exp.unit�'''
			CallerExpression: '''msg.sender'''
			SymbolReference: '''�exp.compile�'''
			FeatureSelection: '''�exp.compile�'''
		}
	}

	def compile(FeatureSelection fs) {
		var String rslt

		if (!fs.opCall && fs.feature instanceof Attribute)
			rslt = interceptAttribute(fs.feature as Attribute, fs)

		if (fs.opCall && fs.feature instanceof Operation)
			rslt = interceptOperation(fs.feature as Operation, fs.args, fs.receiver)

		rslt ?: {
			(if(!fs.receiver.compile.nullOrEmpty) fs.receiver.compile + "." else "") +
			fs.feature.name + if (fs.opCall) {
				"(" + fs.args.map[compile].join(", ") + ")"
			} else
				""
		}
	}

	def compile(SymbolReference sr) {
		var String rslt

		if (!sr.opCall && sr.symbol instanceof Attribute)
			rslt = interceptAttribute(sr.symbol as Attribute, sr)

		if (sr.opCall && sr.symbol instanceof Operation)
			rslt = interceptOperation(sr.symbol as Operation, sr.args, sr)

		if (sr.opCall && sr.symbol instanceof Class)
			rslt = interceptClass(sr.symbol as Class, sr.args, sr)

		rslt ?: {
			(if(sr.containingOperation !== null && sr.containingOperation.params.contains(sr.symbol) && DECOMPOSE_STRUCTS) "" else sr.symbol.name) + 
			if (sr.opCall) {
				"(" + sr.args.map[compile].join(", ") + ")"
			} else
				""
		}
	}

	def interceptClass(Class c, List<Expression> args, Expression reference) {
		switch (c) {
			case c.conformsToError: {
				args.get(0).compile
			}
		}
	}

	def interceptAttribute(Attribute a, Expression reference) {
		val containingClass = a.containingClass

		if (containingClass.conformsToContract) {
			switch (a.name) {
				case "contractStart": "_contractStart"
				case "balance": "address(this).balance"
			}
		} else if (containingClass.conformsToParty && reference === null) {
			switch (a.name) {
				case "id": "address payable" + a.name
			}
		}
	}

	def interceptOperation(Operation o, List<Expression> args, Expression reference) {
		var containingClass = o.containingClass
		switch (containingClass) {
			case containingClass.conformsToDateTime: {
				switch (o.name) {
					case "addDuration": reference.compile + " + " + args.get(0).compile
					case "subtractDuration": reference.compile + " - " + args.get(0).compile
				}
			}
			case containingClass.conformsToParty: {
				switch (o.name) {
					case "deposit": "require(msg.value == " + args.get(0).compile + ")"
					case "transfer": "_asyncTransfer(" + reference.compile + ", " + args.get(0).compile + ")"
				}
			}
		}
	}

}
