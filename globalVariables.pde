int halfWidth;        // half of screen x resolution. set in setup()
int halfHeight;       // half of screen y resulution. set in setup()
float xRes;           // screen resolution
float yRes;           // screen resolution
PGraphics pg;         // graphics buffer (clock)
int numSpokes = 12;   // number of spokes in kaleidoscope background
Clock clock;
PixelEngine PE;

// SETTINGS
float alpha = 0.03;
float masterSpeed = 2;

float fDetail = 1;
float hDetail = 1;
float sDetail = 1;
float bDetail = 1;
float fSpeed = 1;
float hSpeed = 1;
float sSpeed = 1;
float bSpeed = 1;
float fOffset = 0.0;
float hOffset = 0;
float sOffset = 0.25;
float bOffset = 0.35;
float bandOffset = 30;
float[] bandStart = { 0.22 , 0.38 , 0.48 , 0.58 , 0.72 };
float[] bandEnd   = { 0.28 , 0.42 , 0.52 , 0.62 , 0.78 };
float bw = 0.007;
float[] bandWidth = { bw , bw , bw , bw , bw };
int numBands = 5;



int backgroundR = 0;
int backgroundG = 0;
int backgroundB = 0;
int outlineR = 255;
int outlineG = 255;
int outlineB = 255;