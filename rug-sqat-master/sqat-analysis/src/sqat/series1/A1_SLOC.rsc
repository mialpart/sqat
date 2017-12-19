module sqat::series1::A1_SLOC

import IO;
import ParseTree;
import String;
import util::FileSystem;
//import sqat::series1::Comments;

/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman?
	Level.java, there is 179 lines of code
	
- what is the total size of JPacman?
	Total size is 2458
	
- is JPacman large according to SIG maintainability?
	It is small (+). There is only 2458 lines of code.
	
- what is the ratio between actual code and test code size?

Sanity checks:
- write tests to ensure you are correctly skipping multi-line comments
- and to ensure that consecutive newlines are counted as one.
- compare you results to external tools sloc and/or cloc.pl

Bonus:
- write a hierarchical tree map visualization using vis::Figure and 
  vis::Render quickly see where the large files are. 
  (https://en.wikipedia.org/wiki/Treemapping) 

*/

/*
RegEx things:
http://tutor.rascal-mpl.org/Rascal/Statements/Switch/Switch.html#/Rascal/Patterns/Regular/Regular.html
*/

//checking if there is comments
int isComment(str s) {
  	if(/^\s*$/ := s){
  		return 0;
  	}else if(/(^|\s*)\/\/.*/ := s){
  		return 0;
  	}else if(/\/\*.*/ := s){
  		return 2;
}
	//  	println(s);
  	return 1;
}

// checking if there is multicomments
int isMultiComment(str s){
	if(/.*\*\/$/ := s){
		return 3;
	}
	return 0;
}


alias SLOC = map[loc file, int sloc];





SLOC sloc(loc project) {
  SLOC result = ();
  //loc jpacman = |project://jpacman-framework|;
  // implement here
	
  set[loc] projFiles = files(project);
  list[str] lines;
  real testloc = 0.0;
  int max = 0; 
  loc maxfile ;
  
  
  for(loc file <- projFiles){
  	if (file.extension == "java"){
  		lines = readFileLines(file);
  		//println(lines);
  		int totalsloc = 0;
  		int ans = 0;
  		bool multComments = false;
  		for(str line <- lines){
  			if(!multComments){
	  			ans = isComment(line);
			}
			else{
  				ans = isMultiComment(line);
			}
			
  			
  			if(ans := 1){
  			  totalsloc += 1;
  			}else if(ans := 2){
  				multComments = true;
			}else if(ans := 3){
  				multComments = false;
			}
  			
  		}
  		print(file.file + ": ");
  		println(totalsloc);
  		max += totalsloc; 
  	}
  }
  	print("Total project size: "); 
	println(max);
  return result;
}             
             