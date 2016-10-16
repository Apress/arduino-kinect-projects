
int timer;

void setup(){
 
 size(800,600);
 
}

void draw(){
  
  background(255); 
  
  ellipse(timer,height/2,30,30);
  
  timer = timer + 1;
}
