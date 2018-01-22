module sqat::series1::A3_CheckStyle

//import Java17ish;
import lang::java::\syntax::Java15;
import Message;
import String;
import util::FileSystem;
import IO;
import List;
import util::ResourceMarkers;

/*

Assignment: detect style violations in Java source code.
Select 3 checks out of this list:  http://checkstyle.sourceforge.net/checks.html
Compute a set[Message] (see module Message) containing 
check-style-warnings + location of  the offending source fragment. 

Plus: invent your own style violation or code smell and write a checker.

Note: since concrete matching in Rascal is "modulo Layout", you cannot
do checks of layout or comments (or, at least, this will be very hard).

JPacman has a list of enabled checks in checkstyle.xml.
If you're checking for those, introduce them first to see your implementation
finds them.

Questions
- for each violation: look at the code and describe what is going on? 
  Is it a "valid" violation, or a false positive?
  
  Ans: 	It really recognized codesmells. I checked these files and found 
  	 	that there really was whitespaces and TODO-comments.

Tips 

- use the grammar in lang::java::\syntax::Java15 to parse source files
  (using parse(#start[CompilationUnit], aLoc), in ParseTree)
  now you can use concrete syntax matching (as in Series 0)

- alternatively: some checks can be based on the M3 ASTs.

- use the functionality defined in util::ResourceMarkers to decorate Java 
  source editors with line decorations to indicate the smell/style violation
  (e.g., addMessageMarkers(set[Message]))

  
Bonus:
- write simple "refactorings" to fix one or more classes of violations 

*/

/* Checks if there is whitespace lines in file */
set[Message] whiteSpaces(loc projFile){
	if(projFile.extension == "java"){
		
	int lineN = 0;
	set[Message] infoMes = {};
	list[str] code = readFileLines(projFile);
	bool trueFalse = false;
	
	for (str s <- code){
		lineN += 1;
		/* Checks if there is whitespace */
		if(/^\s*$/ := s) {
			if(trueFalse){
				infoMes += info("Whitespaceline: ", projFile + "--:line=<lineN>");
			}
			trueFalse =true;
		}else{
			trueFalse = false;
		}
	}
	return infoMes;
 	}
 	return {};
}

/* Checks if  file is too long */
set[Message] fileLength(loc projFile) {

	list[str] lines = readFileLines(projFile);
	set[Message] infos = {};
	int max = 250;
	
	if (size(lines) > max) {
		infos += info("File longer than <max> lines",projFile);
	}
	return infos;
}


/* Checks if there is TODO- comments in file */
set[Message] toDoComm(loc projectFile){
	if(projectFile.extension == "java"){
	
	int lineN = 0;
	list[str] codeCommsLines = readFileLines(projectFile);
	set[Message] infoToDo = {};
	bool tf = false;
	
	for(str s <- codeCommsLines){
		lineN +=1;
		/* Checks TODO comments*/
		if(/^\s*\/\/\s*TODO.*$/ := s){
			if(tf){
				infoToDo += info("TODO-comment: ", projectFile + "--:line=<lineN>");
			}
			tf = true;
		}else{
			tf = false;
		}
		
	}
	
	return infoToDo;
	}
	return {};
}

/*checks styles*/
set[Message] checkStyle(loc project) {
  set[Message] result = {};
  set[loc] projFiles = files(project);
  
  for(loc file <- projFiles){
  	result += whiteSpaces(file);
  	result += toDoComm(file);
  	result += fileLength(file);
  }

  
  return result;
}
