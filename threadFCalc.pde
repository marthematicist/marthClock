// fld calc thread

float fDetail = 0.010;
float fSpeed = 0.010;
float hDetail = 0.002;
float hSpeed = 0.005;
float sDetail = 0.029;
float sSpeed = 0.05;
float bDetail = 0.049;
float bSpeed = 0.05;
float masterSpeed = 3;


volatile  float[] fld0;
volatile  float[] hue0;
volatile  float[] sat0;
volatile  float[] bri0;
volatile  float[] fld1;
volatile  float[] hue1;
volatile  float[] sat1;
volatile  float[] bri1;
volatile  float[] fld2;
volatile  float[] hue2;
volatile  float[] sat2;
volatile  float[] bri2;
volatile  float[] xf;
volatile  float[] yf;
volatile  float[] xh;
volatile  float[] yh;
volatile  float[] xs;
volatile  float[] ys;
volatile  float[] xb;
volatile  float[] yb;
volatile  float tf = 0;
volatile  float th = 0;
volatile  float ts = 0;
volatile  float tb = 0;
volatile  int numField;


void setupFieldData(int num) {
  numField = num;
  fld0 = new float[num];
  hue0 = new float[num];
  sat0 = new float[num];
  bri0 = new float[num];
  fld1 = new float[num];
  hue1 = new float[num];
  sat1 = new float[num];
  bri1 = new float[num];
  fld2 = new float[num];
  hue2 = new float[num];
  sat2 = new float[num];
  bri2 = new float[num];
  xf = new float[num];
  yf = new float[num];
  xh = new float[num];
  yh = new float[num];
  xs = new float[num];
  ys = new float[num];
  xb = new float[num];
  yb = new float[num];
  for( int i = 0 ; i < num ; i++ ) {
    fld0[i] = 0.5;
    hue0[i] = 0.5;
    sat0[i] = 0.5;
    bri0[i] = 0.5;
    fld1[i] = 0.5;
    hue1[i] = 0.5;
    sat1[i] = 0.5;
    bri1[i] = 0.5;
    fld2[i] = 0.5;
    hue2[i] = 0.5;
    sat2[i] = 0.5;
    bri2[i] = 0.5;
    xf[i] = PA.P[i].xr * fDetail;
      yf[i] = PA.P[i].yr * fDetail;
      xh[i] = (PA.P[i].xr+1*width) * hDetail;
      yh[i] = PA.P[i].yr * hDetail;
      xs[i] = (PA.P[i].xr+2*width) * sDetail;
      ys[i] = PA.P[i].yr * sDetail;
      xb[i] = (PA.P[i].xr+3*width) * bDetail;
      yb[i] = PA.P[i].yr * bDetail;
  }
}
  
volatile int calcFieldCounter = 0;
volatile int calcFieldCountTo = 1;

void thread_CalculateField() {
  flag_CalculateField_done = false;
  calcFieldCountTo = numField;
  for( int n = 0 ; n < numField ; n++ ) {
    calcFieldCounter = n;
    
    // update next element of fld2
    fld2[n] = noise( xf[n] , yf[n] , tf );
    hue2[n] = (noise( xh[n] , yh[n] , th )*1080)%360;
    sat2[n] = noise( xs[n] , ys[n] , ts )*1;
    bri2[n] = (noise( xb[n] , yb[n] , tb )+ 0.25 );
    if( bri2[n] > 1 ) { bri2[n] = 1; }
  }
  tf += fSpeed*masterSpeed;
  th += hSpeed*masterSpeed;
  tb += bSpeed*masterSpeed;
  ts += sSpeed*masterSpeed;
  
  flag_CalculateField_done = true;
  return;
}

void thread_UpdateField() {
  flag_UpdateField_done = false;
  
  for( int i = 0 ; i < numField ; i++ ) {
    fld0[i] = fld1[i];
    fld1[i] = fld2[i];
    hue0[i] = hue1[i];
    hue1[i] = hue2[i];
    sat0[i] = sat1[i];
    sat1[i] = sat2[i];
    bri0[i] = bri1[i];
    bri1[i] = bri2[i];
  }
  flag_UpdateField_done = true;
  //println( "flag_UpdateField_done " + flag_UpdateField_done );
  return;
}