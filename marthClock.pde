String zip = "98264";
String APIkey = "41ece43d5325fc28";
Boolean liveData = true;    // set true to get real data from api, false for testing
Boolean logClockUpdateTime = false;

volatile PixelArray PA;

// fld: controls the field ( background, outline, or fill )
volatile float[] fld0;
volatile float[] fld1;
volatile float[] hue0;
volatile float[] hue1;
volatile float[] sat0;
volatile float[] sat1;
volatile float[] bri0;
volatile float[] bri1;
volatile float fldProgress = 0;
volatile float currentProgress = 0;
volatile boolean fldFlag_thread_readyToUpdate = false;
volatile boolean fldFlag_draw_goUpdate = false;
volatile boolean fldFlag_thread_doneUpdating = false;
volatile boolean fldFlag_draw_requestProgress = false;
volatile boolean fldFlag_thread_progressReady = false;

volatile color[] col0;
int num0;
volatile color[] col1;
int num1;
volatile boolean colFlg_draw_goRender0 = false;
volatile boolean colFlg_draw_goRender1 = false;
volatile boolean colFlg_thread_Rendering0 = false;
volatile boolean colFlg_thread_Rendering1 = false;
volatile boolean colFlg_thread_doneRendering0 = false;
volatile boolean colFlg_thread_doneRendering1 = false;
volatile boolean colFlg_draw_goUpdate0 = false;
volatile boolean colFlg_draw_goUpdate1 = false;
volatile boolean colFlag_thread_Updating0 = false;
volatile boolean colFlag_thread_Updating1 = false;
volatile boolean colFlag_thread_doneUpdating0 = false;
volatile boolean colFlag_thread_doneUpdating1 = false;
volatile boolean colFlag_thread_loopComplete0 = false;
volatile boolean colFlag_thread_loopComplete1 = false;


// resolution helpers
int halfWidth;
int halfHeight;

PGraphics pg;

// clock constants
float outerRadius;
float innerRadius;



float borderWidth;
int millisOffset; 

Clock clock;

void setup() {
  //frameRate(25);
  size( 800 , 480 );
  pg = createGraphics( width , height );
  halfWidth = width/2;
  halfHeight = height/2;
  background(bgColor);

  
  clock = new Clock();

  outerRadius = 0.65*width;
  innerRadius = -1;
  
  PA = new PixelArray();
  fld0 = new float[PA.num];
  fld1 = new float[PA.num];
  hue0 = new float[PA.num];
  hue1 = new float[PA.num];
  sat0 = new float[PA.num];
  sat1 = new float[PA.num];
  bri0 = new float[PA.num];
  bri1 = new float[PA.num];
  for( int i = 0 ; i < PA.num ; i++ ) {
    fld0[i] = 0;
    fld1[i] = 0;
    hue0[i] = 0;
    hue1[i] = 0;
    sat0[i] = 0;
    sat1[i] = 0;
    bri0[i] = 0;
    bri1[i] = 0;
  }
  num0 = PA.num/2;
  num1 = PA.num-num0;
  col0 = new color[num0];
  col1 = new color[num1];
  for( int i = 0 ; i < num0 ; i++ ) {
    col0[i] = color(0);
  }
  for( int i = 0 ; i < num1 ; i++ ) {
    col1[i] = color(0);
  }
  
  
  thread( "threadFCalc" );
  while( !fldFlag_thread_readyToUpdate ) {
    // wait until fld data ready
  }
  fldFlag_thread_readyToUpdate = false;
  fldFlag_draw_goUpdate = true;
  while( !fldFlag_thread_doneUpdating ) {
    // wait until done updating
  }
  fldFlag_thread_doneUpdating = false;
  
  while( !fldFlag_thread_readyToUpdate ) {
    // wait until fld data ready
  }
  fldFlag_thread_readyToUpdate = false;
  fldFlag_draw_goUpdate = true;
  while( !fldFlag_thread_doneUpdating ) {
    // wait until done updating
  }
  fldFlag_thread_doneUpdating = false;
  
  thread( "threadCCalc0" );
  thread( "threadCCalc1" );
}

