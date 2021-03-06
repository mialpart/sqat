module sqat::series1::A2_McCabe

import lang::java::jdt::m3::AST;
import IO;

/*

Construct a distribution of method cylcomatic complexity. 
(that is: a map[int, int] where the key is the McCabe complexity, and the value the frequency it occurs)


Questions:
- which method has the highest complexity (use the @src annotation to get a method's location)
	project://jpacman-framework/src/main/java/nl/tudelft/jpacman/npc/ghost/Inky.java|(2255,2267,<68,1>,<131,17>)

- how does pacman fare w.r.t. the SIG maintainability McCabe thresholds?
	Biggest complexity was 8. I think it might be a good thing.

- is code size correlated with McCabe in this case (use functions in analysis::statistics::Correlation to find out)? 
  (Background: Davy Landman, Alexander Serebrenik, Eric Bouwers and Jurgen J. Vinju. Empirical analysis 
  of the relationship between CC and SLOC in a large corpus of Java methods 
  and C functions Journal of Software: Evolution and Process. 2016. 
  http://homepages.cwi.nl/~jurgenv/papers/JSEP-2015.pdf)
  
- what if you separate out the test sources?

Tips: 
- the AST data type can be found in module lang::java::m3::AST
- use visit to quickly find methods in Declaration ASTs
- compute McCabe by matching on AST nodes

Sanity checks
- write tests to check your implementation of McCabe

Bonus
- write visualization using vis::Figure and vis::Render to render a histogram.

*/

set[Declaration] jpacmanASTs() = createAstsFromEclipseProject(|project://jpacman-framework|, true); 

alias CC = rel[loc method, int cc];

CC cc(set[Declaration] decls) {
  CC result = {};
  
  visit (decls) {
  	case m:\method(_, _, _, _, Statement impl):{
  		result[m.src] = calculateCC(impl);
  	}
  }
  return result;
}

//From the article
int calculateCC(Statement impl){
	int result = 1;
	visit (impl) {
		case \if(_,_) : result +=1;
		case \if(_,_,_) : result +=1;
		case \case(_) : result +=1;
		case \do(_,_) : result +=1;
		case \while(_,_) : result +=1;
		case \for(_,_,_,_) : result +=1;
		case \for(_,_,_) : result +=1;
		case \foreach(_,_,_) : result +=1;
		case \catch(_,_) : result +=1;
		case \infix(_,"&&",_) : result +=1;
		case \infix(_,"||",_) : result +=1;
	}
	return result;
}


void ccResults() {
	int complexAll = 0;
	int methodComplex = 0;
	loc file;
	
	for(<loc l, int n> <- cc(jpacmanASTs())) {
		if(n > methodComplex) {
			methodComplex = n;
			file = l;
		}
		complexAll+=n;
	}
	println("Overall cc: ");
	println(complexAll);
	println("Method (biggest cc) and its complexity: ");
	println(file);
	println(methodComplex);
	
}

alias CCDist = map[int cc, int freq];

CCDist ccDist(CC cc) {
  // to be done
}



