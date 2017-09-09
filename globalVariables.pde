int halfWidth;        // half of screen x resolution. set in setup()
int halfHeight;       // half of screen y resulution. set in setup()
float xRes;           // screen resolution
float yRes;           // screen resolution
PGraphics pg;         // graphics buffer (clock)
int numSpokes = 12;   // number of spokes in kaleidoscope background
Clock clock;
PixelEngine PE;

// SETTINGS
float alpha = 0.02;
float masterSpeed = 3;

float fDetail = 0.010;
float hDetail = 0.0002;
float sDetail = 0.029;
float bDetail = 0.049;
float fSpeed = 0.010;
float hSpeed = 0.005;
float sSpeed = 0.05;
float bSpeed = 0.05;
float fOffset = 0;
float hOffset = 0;
float sOffset = 0.25;
float bOffset = 0.25;
float bandOffset = 30;

float[] bandStart = { 0.20 , 0.37 , 0.47 , 0.57 , 0.70 };
float[] bandEnd   = { 0.30 , 0.43 , 0.53 , 0.63 , 0.80 };
float[] bandWidth = { 0.007 , 0.007 , 0.007 , 0.007 , 0.007 };
int numBands = 5;



int backgroundR = 0;
int backgroundG = 0;
int backgroundB = 0;
int outlineR = 255;
int outlineG = 255;
int outlineB = 255;