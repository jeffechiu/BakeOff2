import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean circlesIn = false;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 0;
float logoY = 0;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(-width/2+border, width/2-border); //set a random x with some padding
    d.y = random(-height/2+border, height/2-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }
  confirmSquare();

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Destination d = destinations.get(i);
    translate(d.x, d.y); //center the drawing coordinates to the center of the screen
    rotate(radians(d.rotation));
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  noStroke();
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"  
  if(closeRotation){
    fill(0, 255, 0);
    circle(0, 0, 50);
  }
  if(closeZ){
    fill(255);
  }else{
    fill(60, 60, 192, 192);
  }
  if(closeDist){
    stroke(50,168,82);
  }
  if (closeRotation && closeZ && closeDist) {
    fill(0, 255, 0);
  }
  circle(-logoZ/2, -logoZ/2, 10);
  circle(-logoZ/2, +logoZ/2, 10);
  circle(logoZ/2, -logoZ/2, 10);
  circle(logoZ/2, logoZ/2, 10);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void confirmSquare()
{
  fill(0, 255, 0);
  circle(inchToPix(1.5f), inchToPix(.5f), inchToPix(1f));
  fill(0, 0, 0);
  textSize(20);
  text("Confirm", inchToPix(1.5f), inchToPix(.6f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation++;

  //lower left corner, decrease Z
  text("-", inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
}

void expandCirclesIn()
{
  fill(255, 255, 255);
  circle(width/2+logoX-logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
  circle(width/2+logoX-logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
  circle(width/2+logoX+logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
  circle(width/2+logoX+logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
}

void expandCirclesOut()
{
  fill(255, 255, 255, 0);
  circle(width/2+logoX-logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
  circle(width/2+logoX-logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
  circle(width/2+logoX+logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
  circle(width/2+logoX+logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
}



void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
    
  }
  
  
}


void mouseDragged()
{
  
  /*
  if (mouseX > width/2+logoX-logoZ/2-inchToPix(.075f) && mouseX < width/2+logoX-logoZ/2+inchToPix(.075f) && mouseY > height/2+logoY-logoZ/2-inchToPix(.075f) &&  mouseY < height/2+logoY-logoZ/2+inchToPix(.075f)) {
    print("it happened");
    float distance = dist(mouseX, mouseY, width/2+logoX-logoZ/2, height/2+logoX-logoZ/2);
    logoZ = constrain(logoZ+distance, .01, inchToPix(4f)); //leave min and max alone!
    float newX = (mouseX+(width/2+logoX-logoZ/2))/2 - width/2 + logoZ/2;
    float newY = (mouseY+(height/2+logoY-logoZ/2))/2 - height/2 + logoZ/2;
    logoX = newX;
    logoY = newY;
    print(logoZ);
    
  
  */
  
  //dragging movement
  
  if (dist(mouseX, mouseY, width/2+logoX, height/2+logoY)  < logoZ/2) {

    logoX = mouseX-width/2;
    logoY = mouseY-height/2;
    /*
    if (circlesIn == false) {
          print("happened");
          fill(255, 255, 255);
          circle(width/2+logoX-logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
          circle(width/2+logoX-logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
          circle(width/2+logoX+logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
          circle(width/2+logoX+logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
          circlesIn = true;
        }
        else {
        fill(255, 255, 255, 0);
        circle(width/2+logoX-logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
        circle(width/2+logoX-logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
        circle(width/2+logoX+logoZ/2, height/2+logoY-logoZ/2, inchToPix(.15f));
        circle(width/2+logoX+logoZ/2, height/2+logoY+logoZ/2, inchToPix(.15f));
        circlesIn = false;
        }
        */
  } else if ((dist(mouseX, mouseY, width/2+logoX, height/2+logoY) < (logoZ+5)) || (dist(mouseX, mouseY, width/2+logoX, height/2+logoY) < (logoZ-5))){
    float deg = (degrees((atan2(mouseY-(height/2 + logoY), mouseX-(width/2 + logoX)) - radians(logoRotation)))) % 90;
      if (abs(45-abs(deg)) < 7) {
        // Rotate the square if dragged anywhere away from its diagonal lines
        float angleToCenter = atan2(mouseY-(height/2 + logoY), mouseX-(width/2 + logoX)) - 3.14/4.0;
        logoRotation = degrees(angleToCenter);
        
        // If dragged anywhere along the circle of the mouse and the angle matches the corner, change the size
        logoZ = dist(mouseX, mouseY, width/2+logoX, height/2+logoY)*1.414;
        logoZ = constrain(dist(mouseX, mouseY, width/2+logoX, height/2+logoY)*1.414, .01, inchToPix(4f));
      }
    }
  }  



void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (mouseX > inchToPix(1f) && mouseX < inchToPix(2f) && mouseY > inchToPix(0) && mouseY < inchToPix(1f))//(dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  
}

void dragLogic()
{
  Destination d = destinations.get(trialIndex);
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
