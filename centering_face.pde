import gifAnimation.*;
import processing.opengl.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.*;

GifMaker gifExport;
boolean rec = false;

Capture video;
PGraphics pg;

float face_x, face_y, face_w, face_h, vx, vy, offX, offY, offZ;
boolean calib;

boolean faceRect = true;


OpenCV face_cv;

public void setup() {
  size(1280, 960, OPENGL);
  frameRate(60); // 60fps

  // gifModules
  gifExport = new GifMaker(this, "export.gif"); 
  gifExport.setRepeat(0);
  gifExport.setQuality(30);
  gifExport.setDelay(20);
  //gifExport.setTransparent(0,0,0);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }

  //320*240
  video = new Capture(this, 640/2, 480/2, 30);

  face_cv = new OpenCV(this, video);
  face_cv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  pg = createGraphics(video.width, video.height, OPENGL);  

  video.start();
}

void draw() {
  background(0);
  face_cv.loadImage(video);
  face_cv.gray();
  Rectangle[] faces = face_cv.detect();

  pg.beginDraw();
  pg.image(video, 0, 0 );

  pg.noFill();
  pg.strokeWeight(3);
  pg.stroke(0, 255, 0);
  for (int i = 0; i < faces.length; i++) {
    float cx = faces[i].x+(faces[i].width/2);
    float cy = faces[i].y+(faces[i].height/2);
    vx = (face_x-cx);
    vy = (face_y-cy);
    face_x = cx;
    face_y = cy;
    face_w=faces[i].width;
    face_h=faces[i].height;

    //println("face_x="+face_x+" face_y="+face_y+" vx="+vx+" vy="+vy);
    if(faceRect)pg.rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }

  pg.endDraw();
  //pg.get(pg.width-(pg.height/2), 0, (pg.height/2), pg.height);


  ambientLight(63, 31, 31); 
  directionalLight(255, 255, 255, -1, 0, 0); 
  pointLight(63, 127, 255, width/2, height/2, 200); 
  spotLight(100, 100, 100, width/2, height/2, 200, 0, 0, -1, PI, 2);

  //camera(width/2, height/2, 200, width/2.0, height/2.0, 0, 0, 1, 0);
  if (!calib)camera(width/2, height/2, 300, width/2.0, height/2.0, 0, 0, 1, 0);
  else camera(face_x+offX, map(face_y+offY, 0, height, height, 0), 300, width/2.0, height/2.0, 0, 0, 1, 0);

  pushMatrix();
  if (!calib)translate(width / 2, height / 2, 0);
  else translate(face_x+offX, map(face_y+offY, 0, height, height, 0), map((face_w*face_h)+offZ, -10000, 10000, 50, -50));

  beginShape();
  texture(pg);
  vertex(-100, -100, 0, pg.width, 0);
  vertex(100, -100, 0, 0, 0);
  vertex(100, 100, 0, 0, pg.height);
  vertex(-100, 100, 0, pg.width, pg.height);
  endShape();
  popMatrix();

  if (rec) {
    this.loadPixels();
    gifExport.addFrame(this.pixels, width, height);
  }
}




void keyPressed() {
  if (key==ENTER) {
    if (!rec) {
      rec = true;
    } else {
      gifExport.finish();
      exit();
    }
  }else{
    faceRect = !faceRect;
  }
}


void captureEvent(Capture c) {
  c.read();
}

void mousePressed() {
  if (!calib) {
    offX=(width/2)-face_x;
    offY=(height/2)-face_y;
    offZ=0-(face_w*face_h);
    calib=true;
  }
}