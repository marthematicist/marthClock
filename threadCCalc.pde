// color calulation thread

float alpha = 0.025;

color bgColor = color( 0 , 0 , 0 );
color outlineColor = color( 255 , 255 , 255 );
color bandColor = color( 32 );

//color bgColor = color( 255 , 255 , 255 );
//color outlineColor = color( 0 , 0 , 0 );

float[] bandStart = { 0.20 , 0.37 , 0.47 , 0.57 , 0.70 };
float[] bandEnd   = { 0.30 , 0.43 , 0.53 , 0.63 , 0.80 };
float[] bandWidth = { 0.007 , 0.007 , 0.007 , 0.007 , 0.007 };
int numBands = 5;

volatile int[]   pType0;    // 0 = bg ; 1 = outline ; 2 = color
volatile int[]   band0;
volatile float[] fldVal0;
volatile float[] hueVal0;
volatile float[] satVal0;
volatile float[] briVal0;
volatile int[]   pType1;
volatile int[]   band1;
volatile float[] fldVal1;
volatile float[] hueVal1;
volatile float[] satVal1;
volatile float[] briVal1;

void setupValues() {
  pType0 = new int[num0];
  band0 = new int[num0];
  fldVal0 = new float[num0];
  hueVal0 = new float[num0];
  satVal0 = new float[num0];
  briVal0 = new float[num0];
  for( int i = 0 ; i < num0 ; i++ ) {
    pType0[i] = 2;
    fldVal0[i] = 0;
    hueVal0[i] = 0;
    satVal0[i] = 0;
    briVal0[i] = 0;
  }
  pType1 = new int[num1];
  band1 = new int[num1];
  fldVal1 = new float[num1];
  hueVal1 = new float[num1];
  satVal1 = new float[num1];
  briVal1 = new float[num1];
  for( int i = 0 ; i < num1 ; i++ ) {
    pType1[i] = 2;
    fldVal1[i] = 0;
    hueVal1[i] = 0;
    satVal1[i] = 0;
    briVal1[i] = 0;
  }
  
}


void thread_CalculateValues0() {
  flag_CalculateValues0_done = false;
  for( int i = 0 ; i < num0 ; i++ ) {
    float f = lerp( fld0[i] , fld1[i] , currentProgress );
    band0[i] = -1;
    fldVal0[i] = f;
    int type = 0;
    for( int b = 0 ; b < numBands ; b++ ) {
      if( f >= (bandStart[b]-bandWidth[b]) && f <= (bandEnd[b]+bandWidth[b]) ) {
        if( f >= bandStart[b] && f <= bandEnd[b] ) {
          type = 2; //color
          hueVal0[i] = lerp360( hue0[i] , hue1[i] , currentProgress );
          satVal0[i] = lerp( sat0[i] , sat1[i] , currentProgress );
          briVal0[i] = lerp( bri0[i] , bri1[i] , currentProgress );
          band0[i] = b;
        } else {
          type = 1; //outline
        }
      }
      pType0[i] = type;
    }
  }
  flag_CalculateValues0_done = true;
  return;
}

void thread_CalculateValues1() {
  flag_CalculateValues1_done = false;
  for( int i = 0 ; i < num1 ; i++ ) {
    float f = lerp( fld0[i+num0] , fld1[i+num0] , currentProgress );
    band1[i] = -1;
    fldVal1[i] = f;
    int type = 0;
    for( int b = 0 ; b < numBands ; b++ ) {
      if( f >= (bandStart[b]-bandWidth[b]) && f <= (bandEnd[b]+bandWidth[b]) ) {
        if( f >= bandStart[b] && f <= bandEnd[b] ) {
          type = 2; //color
          hueVal1[i] = lerp360( hue0[i+num0] , hue1[i+num0] , currentProgress );
          satVal1[i] = lerp( sat0[i+num0] , sat1[i+num0] , currentProgress );
          briVal1[i] = lerp( bri0[i+num0] , bri1[i+num0] , currentProgress );
          band1[i] = b;
        } else {
          type = 1; //outline
        }
      }
    }
    pType1[i] = type;
  }
  flag_CalculateValues1_done = true;
  return;
}

void thread_CalculateColor0() {
  flag_CalculateColor0_done = false;
  color c;
  for( int i = 0 ; i < num0 ; i++ ) {
    if( pType0[i] == 1 ) {
      c = outlineColor;
    } else if( pType0[i] == 2 ) {
      c = hsbColor( (hueVal0[i]+band0[i]*60)%360 , satVal0[i] , briVal0[i] );
    } else {
      c = bgColor;
    }
    col0a[i] = lerpColor( col0[i] ,  c , alpha );
  }
  flag_CalculateColor0_done = true;
  return;
}
      
void thread_CalculateColor1() {
  flag_CalculateColor1_done = false;
  color c;
  for( int i = 0 ; i < num1 ; i++ ) {
    if( pType1[i] == 1 ) {
      c = outlineColor;
    } else if( pType1[i] == 2 ) {
      c = hsbColor( (hueVal1[i]+band1[i]*60)%360 , satVal1[i] , briVal1[i] );
    } else {
      c = bgColor;
    }
    col1a[i] = lerpColor( col1[i] ,  c , alpha );
  }
  flag_CalculateColor1_done = true;
  return;
}      
  

void thread_UpdateColor0() {
  flag_UpdateColor0_done = false;
  for( int i = 0 ; i < num0 ; i++ ) {
    col0[i] = col0a[i];
  }
  flag_UpdateColor0_done = true;
  //println( "flag_UpdateColor0_done " + flag_UpdateColor0_done );
  return;
}


void thread_UpdateColor1() {
  flag_UpdateColor1_done = false;
  for( int i = 0 ; i < num1 ; i++ ) {
    col1[i] = col1a[i];
  }
  flag_UpdateColor1_done = true;
  //println( "flag_UpdateColor1_done " + flag_UpdateColor1_done );
  return;
}