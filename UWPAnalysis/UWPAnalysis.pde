// this started out as a quick sketch - not sure if it will get folded into
// the primary Traveller project, or stay standalone

// probably should have it consume a subsector JSON instead of randomly
// creating a list, but this is good enough for now

int listSize = 40;
UWP[] systems;
float[] popPercent;
long totalPop;

float barHeight;

void setup(){
  background(255);
  size(600,600);
  
  barHeight = (height - 20) / listSize;
  
  systems = new UWP[listSize];
  popPercent = new float[listSize];
  
  totalPop = 0;
  for (int i = 0; i < listSize; i++){
    systems[i] = new UWP();
    totalPop += systems[i].popcount;
  }

  for (int i = 0; i < listSize; i++){
    popPercent[i] = (systems[i].popcount / (float)totalPop) * 100;
  } 

  println(magnitudeFormatNumber(totalPop));
  
  for (int i = 0; i < listSize; i++){
    println(systems[i] + " : " + 
            nf(popPercent[i],2,2) + "%  : " + 
            magnitudeFormatNumber(systems[i].popcount));// + " : " + 
            //systems[i].popcount + " : " + 
            //magnitudeFormatNumber((long)systems[i].popDensity) + " people/sq.mi."); 
  }
}

void draw(){
  background(255);
  textAlign(LEFT, TOP);

  for (int i = 0; i < listSize; i++){
    fill(0, 125, 255);
    stroke(0);
    rect(0, i * barHeight + 10, (width * popPercent[i]/100), barHeight);
    
    if (systems[i].importance >= 4){
      fill(255, 0, 0);
    } else {
      fill(0);
    }
    textSize(12);
    text(systems[i].toString(), 10, i * barHeight + 10);
  }
  
  textAlign(RIGHT, TOP);
  textSize(24);
  fill(0);
  text(magnitudeFormatNumber(totalPop), width, 0);
  
  stroke(0, 125, 255, 125);
  line(width/4, 0, width/4, height);
  line(width/2, 0, width/2, height);
  line(width/4 * 3, 0, width/4 * 3, height);
}


String magnitudeFormatNumber(long _num){
  float thousand = 1000;
  float million  = 1000000;
  float billion  = 1000000000;
  String result;
  if (floor(_num/billion) > 0){
    result = nf(_num/billion, 0, 2) + " billion";
  } else if (floor(_num/million) > 0){
    result = nf(_num/million, 0, 2) + " million";
  } else if (floor(_num/thousand) > 0){
    result = nf(_num/thousand, 0, 2) + " thousand";
  } else {
    //result = nf((float)_num/100, 0, 2) + " hundred";
    result = nf(_num,0,0);
  }
  return result;
}