

class PixelEngine {
  int numPixelBlocks;          // number of pixel blocks
  Randomizer randomizer;       // object to make the random numbers
  PixelBlock[] PixelBlocks;    // blocks of pixels
  int[] IsInBlock;             // tracks in which block each RenderedPixel resides
  int[] HasIndexInBlock;       // tracks the index of each RenderedPixel within its block
  Thread[] BlockThreads;       // threads that the PixelBlocks will run
  Thread randomizerThread;
  int numRenderedPixels;       // total number of RenderedPixels shared among the blocks
  float tf = 0;                // time variables
  float th = 0;
  float ts = 0;
  float tb = 0;
  
  PixelEngine( int numPixelBlocksIn ) {
    this.numPixelBlocks = numPixelBlocksIn;
    this.PixelBlocks = new PixelBlock[numPixelBlocks];
    this.BlockThreads = new Thread[numPixelBlocks];
    this.numRenderedPixels = 0;
    
    // create a temporary ArrayList of RenderedPixels
    ArrayList<RenderedPixel> PT = new ArrayList<RenderedPixel>();
    for( int x = 0 ; x < halfWidth ; x++ ) {
      for( int y = 0 ; y < halfHeight ; y++ ) {
        if( y <= x ) {
          PT.add( new RenderedPixel( x , y ) );
          numRenderedPixels++;
        }
      }
    }
    randomizer = new Randomizer( PT );
    // portion out the temporary arraylist into smaller arraylists
    this.IsInBlock = new int[numRenderedPixels];
    this.HasIndexInBlock = new int [numRenderedPixels];
    int numRenderedPixelsPerBlock = ceil( float(numRenderedPixels) / float(numPixelBlocks) );
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      ArrayList<RenderedPixel> blockList = new ArrayList<RenderedPixel>();
      int startInd = i*numRenderedPixelsPerBlock;
      int endInd = (i+1)*numRenderedPixelsPerBlock;
      int numInd = endInd - startInd;
      if( endInd > numRenderedPixels ) { endInd = numRenderedPixels; }
      for( int j = startInd ; j < endInd ; j++ ) {
        blockList.add( PT.get( j ).copy() );
        IsInBlock[j] = i;
        HasIndexInBlock[j] = j-startInd;
      }
      PixelBlocks[i] = new PixelBlock( blockList );
    }
  }
  
  int[] outputPixelData() {
    int[] out = new int[width*height];
    for( int pb = 0 ; pb < numPixelBlocks ; pb++ ) {
      for( int rp = 0 ; rp < PixelBlocks[pb].numRenderedPixels ; rp++ ) {
        for( int i = 0 ; i < PixelBlocks[pb].RenderedPixels[rp].numChildPixels ; i++ ) {
          out[ PixelBlocks[pb].RenderedPixels[rp].iPixels[i] ] = PixelBlocks[pb].RenderedPixels[rp].colorValueFixed;
        }
      }
    }
    return out;
  }
  
  void writePixelData() {
    for( int pb = 0 ; pb < numPixelBlocks ; pb++ ) {
      for( int rp = 0 ; rp < PixelBlocks[pb].numRenderedPixels ; rp++ ) {
        for( int i = 0 ; i < PixelBlocks[pb].RenderedPixels[rp].numChildPixels ; i++ ) {
          pixels[ PixelBlocks[pb].RenderedPixels[rp].iPixels[i] ] = PixelBlocks[pb].RenderedPixels[rp].colorValueFixed;
        }
      }
    }
  }
  
  void updateRandomNumbers() {
    for( int i = 0 ; i < numRenderedPixels ; i++ ) {
      int block = IsInBlock[i];
      int pix = HasIndexInBlock[i];
      PixelBlocks[block].RenderedPixels[pix].fldInitial = PixelBlocks[block].RenderedPixels[pix].fldFinal;
      PixelBlocks[block].RenderedPixels[pix].hueInitial = PixelBlocks[block].RenderedPixels[pix].hueFinal;
      PixelBlocks[block].RenderedPixels[pix].satInitial = PixelBlocks[block].RenderedPixels[pix].satFinal;
      PixelBlocks[block].RenderedPixels[pix].briInitial = PixelBlocks[block].RenderedPixels[pix].briFinal;
      PixelBlocks[block].RenderedPixels[pix].fldFinal = randomizer.fld[i];
      PixelBlocks[block].RenderedPixels[pix].hueFinal = randomizer.hue[i];
      PixelBlocks[block].RenderedPixels[pix].satFinal = randomizer.sat[i];
      PixelBlocks[block].RenderedPixels[pix].briFinal = randomizer.bri[i];
    }
  }
  
  void createNewRandomizerThread() {
    randomizerThread = new Thread( randomizer );
  }
  void startRandomizerThread() {
    randomizerThread.start();
  }
  void waitForRandomizerThreadToFinish() {
    try {
      randomizerThread.join();
    } catch ( InterruptedException e) {
      return;
    }
  }
  void interruptRandomizerThread() {
    randomizerThread.interrupt();
  }
  void updateRandomizerProgress() {
    float p = randomizer.progress;
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      PixelBlocks[i].setProgress(p);
    }
  }
  
  boolean randomNumbersReady() {
    return randomizer.doneWithBatch;
  }
  
  void createNewBlockThreads() {
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      BlockThreads[i] = new Thread( PixelBlocks[i] ); 
    }
  }
  
  void startBlockThreads() {
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      BlockThreads[i].start(); 
    }
  }
  void interruptThreadBlocks() {
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      BlockThreads[i].interrupt(); 
    }
  }
  void fixColorValues() {
    for( int i = 0 ; i < numPixelBlocks ; i++ ) {
      PixelBlocks[i].fixColorValues(); 
    }
  }
  void waitForBlockThreadsToFinish() {
    try {
      for( int i = 0 ; i < numPixelBlocks ; i++ ) {
        BlockThreads[i].join(); 
      }
    } catch(InterruptedException e) {
      return;
    }
  }
  
  
}