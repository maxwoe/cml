/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.generator

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.ActionQuery
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
import at.ac.univie.swa.cml.Clause
import at.ac.univie.swa.cml.ClauseQuery
import at.ac.univie.swa.cml.CmlClass
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.CompoundAction
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DoWhileStatement
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.EventQuery
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.FeatureSelection
import at.ac.univie.swa.cml.ForStatement
import at.ac.univie.swa.cml.IfStatement
import at.ac.univie.swa.cml.Import
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.NamedElement
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
import com.google.inject.Inject
import java.io.InputStream
import java.math.BigDecimal
import java.util.LinkedHashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Scanner
import java.util.Set
import org.apache.log4j.Logger
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

	static final Logger LOG = Logger.getLogger(CmlGenerator)
	int fixedPointDecimals
	boolean fixedPointArithmetic
	boolean safeMath
	boolean pullPayment
	boolean ownable
	@Inject extension CmlModelUtil
	@Inject extension CmlTypeConformance
	Iterable<CmlProgram> allResources
	
	override doGenerate(Resource resource, ResourceSet input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		LOG.info("resource: " + resource)
		
		allResources = input.resources.map(r|r.allContents.toIterable.filter(CmlProgram)).flatten

		copyResource("openzeppelin/Escrow.sol", fsa)
		copyResource("openzeppelin/Ownable.sol", fsa)
		copyResource("openzeppelin/PullPayment.sol", fsa)
		//copyResource("openzeppelin/Math.sol", fsa)
		copyResource("openzeppelin/SafeMath.sol", fsa)
		copyResource("openzeppelin/Secondary.sol", fsa)
		copyResource("other/DSMath.sol", fsa)
		copyResource("other/DateTime.sol", fsa)
		copyResource("other/IntLib.sol", fsa)
		copyResource("other/RealLib.sol", fsa)
		copyResource("other/ConditionalContract.sol", fsa)
		
		for (p : resource.allContents.toIterable.filter(CmlProgram)) {
			if (!p.contracts.empty) {
				fsa.generateFile("/" + resource.URI.trimFileExtension.segmentsList.last + ".sol", p.compile)
			}
		}
	}

	def copyResource(String resourceName, IFileSystemAccess2 fsa) {
		val url = class.classLoader.getResource(resourceName)
		val inputStream = url.openStream
		try {
			fsa.generateFile("/lib/" + resourceName, inputStream.convertToString)
		} finally {
			inputStream.close()
		}
	}
	
	def static convertToString(InputStream is) {
		val Scanner s = new Scanner(is).useDelimiter("\\A")
		if (s.hasNext()) s.next() else ""
	}

	def deriveInheritance(CmlClass c) {
		var list = newLinkedList
		list.add("ConditionalContract")
		if (ownable)
			list.add("Ownable")
		if (pullPayment)
			list.add("PullPayment")
		list
	}
	
	def initGeneratorSettings() {
		fixedPointDecimals = 18
		fixedPointArithmetic = false
		safeMath = false
		pullPayment = false
		ownable = false
	}
	
	def deriveGeneratorSettings(CmlClass c) {
		initGeneratorSettings
		for (a : c.annotations) {
			val annotation = a.name
			switch (annotation) {
				case SAFE_MATH:
					safeMath = true
				case FIXED_POINT_ARITMHMETIC: {
					fixedPointArithmetic = true
					if (!a.params.empty) {
						val integerLiteral = a.params.get(0).value
						if (integerLiteral instanceof IntegerLiteral)
							fixedPointDecimals = integerLiteral.value
					}
				}
				case OWNABLE:
					ownable = true
				case PULL_PAYMENT:
					pullPayment = true
			}
		}
	}
	
	def compile(CmlProgram program) '''
		pragma solidity >=0.4.22 <0.7.0;
		pragma experimental ABIEncoderV2;
		�FOR contract : program.contracts�
			�contract.deriveGeneratorSettings�
			�IF ownable�import "./lib/openzeppelin/Ownable.sol";�ENDIF�
			�IF pullPayment�import "./lib/openzeppelin/PullPayment.sol";�ENDIF�
���			import "./lib/openzeppelin/Math.sol";
			�IF safeMath�import "./lib/openzeppelin/SafeMath.sol";�ENDIF�
			�IF safeMath && fixedPointArithmetic�import "./lib/other/DSMath.sol";�ENDIF�
			import "./lib/other/ConditionalContract.sol";
			import "./lib/other/DateTime.sol";
			import "./lib/other/IntLib.sol";
			import "./lib/other/RealLib.sol";
			
			contract �contract.name��FOR a : contract.deriveInheritance BEFORE " is " SEPARATOR ", "��a��ENDFOR� {
			
				�contract.compileEnums�
				�contract.compileStructs�
				�contract.compileEvents�
				�"/*\n * State variables\n */\n"�
				�contract.compileAttributes�
				uint _contractStart;
				
				�"/*\n * Constructor\n */\n"�
				�contract.compileConstructor�
				
���				�contract.compileSetupStates�

				�"/*\n * Functions\n */\n"�
				�contract.compileFunctions�
				�contract.compileEventFunctions�
				�contract.compileStaticFunctions�
				// Fallback function
				function() external payable {}
				
				�contract.compileClauseConstraints�
				�contract.compileGetHighestTimestamp�
			}
		�ENDFOR�
	'''

	def compileClauseConstraints(CmlClass contract)'''
	function clauseAllowed(bytes32 _clauseId) internal returns (bool) {
		�FOR clause : contract.clauses�
			if (_clauseId == "�clause.name�") {
				�clause.getConstraints�
				return true;
			}
   		�ENDFOR�		      
		return false;
	}

	'''

	def compileGetHighestTimestamp(CmlClass contract)'''
	function getHighestTimestamp(bytes32 _clauseId) internal returns (uint) {
		�FOR clause : contract.clauses�
			�IF clause.antecedent.temporal !== null && clause.antecedent.temporal.reference instanceof ClauseQuery�
				if (_clauseId == "�(clause.antecedent.temporal.reference as ClauseQuery).clause.name�") {
					uint highestTime = 0;
					�clause.getTimestamps�
					return highestTime;
				}
			�ENDIF�
   		�ENDFOR�		      
		return 0;
	}
	
	'''
	
	def getTimestamps(Clause c)'''
		�var actions = c.gatherActions�
		�FOR a : actions�
			if (highestTime < _callMonitor[this.�a�.selector].time) {
				highestTime =  _callMonitor[this.�a�.selector].time;
			}
		�ENDFOR�
	'''
	
	def gatherActions(Clause c) {
		val tc = c.antecedent.temporal
		if (tc !== null) {
			return (tc.reference as ClauseQuery).clause.action.compoundAction.eAllOfType(AtomicAction).map[operation.name]
		} else return emptyList
	}
	
	def compile(ActionQuery aq)'''
		�aq.party.name�, this.�aq.action.name�.selector'''
		
	def getConstraints(Clause c)'''
		�var constraints = c.deriveConstraints�
		�FOR m : constraints�
			�m�
		�ENDFOR�
	'''
	
	def deriveConstraints(Clause c) {
		var constraints = newArrayList
		var party = c.actor.party
		var tc = c.antecedent.temporal
		var gc = c.antecedent.general
		if (party.name != "anyone")
			constraints.add("require(onlyBy("+party.name+"));")
		if (tc !== null) {
			if (tc.reference instanceof Expression) {
				if (tc.timeframe === null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(" + (tc.reference as Expression).compile +", 0, false"+"));")
				if (tc.closed == false && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(" + (tc.reference as Expression).compile +", "+ tc.timeframe.compile+ ", false"+"));")
				if (tc.closed == true && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(" + (tc.reference as Expression).compile +", "+ tc.timeframe.compile+ ", true"+"));")
			}
			if (tc.reference instanceof ClauseQuery) {
				if ((tc.reference as ClauseQuery).status == "failed" || tc.precedence.literal == "before")
					constraints.add("require(!("+(tc.reference as ClauseQuery).clause.action.compoundAction.compile+"));")
				else
					constraints.add("require("+(tc.reference as ClauseQuery).clause.action.compoundAction.compile+");")	
				
				if (tc.timeframe === null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(getHighestTimestamp(\"" + (tc.reference as ClauseQuery).clause.name + "\"), 0, false"+"));")
				if (tc.closed == false && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(getHighestTimestamp(\"" + (tc.reference as ClauseQuery).clause.name +"\"), " + tc.timeframe.compile+ ", false"+"));")
				if (tc.closed == true && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(getHighestTimestamp(\"" + (tc.reference as ClauseQuery).clause.name +"\"), " + tc.timeframe.compile+ ", true"+"));")
			}
			if (tc.reference instanceof EventQuery) {
				if (tc.precedence.literal == "after")
					constraints.add("require("+(tc.reference as EventQuery).event.name+");")
				if (tc.precedence.literal == "before")
					constraints.add("require(!"+(tc.reference as EventQuery).event.name+");")
				//missed out for now since there is no monitoring of Events
			}
			if (tc.reference instanceof ActionQuery) {
				if (tc.precedence.literal == "after")
					constraints.add("require(actionDone(" + (tc.reference as ActionQuery).compile + ", false));")
				if (tc.precedence.literal == "before")
					constraints.add("require(!actionDone(" + (tc.reference as ActionQuery).compile + ", true));")
				if (tc.timeframe === null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(_callMonitor[this." + (tc.reference as ActionQuery).action.name + ".selector].time, 0, false" + "));")
				if (tc.closed == false && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(_callMonitor[this." + (tc.reference as ActionQuery).action.name + ".selector].time, " + tc.timeframe.compile + ", false" + "));")
				if (tc.closed == true && tc.timeframe !== null)
					constraints.add("require(only" + tc.precedence.literal.toFirstUpper + "(_callMonitor[this." + (tc.reference as ActionQuery).action.name + ".selector].time, " + tc.timeframe.compile + ", true" + "));")
			}	
		}
		if (gc !== null)
			constraints.add("require(when("+gc.expression.compile+"));")
		constraints
	}

	def compileEventFunctions(CmlClass c) '''
		�FOR e : c.attributes.filter[type.mapsToEvent] SEPARATOR "\n" AFTER "\n"�
			�e.compileEventAsFunction�
		�ENDFOR�
	'''
	
	def compileStaticFunctions(CmlClass c) '''
		�FOR o : c.staticOperations SEPARATOR "\n" AFTER "\n"�
			�o.compile(o.deriveAnnotations, newLinkedHashMap)�
		�ENDFOR�
	'''

	def compileFunctions(CmlClass c) '''
		�FOR cl : c.clauses�
			�FOR aa : cl.action.compoundAction.eAllOfType(AtomicAction) SEPARATOR "\n" AFTER "\n"�
				// @notice function for clause �cl.name�
				�aa.operation.compile(aa.operation.deriveAnnotations, cl.deriveModifiers)�
			�ENDFOR�
		�ENDFOR�
	'''

	def String compileEnums(CmlClass c) '''
		�FOR a : c.gatherEnums BEFORE "/*\n * Enums\n */\n" SEPARATOR "" AFTER "\n"�
			�a.compileEnum�
		�ENDFOR�
	'''
	
	def String compileStructs(CmlClass c) '''
		�FOR entry : c.gatherStructs BEFORE "/*\n * Structs\n */\n" SEPARATOR "\n" AFTER "\n"�
			�entry.compile�
		�ENDFOR�
	'''
	
	def Set<CmlClass> gatherEnums(CmlClass c) {
		var set = newLinkedHashSet
		set.addAll(c.referencedNamedElements.map[inferType].filter[mapsToEnum])
		for(entry : c.referencedNamedElements.map[inferType].filter[mapsToStruct])
			set.addAll(entry.traverseForEnums)
		set
	}
	
	def Set<CmlClass> traverseForEnums(CmlClass c) {
		var set = newLinkedHashSet
		for(class : c.attributes.map[type]) {
			if (class.mapsToEnum)
				set.add(class)
			set.addAll(traverseForEnums(class))
		}
		set
	}

	def Set<CmlClass> gatherStructs(CmlClass c) {
		var set = newLinkedHashSet
		set.addAll(c.referencedNamedElements.map[inferType].filter[!conformsToVoid].filter[mapsToStruct])
		for(entry : c.referencedNamedElements.map[inferType].filter[mapsToStruct])
			set.addAll(entry.traverseForStructs)
		set
	}
	
	def Set<CmlClass> traverseForStructs(CmlClass c) {
		var set = newLinkedHashSet
		for(class : c.attributes.filter[type.mapsToStruct].map[type]) {
			set.add(class)
			set.addAll(traverseForStructs(class))
		}
		set
	}
	
	def Set<NamedElement> referencedNamedElements(CmlClass c) {
		var set = new LinkedHashSet<NamedElement>
		set.addAll(c.attributes)
		set.addAll(c.operations)
		set.addAll(c.operations.map[params].flatten)
		for(o : c.operations) {
			set.addAll(o.traverseForTypes)
		}
		set
	}
	
	def Set<NamedElement> traverseForTypes(Operation o) {
		var set = new LinkedHashSet<NamedElement>
		set.addAll(o.referencedSymbols)
		set.addAll(o.variableDeclarations)
		for(op : o.referencedOperations) {
			if (op !== o)
				set.addAll(traverseForTypes(op))
		}
		set
	}
	
	def Set<Operation> staticOperations(CmlClass c) {
		c.referencedNamedElements.filter(Operation).filter[static && !containedInMainLib].toSet
	}
	
	def Set<Attribute> staticAttributes(CmlClass c) {
		c.referencedNamedElements.filter(Attribute).filter[static].toSet
	}
	
	def mapsToStruct(CmlClass c) {
		!c.conformsToLibraryType && !c.conformsToParty && !c.mapsToEnum && !c.mapsToEvent && !c.conformsToSolidityLibraryType
	}
	
	def mapsToEnum(CmlClass c) {
		c.conformsToEnum || c.subclassOfEnum
	}
	
	def mapsToEvent(CmlClass c) {
		c.conformsToEvent || c.subclassOfEvent
	}
	
	def compileAttributes(CmlClass c) '''
		�FOR a : c.staticAttributes�
			�a.compile�;
		�ENDFOR�
		�FOR a : c.attributes.filter[!type.mapsToEnum]�
			�a.compile�;
		�ENDFOR�
	'''

	def compileEvents(CmlClass c) '''
		�FOR e : c.attributes.filter[type.mapsToEvent] BEFORE "/*\n * Events\n */\n" AFTER "\n"�
			event �e.type.name.toFirstUpper�();
		�ENDFOR�
	'''

	def compileConstructor(CmlClass c) {
		val initOperation = c.operations.findFirst[name == "init"]
		if (initOperation !== null)
			initOperation.compileInitConstructor
		else
			c.compileStandardConstructor
	}

	def compileInitConstructor(Operation o) '''	
		constructor(�o.params.compile�) �FOR a : o.deriveAnnotations SEPARATOR ' '��a��ENDFOR� {
			�FOR s : o.body?.statements ?: emptyList�
				�compileStatement(s)�
			�ENDFOR�
			_contractStart = now;
���			setupClauses();
		}
	'''

	def compileStandardConstructor(CmlClass c) '''
		constructor() public {
			_contractStart = now;
���			setupClauses();
		}
    '''

	def compileStates(CmlClass c) '''
		�FOR s : c.clauses.indexed�
			bytes32 constant STATE�s.key� = "�s.value.name�";
		�ENDFOR�
		bytes32[] states = [�FOR s : c.clauses.indexed SEPARATOR ", "�STATE�s.key��ENDFOR�];
		
	'''

//	def compileSetupStates(CmlClass c) '''
//		function setupClauses() internal {
//			�FOR i : c.clauses.indexed�
//				�FOR j : i.value.action.compoundAction.eAllOfType(AtomicAction)�
//					�IF i.value.action.deontic.literal == "may"�
//					// automatically set to true due to may deontic
//					_callMonitor[this.�j.operation.name�.selector].success = true;
//					_callMonitor[this.�j.operation.name�.selector].time = now;
//					�ENDIF�
//				�ENDFOR�
//			�ENDFOR�
//		}
//	'''

	def String compile(CompoundAction ca) {
		switch (ca) {
			XorCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " != " + right
			}
			OrCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " || " + right
			}
			SeqCompoundAction: {
				val left = ca.left.compile
				val right = ca.right.compile
				left + " && " + right
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
				"_callMonitor[this."+ca.operation.name+".selector].success"
		}
	}
	
	def compile(List<Attribute> attributes) '''
		�FOR a : attributes SEPARATOR ', '��a.compile��ENDFOR�'''

	def compile(Attribute a) {
		interceptAttribute(a, null) ?: '''�(a.type as Type).compile��IF a.constant� constant�ENDIF��IF a.type.mapsToStruct && a.containingOperation !== null� memory�ENDIF� �a.name��IF a.expression !== null� = �a.expression.compile��ENDIF�'''
	}

	def compile(CmlClass c) '''
		struct �c.name.toFirstUpper� {
			�FOR a : c.classHierarchyAttributes.values�
				�a.compile�;
	   		�ENDFOR�
		}
	'''

	def compile(Operation o, List<String> annotations, LinkedHashMap<String, List<String>> modifiers) '''	
		function �o.name�(�o.params.compile�) �FOR a : annotations SEPARATOR ' '��a��ENDFOR�
			�FOR m : modifiers.entrySet SEPARATOR ' '�
				�m.key�(�m.value.join(", ")�)
			�ENDFOR�
			�IF o.type !== null�returns (�(o.type as Type).compile��IF o.type.mapsToStruct� memory�ENDIF�)�ENDIF�
		{
			�FOR s : o.body?.statements ?: emptyList�
				�compileStatement(s)�
			�ENDFOR�
		}
	'''
	
	def compileOperationParams(List<Attribute> attributes) '''
		�FOR a : attributes SEPARATOR ', '�
			�IF !a.type.mapsToStruct��ENDIF�
		�ENDFOR�
	'''
	
	def containsDepositOperation(Operation o) {
		o.eAllOfType(Statement).filter(FeatureSelection)?.filter[opCall && feature instanceof Operation]?.map[feature]?.
			findFirst[containingClass.conformsToParty && name == "deposit"] !== null
	}
	
	def modifiesStateAttributes(Operation o) {
		!o.eAllOfType(AssignmentExpression).map[left].filter(SymbolReference).map[symbol].filter(Attribute).filter[!static].empty
	}
	
	def List<String> deriveAnnotations(Operation o) {
		var list = newArrayList
		list.add("public")
		if (o.containsDepositOperation)
			list.add("payable")
		else if (o.static) 
			list.add("pure")
		//else if (!o.modifiesStateAttributes)
		//	list.add("view")
		list
	}

	def deriveModifiers(Clause c) {
		var modifiers = new LinkedHashMap<String, List<String>>()
		var list = newArrayList
		list.add("\""+c.name+"\"")
		modifiers.put("checkAllowed", list)
		modifiers
	}
	
	def compileBlock(Block block) '''
		{	
			�FOR s : block.statements�
				�s.compileStatement�
			�ENDFOR�
		}
	'''
	
	def String compileStatement(Statement s) {
		switch (s) {
			VariableDeclaration: '''�(s.type as Type).compile� �s.name� = �s.expression.compile�;'''
			ReturnStatement:
				"return (" + s.expression.compile + ");"
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
			ThrowStatement: '''revert(�s.expression?.compile�);'''
			default: {
				val statement = (s as Expression).compile
				if (!statement.nullOrEmpty) (statement + ";") else ""
			}
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

	def compileEnum(CmlClass c) '''
		enum �c.name.toFirstUpper� { �FOR e : c.enumElements SEPARATOR ', '��e.name��ENDFOR� } �c.name.toFirstUpper� �c.name.toFirstLower�;
	'''

	def compile(Type t) {
		switch (t) {
			CmlClass:
				switch (t) {
					case t.conformsToInteger: "uint" // "int"
					case t.conformsToBoolean: "bool"
					case t.conformsToString: "bytes32"
					case t.conformsToReal: if (fixedPointArithmetic) "uint" else "ufixed" //"fixed"
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
		var modifiers = new LinkedHashMap<String, List<String>>()
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
				val left = exp.left.compile
				val right = exp.right.compile
				if (safeMath && (!fixedPointArithmetic || (fixedPointArithmetic && fixedPointDecimals != 18 && fixedPointDecimals != 27)))
					switch (exp.op) {
						case '+': '''SafeMath.add(�(left)�, �(right)�)'''
						case '-': '''SafeMath.sub(�(left)�, �(right)�)'''
					}
				else if (safeMath && fixedPointArithmetic)
					switch (exp.op) {
						case '+': '''DSMath.add(�(left)�, �(right)�)'''
						case '-': '''DSMath.sub(�(left)�, �(right)�)'''
					}
				else
					switch (exp.op) {
						case '+': '''�(left)� + �(right)�'''
						case '-': '''�(left)� - �(right)�'''
					}
			}
			MultiplicativeExpression: {
				val left = exp.left.compile
				val right = exp.right.compile
				if (safeMath && (!fixedPointArithmetic || (fixedPointArithmetic && fixedPointDecimals != 18 && fixedPointDecimals != 27)))
					switch (exp.op) {
						case '*': '''SafeMath.mul(�(left)�, �(right)�)'''
						case '/': '''SafeMath.div(�(left)�, �(right)�)'''
						case '%': '''SafeMath.mod(�(left)�, �(right)�)'''
						case '**': '''�(left)� ** �(right)�'''
					}
				else if (safeMath && fixedPointArithmetic && fixedPointDecimals == 18)
					switch (exp.op) {
						case '*': '''DSMath.wmul(�(left)�, �(right)�)'''
						case '/': '''DSMath.wdiv(�(left)�, �(right)�)'''
						case '%': '''SafeMath.mod(�(left)�, �(right)�)'''
						case '**': '''�(left)� ** �(right)�'''
					}
				else if (safeMath && fixedPointArithmetic && fixedPointDecimals == 27)
					switch (exp.op) {
						case '*': '''DSMath.rmul(�(left)�, �(right)�)'''
						case '/': '''DSMath.rdiv(�(left)�, �(right)�)'''
						case '%': '''SafeMath.mod(�(left)�, �(right)�)'''
						case '**': '''DSMath.rpow(�(left)�, �(right)�)'''
					}
				else
					switch (exp.op) {
						case '*': '''�left� * �right�'''
						case '/': '''�(left)� / �(right)�'''
						case '%': '''�(left)� % �(right)�'''
						case '**': '''�(left)� ** �(right)�'''
					}
			}
			UnaryExpression: {
				switch (exp.op) {
					case '+': ''' +�(exp.operand.compile)�'''
					case '-': ''' -�(exp.operand.compile)�'''
					case '!',
					case 'not': ''' !�(exp.operand.compile)�'''
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
			RealLiteral:
				if (fixedPointArithmetic)
					'''�fixedPointRepresentation(exp.value)�'''
				else
					'''�exp.value�'''
			IntegerLiteral:
				if (fixedPointArithmetic)
					'''�fixedPointRepresentation(BigDecimal.valueOf(exp.value))�'''
				else
					'''�exp.value�'''
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

	def fixedPointRepresentation(BigDecimal b) {
		b.scaleByPowerOfTen(fixedPointDecimals).toString().replace("E+", "E")
	}
 	
	def compile(FeatureSelection fs) {
		var String rslt

		if (!fs.opCall && fs.feature instanceof Attribute)
			rslt = interceptAttribute(fs.feature as Attribute, fs)

		if (fs.opCall && fs.feature instanceof Operation)
			rslt = interceptOperation(fs.feature as Operation, fs.args, fs.receiver)

		rslt ?: {
			rslt = fs.receiver.compile + "." + fs.feature.name + if (fs.opCall) {
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

		if (sr.opCall && sr.symbol instanceof CmlClass)
			rslt = interceptClass(sr.symbol as CmlClass, sr.args, sr)

		rslt ?: {
			sr.symbol.name + if (sr.opCall) {
				"(" + sr.args.map[compile].join(", ") + ")"
			} else
				""
		}
	}

	def interceptClass(CmlClass c, List<Expression> args, Expression reference) {
		switch (c) {
			case c.conformsToError: {
				args.get(0).compile
			}
		}
	}

	def interceptAttribute(Attribute a, Expression reference) {
		val containingClass = a.containingClass
		if (containingClass !== null) {
			if (containingClass.conformsToContract) {
				switch (a.name) {
					case "contractStart": "_contractStart"
					case "balance": "address(this).balance"
				}
			} else if (containingClass.conformsToParty && reference === null) {
				switch (a.name) {
					case "id": "address payable " + a.name
				}
			} 
		}
	}

	def interceptOperation(Operation o, List<Expression> args, Expression reference) {
		if (!o.static) {
			val containingClass = o.containingClass
			if (containingClass.conformsToParty) {
				switch (o.name) {
					case "deposit":	"" // NOOP
					case "transfer":
						if (pullPayment) "_asyncTransfer(" + reference.compile + ", " + args.get(0).compile +
							")" else reference.compile + ".transfer" + "(" + args.get(0).compile + ")"
				}
			} else if (containingClass.conformsToInteger) {
				switch (o.name) {
					case "average": "IntLib.average(" + reference.compile + ", " + args.get(0).compile + ")"
					case "max": "IntLib.max(" + reference.compile + ", " + args.get(0).compile + ")"
					case "min": "IntLib.min(" + reference.compile + ", " + args.get(0).compile + ")"
					case "toReal": if (fixedPointArithmetic) "IntLib.toReal(" + reference.compile + ", " + fixedPointDecimals+ ")" else "??? Not yet implemented"
				}
			} else if (containingClass.conformsToReal) {
				switch (o.name) {
					case "max": "RealLib.max(" + reference.compile + ", " + args.get(0).compile + ")"
					case "min": "RealLib.min(" + reference.compile + ", " + args.get(0).compile + ")"
					case "sqrt": "RealLib.sqrt(" + reference.compile + ")"
					case "ceil": if (fixedPointArithmetic) "RealLib.ceil(" + reference.compile + ", " + fixedPointDecimals+ ")" else "??? Not yet implemented"
					case "floor": if (fixedPointArithmetic) "RealLib.floor(" + reference.compile + ", " + fixedPointDecimals+ ")" else "??? Not yet implemented"
					case "toInteger": if (fixedPointArithmetic) "RealLib.toInteger(" + reference.compile + ", " + fixedPointDecimals+ ")" else "??? Not yet implemented"
				}
			} else if (containingClass.conformsToDateTime) {
				switch (o.name) {
					case "isBefore": "DateTime.isBefore(" + reference.compile + ", " + args.get(0).compile + ")"
					case "isAfter": "DateTime.isAfter(" + reference.compile + ", " + args.get(0).compile + ")"
					case "second": "DateTime.getSecond(" + reference.compile + ")"
					case "minute": "DateTime.getMinute(" + reference.compile + ")"
					case "hour": "DateTime.getHour(" + reference.compile + ")"
					case "day": "DateTime.getDay(" + reference.compile + ")"
					case "week": "DateTime.getWeek(" + reference.compile + ")"
					case "equals": "DateTime.equals(" + reference.compile + ", " + args.get(0).compile + ")"
					case "addDuration": "DateTime.addDuration(" + reference.compile + ", " + args.get(0).compile + ")"
					case "subtractDuration": "DateTime.subtractDuration(" + reference.compile + ", " +
						args.get(0).compile + ")"
					case "durationBetween": "DateTime.durationBetween(" + reference.compile + ", " +
						args.get(0).compile + ")"
				}
			} else if (containingClass.conformsToDuration) {
				switch (o.name) {
					case "toSeconds": reference.compile
					case "toMinutes": "DateTime.toMinutes(" + reference.compile + ")"
					case "toHours": "DateTime.toHours(" + reference.compile + ")"
					case "toDays": "DateTime.toDays(" + reference.compile + ")"
					case "toWeeks": "DateTime.toWeeks(" + reference.compile + ")"
					case "addDuration": "DateTime.addDuration(" + reference.compile + ", " + args.get(0).compile + ")"
					case "subtractDuration": "DateTime.subtractDuration(" + reference.compile + ", " +
						args.get(0).compile + ")"
				}
			}
		} else {
			if (o.containedInMainLib) {
				switch (o.name) {
					case "ensure": "require(" + args.get(0).compile + ", " + args.get(1).compile + ")"
				}

			}
		}
	}
}
