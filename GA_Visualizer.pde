// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Genetic Algorithm, Evolving Shakespeare

// Demonstration of using a genetic algorithm to perform a search

// setup()
//  # Step 1: The populationation 
//    # Create an empty populationation (an array or ArrayList)
//    # Fill it with DNA encoded objects (pick random values to start)

// draw()
//  # Step 1: Selection 
//    # Create an empty mating pool (an empty ArrayList)
//    # For every member of the populationation, evaluate its fitness based on some criteria / function, 
//      and add it to the mating pool in a manner consistant with its fitness, i.e. the more fit it 
//      is the more times it appears in the mating pool, in order to be more likely picked for reproduction.

//  # Step 2: Reproduction Create a new empty populationation
//    # Fill the new populationation by executing the following steps:
//       1. Pick two "parent" objects from the mating pool.
//       2. Crossover -- create a "child" object by mating these two parents.
//       3. Mutation -- mutate the child's DNA based on a given probability.
//       4. Add the child object to the new populationation.
//    # Replace the old populationation with the new populationation
//  
//   # Rinse and repeat


PFont f;
String target;
int popmax;
float mutationRate;
Population population;

void setup() {
  size(1000, 600);
  f = createFont("Courier", 32, true);
  target = "To be or not to be.";
  popmax = 45 * 5;
  mutationRate = 0.01;
  // Create a populationation with a target phrase, mutation rate, and populationation max
  population = new Population(target, mutationRate, popmax);
  BuildHistogram();
  frameRate(20);
}
boolean run = true;
void draw() {
  
  if(!run)
    return;
  // Generate mating pool
  population.naturalSelection();
  //Create next generation
  population.generate();
  // Calculate fitness
  population.calcFitness();
  
  displayInfo();
  // If we found the target phrase, stop
  if (population.finished()) {
    println(millis()/1000.0);
    //run = false;
    //noLoop();
  }
}

void displayInfo() {
  
  background(0);
  // Display current status of populationation
  String answer = population.getBest();
  textFont(f);
  textAlign(LEFT);
  fill(0, 204, 0);
  
  textSize(16);
  text("Best phrase:",20,30);
  textSize(32);
  text(answer, 20, 45, 300, 500);

  textSize(12);
  int infoYstart = 220;
  text("total generations: " + population.getGenerations(), 20, infoYstart + 185);
  text("average fitness: " + nf(population.getAverageFitness(), 0, 2), 20, infoYstart + 200);
  text("total populationation: " + popmax, 20, infoYstart + 215);
  text("mutation rate: " + int(mutationRate * 100) + "%", 20, infoYstart + 230);
 
  textSize(9);
  int startx = 350;
  fill(0, 204, 0);
  text("All phrases:\n", startx, 10);
  if(target.length() > 0){
    textSize(max(20/target.length(), 7.0));
    for(int i = 0 ; i < target.length() - target.length() / 5.0 ; i++){
      text("\n" + population.allPhrases(i,45), startx + 5 * i * target.length(), 10);
    }
  }
  
  textSize(12);
  text( "Running"+ (frameCount % 5 != 0 ? "." : "") +(frameCount % 15 != 0 ? "." : "")  , startx, height-110);
  //allPhrases(int columnNum, int columnsToDisplay) 
  
  textSize(14);
  text( target + (frameCount/10 % 5 != 0 ? "_" : ""), 20, height-100, 300, 500);

   DrawPlot();
   DrawHistogram();
}

ArrayList<Float> bests = new ArrayList<Float>();

int incr = 0;

void DrawPlot(){
  ++incr;
  float max = population.GetMax();
  
  //fill(0,204, 0);
  strokeWeight(1.5);
  //strokeWeight(1);
  int offset = 350;
  int sizeLimit = 60;
 for (int i = 0; i < bests.size(); i++) {
    stroke(0, 204, 0);
    rect(offset + 10 * i, height - 10, 5,  - (100 * bests.get(i)));
    if(i < bests.size() -1 && bests.size() > 2){
      stroke(204, 0,0);
      line(offset + 10 * i, height - (110 * bests.get(i)),  offset + 10 * (i+1), height - (110 * bests.get(i+1)));  
    }
  }
  
  boolean wrap = false;
  
  if(wrap){
    if(bests.size() >sizeLimit)
      bests.set(incr%sizeLimit, population.getAverageFitness()/max);
    else
      bests.add(population.getAverageFitness()/max);
   }else{ //shift
     if(bests.size() >sizeLimit){
       for(int i = 1; i < bests.size(); i++)
        bests.set(i-1,bests.get(i));
       bests.set(bests.size()-1, population.getAverageFitness()/max);
     }
    else
      bests.add(population.getAverageFitness()/max);
     
   }
  
  if(incr > sizeLimit * 2)
    incr = 0;
  stroke(0, 204, 0);
  rect(offset, height - 101, 10 * (sizeLimit), 1);
}

int[] entries;

void DrawHistogram(){
  float max = population.GetMax();
  int index = 0;
  int offset = 20;
  ClearHistogram();
  stroke(0, 204, 0, 0);
  for(int i = 0 ;i < popmax; i++){
    index = (int)( (population.GetFitness(i)/max) * 99 ) ;
    entries[index]++;
    //rect(offset + 1*i, height - 5, 1,  - (entries[index]/3.0));
  } 
   for(int i = 0 ;i < 100; i++){
    rect(offset + 2*i, height - 5, 2,  - (entries[i]/3.0));
  } 
  
}
void ClearHistogram(){
  for(int i = 0 ; i < entries.length; i++)
    entries[i] = 0;
}

void BuildHistogram(){
  entries = new int[100];
  for(int i = 0 ;i < 100; i++){
    entries[i] = 0;
  }
}

void keyPressed() {
  if(keyCode == SHIFT || keyCode == CONTROL)
    return;
    
  if(key != BACKSPACE && keyCode != SHIFT)
    target += key;
  else if(target.length() > 0 && key == BACKSPACE)
    target = target.substring(0, target.length()-1);
    
  population = new Population(target, mutationRate, popmax);
  run = true;
}
