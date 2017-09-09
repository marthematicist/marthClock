class PixelBlock implements Runnable {
  int numRenderedPixels;
  RenderedPixel[] RenderedPixels;
  float progress;
  
  PixelBlock( ArrayList<RenderedPixel> RPin ) {
    this.numRenderedPixels = RPin.size();
    RenderedPixels = new RenderedPixel[numRenderedPixels];
    for( int i = 0 ; i < numRenderedPixels ; i++ ) {
      RenderedPixels[i] = RPin.get(i).copy();
    }
  }
  
  void run() {
    // update all pixels
    for( int i = 0 ; i < numRenderedPixels ; i++ ) {
      RenderedPixels[i].updateColor( progress );
    }
  }
  
  void setProgress( float progressIn ) {
    progress = progressIn;
  }
  
  void fixColorValues() {
    for( int i = 0 ; i < numRenderedPixels ; i++ ) {
      RenderedPixels[i].colorValueFixed = RenderedPixels[i].colorValue;
    }
  }
  
}