module sqat::series2::A1a_StatCov
//import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Java17ish;
import Message;
import lang::java::jdt::m3::AST;
import IO;
import ParseTree;
import Type;
import List;
import String;
import Set;
import Map;
import util::FileSystem;
import Type;

/*

Implement static code coverage metrics by Alves & Visser 
(https://www.sig.eu/en/about-sig/publications/static-estimation-test-coverage)


The relevant base data types provided by M3 can be found here:

- module analysis::m3::Core:

rel[loc name, loc src]        M3.declarations;            // maps declarations to where they are declared. contains any kind of data or type or code declaration (classes, fields, methods, variables, etc. etc.)
rel[loc name, TypeSymbol typ] M3.types;                   // assigns types to declared source code artifacts
rel[loc src, loc name]        M3.uses;                    // maps source locations of usages to the respective declarations
rel[loc from, loc to]         M3.containment;             // what is logically contained in what else (not necessarily physically, but usually also)
list[Message]                 M3.messages;                // error messages and warnings produced while constructing a single m3 model
rel[str simpleName, loc qualifiedName]  M3.names;         // convenience mapping from logical names to end-user readable (GUI) names, and vice versa
rel[loc definition, loc comments]       M3.documentation; // comments and javadoc attached to declared things
rel[loc definition, Modifier modifier] M3.modifiers;     // modifiers associated with declared things

- module  lang::java::m3::Core:

rel[loc from, loc to] M3.extends;            // classes extending classes and interfaces extending interfaces
rel[loc from, loc to] M3.implements;         // classes implementing interfaces
rel[loc from, loc to] M3.methodInvocation;   // methods calling each other (including constructors)
rel[loc from, loc to] M3.fieldAccess;        // code using data (like fields)
rel[loc from, loc to] M3.typeDependency;     // using a type literal in some code (types of variables, annotations)
rel[loc from, loc to] M3.methodOverrides;    // which method override which other methods
rel[loc declaration, loc annotation] M3.annotations;

Tips
- encode (labeled) graphs as ternary relations: rel[Node,Label,Node]
- define a data type for node types and edge types (labels) 
- use the solve statement to implement your own (custom) transitive closure for reachability.

Questions:
- what methods are not covered at all?
	Many of these uncovered methods are from UI,level and board classes
	
- how do your results compare to the jpacman results in the paper? Has jpacman improved?
	In that paper: Static 88.06%/ Clover 93.53%/ Difference −5.47%
	My coverage result was : 80.51282051 / Clover 76.6 / Difference about +4.1
	
	Seems like it hasnt. At least Coverage is smaller nowadays.

- use a third-party coverage tool (e.g. Clover) to compare your results to (explain differences)
	My coverage result was : 80.51282051 and Clover gave: 76.6 
	
	This static version works on source code
	
	Clover takes Statements and Methods and measures coverage while the whole program has been executed. 


*/



M3 jpacmanM3() = createM3FromEclipseProject(|project://jpacman-framework/|);

alias Node = loc;
alias Graph =rel[Node, Node];




void main() {
	M3 m3 = jpacmanM3();
	Graph graph;
	Graph closure;
	
	allTests = getMethods(m3);
	//println(allTests);
	graph = buildGraph(m3);
	closure = transitiveClosure(graph);
	coverage = getCoverage(closure,allTests);

	results(coverage);

}

bool isJpacman(loc l) = contains(l.path, "/jpacman/"); 

void results(tuple[set[loc],set[loc]] coverage){
	println("Not covered :");
	for(meth <- coverage[1] - coverage[0]) {
		println(meth);
	}
	
	println("Static coverage is: <size(coverage[0]) * 100.0 / size(coverage[1])>");
	println(<size(coverage[0]), size(coverage[1])>);
}

tuple[set[loc],set[loc]] getCoverage(Graph closure, map[loc, loc] allTests) {
	set[loc] coveredMeths = {};
	set[loc] allMeths = {};
	for(<from,to> <- closure) {
		if(isTest(from, allTests) && !isTest(to, allTests)) {
			//gettin covered methods
			if(to notin coveredMeths) {
				coveredMeths += to;
			}
		}
		//getting all methods, also whichs are not covered
		if(to notin allMeths && !isTest(to, allTests)) {
			allMeths += to;
		}
	}
	return <coveredMeths, allMeths>;
}

Graph transitiveClosure(Graph graph) {
	return solve(graph){
		graph = graph + (graph o graph);
	};
}

bool isTest(loc l, map[loc, loc] allTests) = l in allTests ? true : false;

Graph buildGraph(M3 m3){
	Graph graph = {};
	m3Invocation = m3.methodInvocation;
	graph = { <from , to> | <from,to> <- m3Invocation , contains(to.path, "/jpacman/")};
	return graph;
}

map [loc,loc] getMethods(M3 m3) {
	map[loc,loc] allTests = ();
	m3Decl = m3.declarations;
	allTests =  ( decl.name : decl.src | decl <- m3Decl, isMethod(decl.name), 
										 contains(decl.name.path, "/jpacman/"), 
										 contains(decl.src.path,"/test/"));

	return allTests;
}

