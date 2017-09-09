class RenderedPixel {
  // COLOR DATA
  int R;           // RGB red
  int G;           // RGB blue
  int B;           // RGB green
  int colorValue;     // color value (hex)
  int colorValueFixed;
  // RANDOMIZED VALUES
  float fldInitial = 0.5;       // determines whether pixel is bg, outline, or color
  float hueInitial = 180;       // hue
  float satInitial = 0.5;       // saturation
  float briInitial = 0.5;       // brightness
  float fldFinal = 0.5;
  float hueFinal = 180;
  float satFinal = 0.5;
  float briFinal = 0.5;
  // RENDER LOCATION
  float xRender;      // the x and y coordinates relative to the center
  float yRender;      // of the screen, and rotated/reflected
  // NUMBER OF CHILD PIXELS
  int numChildPixels;
  // SCREEN LOCATION
  int[] xPixels;      // screen coordinates of all child pixels
  int[] yPixels;      // rendered by this RenderedPixel
  // ARRAY LOCATION
  int[] iPixels;      // graphics buffer indices of all child pixels 
                      // rendered by this RenderedPixel
  // RANDOM VALUE LOCATIONS
  float xFld;
  float yFld;
  float xHue;
  float yHue;
  float xSat;
  float ySat;
  float xBri;
  float yBri;
  
  RenderedPixel() {
    // empty constructor
  }
  
  RenderedPixel( int x , int y ) {
    // Set default color values
    this.R = 0;
    this.G = 0;
    this.B = 0;
    
    setColorValue();
    
    // Calculate render location
    float ang = atan2( float(x) , float(y) ) % ( TWO_PI/numSpokes );
    if( ang > 0.5*( TWO_PI/numSpokes ) ) {
      ang = TWO_PI/12.0 - ang ;
    }
    float rad = sqrt( float(x*x) + float(y*y) );
    this.xRender = rad*cos(ang);
    this.yRender = rad*sin(ang);
    
    // Calculate child values:
    this.numChildPixels = 4;
    // create temporary lists containing x, y values
    IntList xt = new IntList();
    IntList yt = new IntList();
    // append original and reflections over x=0 and y=0
    xt.append( halfWidth + x );
    yt.append( halfHeight + y );
    xt.append( halfWidth-1 - x );
    yt.append( halfHeight-1 - y );
    xt.append( halfWidth + x );
    yt.append( halfHeight-1 - y );
    xt.append( halfWidth-1 - x );
    yt.append( halfHeight + y );
    // append reflections over y=x if they are on screen
    if( (x < halfHeight) && (y < halfWidth) && (x != y) ) {
      this.numChildPixels = 8;
      yt.append( halfHeight + x );
      xt.append( halfWidth + y );
      yt.append( halfHeight-1 - x );
      xt.append( halfWidth-1 - y );
      yt.append( halfHeight + x );
      xt.append( halfWidth-1 - y );
      yt.append( halfHeight-1 - x );
      xt.append( halfWidth + y );
    }
    // dump temp values into field arrays
    this.xPixels = new int[numChildPixels];
    this.yPixels = new int[numChildPixels];
    this.iPixels = new int[numChildPixels];
    for( int i = 0 ; i < numChildPixels ; i++ ) {
      xPixels[i] = xt.get(i);
      yPixels[i] = yt.get(i);
      iPixels[i] = xt.get(i) + yt.get(i)*width;
    }
    // Calculate random value locations
    xFld = xRender * fDetail;
    yFld = yRender * fDetail;
    xHue = (xRender+1*width) * hDetail;
    yHue = yRender * hDetail;
    xSat = (xRender+2*width) * sDetail;
    ySat = yRender * sDetail;
    xBri = (xRender+3*width) * bDetail;
    yBri = yRender * bDetail;
  }
  
  void updateColor( float progress ) {
    // calculate field value: determines if pixel is background, outline, or color
    // based on band settings
    float fld = lerp(fldInitial,fldFinal,progress);
    // assume pixel will be background color
    int r = backgroundR;   int g = backgroundG;  int b = backgroundB;
    // check to see if pixel is in each of the bands
    for( int i = 0 ; i < numBands ; i++ ) {
      if( fld >= (bandStart[i]-bandWidth[i]) && fld <= (bandEnd[i]+bandWidth[i]) ) {
        // pixel is in this band so either outline or color
        if( fld >= bandStart[i] && fld <= bandEnd[i] ) {
          // pixel is color:
          // calculate hue, saturation, and brightness values
          float hue = (lerp360( hueInitial , hueFinal , progress )+bandOffset*i)%360;
          float sat = lerp(satInitial,satFinal,progress);
          float bri = lerp(briInitial,briFinal,progress);
          int[] colarray = RGBfromHSB( hue , sat , bri );
          r = colarray[0];  g = colarray[1];  b = colarray[2];
        } else {
          // pixel is outline:
          r = outlineR;   g = outlineG;  b = outlineB;
        }
      } else {
        // pixel is background
        // do nothing because we made that assumption already
      }
    }
    // set new colors
    R = round(lerp(float(R),float(r),alpha));
    G = round(lerp(float(G),float(g),alpha));
    B = round(lerp(float(B),float(b),alpha));
    setColorValue();
  }
  
  RenderedPixel copy() {
    RenderedPixel out = new RenderedPixel();
    out.R = this.R;
    out.G = this.G;
    out.B = this.B;
    out.colorValue = this.colorValue;
    out.fldInitial = this.fldInitial;
    out.hueInitial = this.hueInitial;
    out.satInitial = this.satInitial;
    out.briInitial = this.briInitial;
    out.fldFinal = this.fldFinal;
    out.hueFinal = this.hueFinal;
    out.satFinal = this.satFinal;
    out.briFinal = this.briFinal;    
    out.xRender = this.xRender;
    out.yRender = this.yRender;
    out.numChildPixels = this.numChildPixels;
    out.xPixels = new int[this.numChildPixels];
    out.yPixels = new int[this.numChildPixels];
    out.iPixels = new int[this.numChildPixels];
    for( int i = 0 ; i < this.numChildPixels ; i++ ) {
      out.xPixels[i] = this.xPixels[i];
      out.yPixels[i] = this.yPixels[i];
      out.iPixels[i] = this.iPixels[i];
    }
    out.xFld = this.xFld;
    out.yFld = this.yFld;
    out.xHue = this.xHue;
    out.yHue = this.yHue;
    out.xSat = this.xSat;
    out.ySat = this.ySat;
    out.xBri = this.xBri;
    out.yBri = this.yBri;
    return out;
  }
  
  int[] RGBfromHSB( float h , float s  , float b ) {
    h %= 360;
    float c = b*s;
    float x = c*( 1 - abs( (h/60) % 2 - 1 ) );
    float m = b - c;
    float rp = 0;
    float gp = 0;
    float bp = 0;
    if ( 0 <= h && h < 60 ) { rp = c;  gp = x;  bp = 0; }
    if ( 60 <= h && h < 120 ) { rp = x;  gp = c;  bp = 0; }
    if ( 120 <= h && h < 180 ) { rp = 0;  gp = c;  bp = x; }
    if ( 180 <= h && h < 240 ) { rp = 0;  gp = x;  bp = c; }
    if ( 240 <= h && h < 300 ) { rp = x;  gp = 0;  bp = c; }
    if ( 300 <= h && h < 360 ) { rp = c;  gp = 0;  bp = x; }
    int R = round( (rp+m)*255 );
    int G = round( (gp+m)*255 );
    int B = round( (bp+m)*255 );
    int[] out = {R , G , B};
    return out;
  }
  
  void setColorValue() {
    this.colorValue = ( 
      (255<<24) | 
      (round(constrain(R,0,255))<<16) | 
      (round(constrain(G,0,255))<<8) | 
      (round(constrain(B,0,255)) ) 
    );
  }
  
}