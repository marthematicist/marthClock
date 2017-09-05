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

void threadFCalc() {
  int num = PA.num;
  float xf[];
  float yf[];
  float xh[];
  float yh[];
  float xs[];
  float ys[];
  float xb[];
  float yb[];
  xf = new float[num];
  yf = new float[num];
  xh = new float[num];
  yh = new float[num];
  xs = new float[num];
  ys = new float[num];
  xb = new float[num];
  yb = new float[num];
  for( int i = 0 ; i < num ; i++ ) {
    xf[i] = PA.P[i].xr * fDetail;
    yf[i] = PA.P[i].yr * fDetail;
    xh[i] = (PA.P[i].xr+1*width) * hDetail;
    yh[i] = PA.P[i].yr * hDetail;
    xs[i] = (PA.P[i].xr+2*width) * sDetail;
    ys[i] = PA.P[i].yr * sDetail;
    xb[i] = (PA.P[i].xr+3*width) * bDetail;
    yb[i] = PA.P[i].yr * bDetail;
  }
  float tf = 0;
  float th = 0;
  float ts = 0;
  float tb = 0;
  
  int n = 0;
  float fld2[] = new float[ num ];
  float hue2[] = new float[ num ];
  float sat2[] = new float[ num ];
  float bri2[] = new float[ num ];
  while(true) {
    // handle request for progress
    if( fldFlag_draw_requestProgress ) {
      fldFlag_draw_requestProgress = false;
      fldProgress = float(n) / float(num);
      fldFlag_thread_progressReady = true;
    }
    
    // update next element of fld2
    fld2[n] = noise( xf[n] , yf[n] , tf );
    hue2[n] = (noise( xh[n] , yh[n] , th )*1080)%360;
    sat2[n] = noise( xs[n] , ys[n] , ts )*1;
    bri2[n] = (noise( xb[n] , yb[n] , tb )+ 0.25 );
    if( bri2[n] > 1 ) { bri2[n] = 1; }
    // update counter
    n++;
    
    // check if done with fld calculations
    if( n >= num ) {
      // set flag: ready to update
      fldFlag_thread_readyToUpdate = true;
      // wait for flag: go update
      while( !fldFlag_draw_goUpdate ) {
        // handle request for progress
        if( fldFlag_draw_requestProgress ) {
          fldFlag_draw_requestProgress = false;
          fldProgress = float(n) / float(num);
          fldFlag_thread_progressReady = true;
        }
      }
      
      // update fld data
      fldFlag_draw_goUpdate = false;
      for( int i = 0 ; i < num ; i++ ) {
        fld0[i] = fld1[i];
        fld1[i] = fld2[i];
        hue0[i] = hue1[i];
        hue1[i] = hue2[i];
        sat0[i] = sat1[i];
        sat1[i] = sat2[i];
        bri0[i] = bri1[i];
        bri1[i] = bri2[i];
      }
      fldFlag_thread_doneUpdating = true;
      
      
      n = 0;
      tf += fSpeed*masterSpeed;
      th += hSpeed*masterSpeed;
      tb += bSpeed*masterSpeed;
      ts += sSpeed*masterSpeed;
    }
    
    
  }
  
}