boolean logOut = false;
void draw() {
  background(bgColor);
  
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FRAMESTART" ); }
  
  // request fld progress
  fldFlag_draw_requestProgress = true;
  while( !fldFlag_thread_progressReady ) {
    // wait until progress is ready
  }
  currentProgress = fldProgress;
  fldFlag_thread_progressReady = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PROGRESSUPDATED" ); }
  
  
  colFlg_draw_goRender0 = true;
  while( !colFlg_thread_Rendering0 ) {}
  colFlg_thread_Rendering0 = false;
  colFlg_draw_goRender0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERSTART0" ); }
   
  colFlg_draw_goRender1 = true;
  while( !colFlg_thread_Rendering1 ) {}
  colFlg_thread_Rendering1 = false;
  colFlg_draw_goRender1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERSTART1" ); }
  
  
  loadPixels();
  for( int i = 0 ; i < width*height ; i++ ) {
    
    if( PA.I[i] >=0 ) {
      if( PA.I[i] < num0 ) {
        pixels[ i ] = col0[ PA.I[i] ];
      } else {
        pixels[ i ] = col1[ PA.I[i]-num0 ];
      }
    }
  }
  updatePixels();
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELSDONE" ); }
  
  while( !colFlg_thread_doneRendering0 ) {}
  colFlg_thread_doneRendering0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERDONE0" ); }
  while( !colFlg_thread_doneRendering1 ) {}
  colFlg_thread_doneRendering1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  RENDERDONE1" ); }
 
  colFlg_draw_goUpdate0 = true;
  while( !colFlag_thread_Updating0 ) {}
  colFlag_thread_Updating0 = false;
  colFlg_draw_goUpdate0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXEL UPDATE STARTED0" ); }
  
  colFlg_draw_goUpdate1 = true;
  while( !colFlag_thread_Updating1 ) {}
  colFlag_thread_Updating1 = false;
  colFlg_draw_goUpdate1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXEL UPDATE STARTED1" ); }
  
  if( fldFlag_thread_readyToUpdate ) {
    fldFlag_thread_readyToUpdate = false;
    fldFlag_draw_goUpdate = true;
    if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FLD UPDATE STARTED" ); }
    while( !fldFlag_thread_doneUpdating ) {
      // wait until done updating
    }
    fldFlag_thread_doneUpdating = false;
    if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  FLD UPDATE DONE" ); }
  }
  
  
  while( !colFlag_thread_doneUpdating0 ) {}
  colFlag_thread_doneUpdating0 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELS UPDATE DONE0" ); }
  while( !colFlag_thread_doneUpdating1 ) {}
  colFlag_thread_doneUpdating1 = false;
  if( logOut ) { println( "frame: " , frameCount , "  time: " , millis() , "  PIXELS UPDATE DONE1" ); }
  
  while( !colFlag_thread_loopComplete0 ) {}
  colFlag_thread_loopComplete0 = false;
  while( !colFlag_thread_loopComplete1 ) {}
  colFlag_thread_loopComplete1 = false;
  
  if( frameCount%500 == 0 ) {
    println( "frameRate: " , frameRate );
  }
  
  
  if( second() != prevSecond ) {
    prevSecond = second();
    secondChanged = true;
  }
  if( minute() != prevMin ) {
    prevMin = minute();
    minuteChanged = true;
  }
  if( hour() != prevHour ) {
    prevHour = hour();
    hourChanged = true;
    clock.updateWeather();
  }
  if( day() != prevDay ) {
    prevDay = day();
    dayChanged = true;
    clock.updateAstronomy();
  }
    
  clock.drawClock();
  
  if( mouseDownQuit ) {
    if( millis() - mousePressTime > mousePressTimeout ) {
      exit();
    }
    if( millis() - mousePressTime > mouseMessageDelay ) {
      String msg = "CLOSING IN " + ( (mousePressTimeout - (millis() - mousePressTime) )/1000+1 );
      showSystemMessage( msg );
    }
  }
  
  if( alphaSliderEngaged ) {
    alpha = lerpCube( alphaMin , alphaMax , float(mouseX)/float(width) );
    String msg = "smoothness =  " + nf( float( round( alpha*1000 ) ) / 1000 , 0 , 3);
    showSystemMessage( msg );
  }
  if( speedSliderEngaged ) {
    masterSpeed = lerpSquare( speedMin , speedMax , float(mouseX)/float(width) );
    String msg = "speed =  " + nf( float( round( masterSpeed*100 ) ) / 100 , 0 , 2);
    showSystemMessage( msg );
  }
  
  if( captureScreenshot ) {
    captureScreenshot = false;
    save( "screenShot.jpg" );
  }
    
  
}

int prevSecond = -1;
int prevMin = -1;
int prevHour = -1;
int prevDay = -1;
boolean secondChanged = false;
boolean minuteChanged = false;
boolean hourChanged = false;
boolean dayChanged = false;
boolean resetClock = false;

boolean mouseDownQuit = false;
int mousePressTime = 0;
int mousePressTimeout = 6000;
int mouseMessageDelay = 1000;

float sliderHeight = 30;
boolean speedSliderEngaged = false;
boolean alphaSliderEngaged = false;
float alphaMin = 0.001;
float alphaMax = 1;
float speedMin = 0;
float speedMax = 10;

boolean captureScreenshot = false;

void mousePressed() {
  if( mouseY >= sliderHeight && height - mouseY >= sliderHeight ) { 
    mouseDownQuit = true;
    if( mouseX >= halfWidth ) { clock.nextClock(); }
    else { clock.prevClock(); }
  } else {
    if( mouseY >sliderHeight ) {
      speedSliderEngaged = true;
    }
    if( height - mouseY > sliderHeight ) {
      alphaSliderEngaged = true;
    }
  }
  
  resetClock = true;
  mousePressTime = millis();
}

void mouseReleased() {
  mouseDownQuit = false;
  speedSliderEngaged = false;
  alphaSliderEngaged = false;
  
}

void keyPressed() {
  if( key == 's' ) {
    captureScreenshot = true;
  }
}

void showSystemMessage( String systemText ) {
  textAlign(CENTER,CENTER);
      textSize(40);
      rectMode(CENTER);
      fill(255,0,0,196);
      stroke( 255 );
      strokeWeight( 5);
      float msgWidth = textWidth( systemText );
      rect(halfWidth , halfHeight+5 , msgWidth + 20 , 60 , 10 , 10 , 10 , 10 );
      fill(255);
      text( systemText , halfWidth , halfHeight );
}


float lerpSquare( float val1 , float val2 , float amt ) {
  return lerp( val1 , val2 , amt*amt );
}

float lerpCube( float val1 , float val2 , float amt ) {
  return lerp( val1 , val2 , amt*amt*amt );
}