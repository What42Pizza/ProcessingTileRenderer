// Started 04/05/21
// Last updated 04/12/21

// Alpha 1.1.1





/*

Change log:

Alpha 1.1.1: 04/20/21
fixed var name error

Alpha 1.1.0: 04/12/21
added scrolling
added RendetingData.TimeTaken
renamed many RenderingData vars
removed old renderer function
moved the loader class to the main file (w/ setup() & draw())

Alpha 1.0.0: 04/07/21
finished first working renderer

*/




// Settings

boolean UseFullScreen = true;

// for non-fullscreen
int Width = 512;
int Height = 512;

int Zoom = 2;

int NumOfThreads = 8;





// Vars

int[][] Map;
PImage[] Textures;

int TextureSize = 4; // 16x16 (2^4=16)

TileRenderer TR;





void setup() {
  frameRate (60);
}



void settings() {
  
  if (UseFullScreen) {
    fullScreen();
    width = 1920;
    height = 1080;
  } else {
    size (Width, Height);
  }
  
  Textures = Loader.GetTextures();
  Map = new int [width / TextureSize] [height / TextureSize];
  
  TR = new TileRenderer (Map, Textures, TextureSize, NumOfThreads, width, 0, 0, width, height);
  
}




int TotalTimeTaken = 0;

void draw() {
  
  RenderingData.Zoom = Zoom;
  RenderingData.CameraX = mouseX / 100.0;
  RenderingData.CameraY = mouseY / 100.0;
  TR.Render();
  
  text (frameRate, 5, 15);
  
  TotalTimeTaken += RenderingData.RenderTime;
  text ("average render time: " + (TotalTimeTaken / frameCount), 5, 30);
  
  if (mousePressed) {
    Map [mouseX/16/Zoom] [mouseY/16/Zoom] = 1; // works bc it's the same poiner as in RenderingData
  }
  
}










Loader_Class Loader = new Loader_Class();

public class Loader_Class {
  
  
  
  public PImage[] GetTextures() {
    File TexturesFolder = new File (dataPath("") + "\\Textures");
    String[] TextureNames = TexturesFolder.list();
    PImage[] Out = new PImage [TextureNames.length];
    for (int i = 0; i < Out.length; i ++) {
      String Name = TextureNames[i];
      Out[i] = loadImage (dataPath("") + "\\Textures\\" + Name);
    }
    return Out;
  }
  
  
  
}
