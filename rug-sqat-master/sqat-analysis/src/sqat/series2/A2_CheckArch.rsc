module sqat::series2::A2_CheckArch


import sqat::series2::Dicto;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import Message;
import ParseTree;
import IO;
import String;
import Set;

import analysis::m3::Core;
import Plugin;
import util::FileSystem;
import Java17ish;
import Boolean;



/*

This assignment has two parts:
- write a dicto file (see example.dicto for an example)
  containing 3 or more architectural rules for Pacman
  
- write an evaluator for the Dicto language that checks for
  violations of these rules. 

Part 1  

An example is: ensure that the game logic component does not 
depend on the GUI subsystem. Another example could relate to
the proper use of factories.   

Make sure that at least one of them is violated (perhaps by
first introducing the violation).

Explain why your rule encodes "good" design.
  
Part 2:  
 
Complete the body of this function to check a Dicto rule
against the information on the M3 model (which will come
from the pacman project). 

A simple way to get started is to pattern match on variants
of the rules, like so:

switch (rule) {
  case (Rule)`<Entity e1> cannot depend <Entity e2>`: ...
  case (Rule)`<Entity e1> must invoke <Entity e2>`: ...
  ....
}

Implement each specific check for each case in a separate function.
If there's a violation, produce an error in the `msgs` set.  
Later on you can factor out commonality between rules if needed.

The messages you produce will be automatically marked in the Java
file editors of Eclipse (see Plugin.rsc for how it works).

Tip:
- for info on M3 see series2/A1a_StatCov.rsc.

Questions
- how would you test your evaluator of Dicto rules? (sketch a design)
- come up with 3 rule types that are not currently supported by this version
  of Dicto (and explain why you'd need them). 
  	1. There are no implement rule. It could be nice to check if some class implements some interface.
  	
  	2. Only <class> can <thing to do> on <class>. 
  		This could be useful to check if just one class has some action to do.
  		Then we dont need to check if every other class does not do that action.
*/

//helpers
rel[loc from, loc to] dependLocs(Entity e1, Entity e2, M3 m3) = {m | m <- m3.typeDependency, isClass(m.from) && contains("<m.from>", replaceAll("<e1>", ".", "/")) && contains("<m.to>", replaceAll("<e2>", ".", "/"))};
rel[loc from, loc to] importLocs(Entity e1, Entity e2, M3 m3) = {m | m <- m3.containment, contains("<m.from>", replaceAll("<e1>", ".", "/")) && contains("<m.to>", replaceAll("<e2>", ".", "/"))};
rel[loc from, loc to] extendsLocs(Entity e1, Entity e2, M3 m3) = {m | m <- m3.extends, contains("<m.from>", replaceAll("<e1>", ".", "/")) && contains("<m.to>", replaceAll("<e2>", ".", "/"))};

//checks if there is implements
Message doesDepend(Entity e1,Entity e2,M3 m3){
	location_e1 = |java+class:///| + replaceAll("<e1>", ".", "/");
	deps = m3.typeDependency;
	if(!isEmpty(dependLocs(e1,e2,m3)) && contains("<deps.from>", replaceAll("<e1>",".","/"))){		
				return info("<e1> really depends on <e2>", location_e1);
		}
	return error("<e1> does not depend on <e2>", location_e1); 
}

//checks that there is no implements
Message cantDepend(Entity e1, Entity e2, M3 m3){
	location_e1 = |java+class:///| + replaceAll("<e1>", ".", "/");
	
	if(!isEmpty(dependLocs(e1,e2,m3))){		
				return info("<e1> really depends on <e2>", location_e1);
	}
	return error("<e1> cannot depend on <e2>", location_e1); 

}

//checks that there is imports
Message mustImport(Entity e1, Entity e2, M3 m3){
	location_e1 = |java+package:///| + replaceAll("<e1>",".","/");
	
	if(!isEmpty(importLocs(e1,e2,m3))){
			return info("<e1> does really import <e2>", location_e1);
	}
	else return error("<e1> does not import <e2>", location_e1);	
}

//checks if there is any extends
Message mustInherit(Entity e1, Entity e2, M3 m3){
 	
	location_e1 = |java+class:///| + replaceAll("<e1>", ".", "/");
	
	if (!isEmpty(extendsLocs(e1,e2,m3))){
		return info("<e1> does really inherit <e2>", location_e1);
	}
 	return error("<e1> does not inherit <e2>",location_e1);

}


M3 m3jpac() = createM3FromEclipseProject(|project://jpacman-framework/src|); 


set[Message] eval(start[Dicto] dicto, M3 m3) = eval(dicto.top, m3);

set[Message] eval((Dicto)`<Rule* rules>`, M3 m3) 
  	= ( {} | it + eval(r, m3) | r <- rules );
  
set[Message] main() 
 	= eval(parse(#start[Dicto], |project://sqat-analysis/src/sqat/series2/example.dicto|), m3jpac());
  
  
set[Message] eval(Rule rule, M3 m3) {
  set[Message] msgs = {};
  
  switch (rule) {
  	case (Rule) `<Entity e1> must depend <Entity e2>` : msgs += doesDepend(e1,e2,m3);
  	case (Rule) `<Entity e1> cannot depend <Entity e2>` : msgs += cantDepend(e1,e2,m3);
  	case (Rule) `<Entity e1> must import <Entity e2>` : msgs += mustImport(e1,e2,m3);
  	case (Rule) `<Entity e1> must inherit <Entity e2>` : msgs += mustInherit(e1,e2,m3);
  }
  
  return msgs;
}