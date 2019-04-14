/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.generator

import at.ac.univie.swa.CmlLib
import at.ac.univie.swa.CmlModelUtil
import at.ac.univie.swa.cml.AdditiveExpression
import at.ac.univie.swa.cml.AndExpression
import at.ac.univie.swa.cml.Antecedent
import at.ac.univie.swa.cml.AssignmentExpression
import at.ac.univie.swa.cml.Block
import at.ac.univie.swa.cml.BooleanLiteral
import at.ac.univie.swa.cml.CallerExpression
import at.ac.univie.swa.cml.Class
import at.ac.univie.swa.cml.CmlProgram
import at.ac.univie.swa.cml.Container
import at.ac.univie.swa.cml.DateTimeLiteral
import at.ac.univie.swa.cml.DurationLiteral
import at.ac.univie.swa.cml.ElementReferenceExpression
import at.ac.univie.swa.cml.EqualityExpression
import at.ac.univie.swa.cml.Expression
import at.ac.univie.swa.cml.If
import at.ac.univie.swa.cml.Import
import at.ac.univie.swa.cml.IntegerLiteral
import at.ac.univie.swa.cml.MemberFeatureCall
import at.ac.univie.swa.cml.MultiplicativeExpression
import at.ac.univie.swa.cml.Operation
import at.ac.univie.swa.cml.OrExpression
import at.ac.univie.swa.cml.PostfixExpression
import at.ac.univie.swa.cml.RelationalExpression
import at.ac.univie.swa.cml.Return
import at.ac.univie.swa.cml.Statement
import at.ac.univie.swa.cml.StringLiteral
import at.ac.univie.swa.cml.Symbol
import at.ac.univie.swa.cml.SymbolReference
import at.ac.univie.swa.cml.TimeConstraint
import at.ac.univie.swa.cml.UnaryExpression
import at.ac.univie.swa.cml.VariableDeclaration
import at.ac.univie.swa.typing.CmlTypeConformance
import at.ac.univie.swa.typing.CmlTypeProvider
import com.google.inject.Inject
import java.util.LinkedHashMap
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CmlGenerator extends AbstractGenerator2 {
	
	@Inject extension CmlModelUtil
	@Inject extension CmlLib
	@Inject extension CmlTypeProvider
	@Inject extension CmlTypeConformance
	
	override doGenerate(Resource resource, ResourceSet input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val allResources = input.resources.map(r|r.allContents.toIterable.filter(CmlProgram)).flatten
		for (p : resource.allContents.toIterable.filter(CmlProgram)) {
			if(!p.contracts.empty)	
            	fsa.generateFile(resource.URI.trimFileExtension.toPlatformString(true) + ".sol", p.compile(allResources))         
        }
	}
 
 	def retrieveImport(Iterable<CmlProgram> resources, Import i) {
 		if(i.importedNamespace !== CmlLib::LIB_PACKAGE)
 			resources.findFirst[name == i.copy.importedNamespace.replace(".*","")]
 	}
 	
    def compile(CmlProgram program, Iterable<CmlProgram> allResources) '''
	pragma solidity >=0.4.22 <0.7.0;
	
	�FOR contract : program.contracts�
	contract �contract.name� {
		
		/*
		 *  Enums
		 */
		�FOR i : program.imports�
			�FOR e : allResources.retrieveImport(i).enums�
				�e.compileEnum�
			�ENDFOR�
		�ENDFOR�
		�FOR c : program.enums�
			�c.compileEnum�
		�ENDFOR�
		
		/*
		 *  Structs
		 */
		�FOR i : program.imports�
			�allResources.retrieveImport(i).compileModel�
		�ENDFOR�
		�FOR i : program.imports�
			�program.compileModel�
		�ENDFOR�	
		/*
		 *  State variables
		 */	
		address owner;
		uint creationTime;
		�FOR a : contract.attributes�
		   	�a.compile�;
		�ENDFOR�
		
		/*
	 	 *  Events
	 	 */
		�FOR i : program.imports�
			�FOR e : allResources.retrieveImport(i).events�
				�e.compileEvent�
			�ENDFOR�
		�ENDFOR�
		�FOR e : program.events�
			�e.compileEvent�
		�ENDFOR�
		
		/*
		 *  Constructor
		 */
		constructor(�FOR party : program.parties SEPARATOR ', '�address _�program.name��ENDFOR�) public {
			owner = msg.sender;
			�FOR party : program.parties�
				�program.name�= _�program.name�;
			�ENDFOR�
			creationTime = now;
		}
		
		/*
		 *  Functions
		 */
	 	�FOR clause : contract.clauses�
	 		�clause.action.compoundAction.compile�
		�ENDFOR�
		�FOR i : program.imports�
			�FOR e : allResources.retrieveImport(i).events�
				�e.compileEventAsFunction�
			�ENDFOR�
		�ENDFOR�
		�FOR e : program.events�
			�e.compileEventAsFunction�
		�ENDFOR�
		function changeOwner(address _newOwner) public onlyBy(owner) {
			owner = _newOwner;
		}
		
		// Fallback function
		function() external payable {}
		
		/* 	 
		 *  Modifiers
	 	 */
		�FOR clause : contract.clauses�
���			�clause.antecedent.compile�
		�ENDFOR�
		modifier onlyBy(address _account) { 
			require(msg.sender == _account, "Sender not authorized."); _;
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
	}
	�ENDFOR�
    '''
          	
    def compile(List<Symbol> symbols) '''
    	�FOR s : symbols SEPARATOR ', '��s.compile��ENDFOR�'''
    
    def compile(Symbol s) '''
    	�s.type.compile� � s.name�'''
    
    def compileModel(CmlProgram program) '''
	�FOR c : program.classes�
		�IF !c.isAbstract && (c.subclassOfParty || c.subclassOfAsset)��c.compile��ENDIF�
	�ENDFOR�
	'''
	
    def compile(Class c) '''
	struct �c.name.toFirstUpper� {
	   	�FOR f : c.classHierarchyAttributes.values�
	   		�f.compile�;
	   	�ENDFOR�
	   	�FOR f : c.attributes�
	   		�f.compile�;
	   	�ENDFOR�
	}
	
   ''' 
    
    def compile(Operation o) '''	
	function �o.name�(�o.params.map[it as Symbol].compile�) public �FOR m : o.deriveModifiers.entrySet SEPARATOR ' '��m.key�(�m.value.join(", ")�)�ENDFOR� {
���		// TODO: Implement code to �o.name� �FOR arg : o.params SEPARATOR ', '��arg.name��ENDFOR�
		�IF o.precondition !== null�require(�o.precondition.compile�);�ENDIF�
		�FOR s : o.body.statements�
		�compileStatement(s)�
		�ENDFOR�
	}
	
	'''
	
	def deriveModifiers(Operation o) {
		var modifiers = new LinkedHashMap<String, List<String>>(); 
		var party = o.containingClause.actor.party
		var tc = o.containingClause.antecedent.temporal
		if(party != "anyone")
			modifiers.put("onlyBy", #[party.name])
		if(tc !== null) {
			if(tc.reference instanceof Expression) {
				if(tc.timeframe === null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper, #[(tc.reference as Expression).compile, "0", "false"])
				if(tc.closed == false && tc.timeframe !== null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper, #[(tc.reference as Expression).compile, tc.timeframe.compile, "false"])
				if(tc.closed == true && tc.timeframe !== null)
					modifiers.put("only" + tc.precedence.literal.toFirstUpper, #[(tc.reference as Expression).compile, tc.timeframe.compile, "true"])
			}
		}
		modifiers
	}
	
	def compileBlock(Block block) '''
	{
		�FOR s : block.statements�
		�compileStatement(s)�
		�ENDFOR�
	}
	'''
	
	def String compileStatement(Statement s) {
		switch (s) {
			VariableDeclaration: ''' �s.name� = �s.expression.compile�;'''
			Return: "return " + s.expression.compile + ";"
			If: '''
			if (�s.condition.compile�)
				�s.thenBlock.compileBlock�
			�IF s.elseBlock !== null�
			else
				�s.elseBlock.compileBlock�
			�ENDIF�
			'''
			default: (s as Expression).compile + ";"
		}
	}

	def compileEvent(Class c) '''
	event �c.name.toFirstUpper�();'''
	
	def compileEventAsFunction(Class c) '''	
	// @notice trigger event �c.name�
	function �c.name.toFirstLower�() public {
		emit �c.name.toFirstUpper�();
	}
	
	'''
	
	def compileEnum(Class c) '''
	enum �c.name.toFirstUpper� { �FOR e : c.enumElements SEPARATOR ', '��e.name��ENDFOR� }
	�c.name.toFirstUpper� �c.name.toFirstLower�;'''
	
    def compile(Container c) {
    	var t = c.inferType
    	switch (t) {
			case t.conformsToInteger: "uint"
			case t.conformsToBoolean: "bool"
			case t.conformsToString: "bytes32"
			case t.conformsToReal: "uint"
			case t.conformsToDateTime: "uint"
			case t.conformsToDuration: "uint"
			case t.conformsToEnum: t.name
			case t.conformsToSet: "???"
			case t.conformsToMap: "mapping( ? => ? )"
			case t.conformsToAsset: t.name
			case t.conformsToParty: "address"
			default: t.name
		}
	}
	
	def compile(Antecedent a) '''
	// @notice modifier for clause �a.containingClause.name�
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
		if(tc.closed == false && tc.timeframe === null) {
			if(tc.precedence == "after" && tc.reference instanceof Expression)
				modifiers.put("onlyAfter", #[(tc.reference as Expression).compile, "0"])
			if(tc.precedence == "before" && tc.reference instanceof Expression)
				modifiers.put("onlyBefore", #[(tc.reference as Expression).compile, "0"])
		}
	}
	
	def String compile(Expression exp) {
		
		switch (exp) {
			AssignmentExpression: 
				'''�(exp.left.compile)� = �(exp.right.compile)�'''
			OrExpression: {
				'''�(exp.left.compile)� || �(exp.right.compile)�'''
			}
			AndExpression: {
				'''�(exp.left.compile)� && �(exp.right.compile)�'''
			}
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
				if (exp.op == '+')
					''' +�(exp.operand.compile)�'''
				else
					''' -�(exp.operand.compile)�'''
			}
			PostfixExpression: {
				if (exp.op == '++')
					'''�(exp.operand.compile)�++'''
				else
					'''�(exp.operand.compile)�--'''
			}
			IntegerLiteral: '''�exp.value�'''
			BooleanLiteral: '''�exp.value�'''
			StringLiteral: '''"�exp.value�"'''
			SymbolReference: '''�exp.ref.name�'''
			DateTimeLiteral: '''�exp.value�'''
			DurationLiteral: '''�exp.value� �exp.unit�'''
			MemberFeatureCall: exp.featureCallTransformation
			ElementReferenceExpression: '''�exp.reference.compile�'''
			CallerExpression: '''msg.sender'''
		}
	}
	
	def featureCallTransformation(MemberFeatureCall mfc) {
		val t = mfc.member.inferType
		switch (t) {	
			case t.conformsToDateTime: {
				if (mfc.operationCall)
					switch(mfc.member.name) {
						case "addDuration" : mfc.receiver.compile + " + " + mfc.args.get(0).compile
				} else mfc.receiver.compile + "." + mfc.member.name
			}
			default:
				mfc.receiver.compile + "." + mfc.member.name +
				if (mfc.operationCall) {
					"(" + mfc.args.map[compile].join(", ") + ")"
				} else ""
		}
	}

}

