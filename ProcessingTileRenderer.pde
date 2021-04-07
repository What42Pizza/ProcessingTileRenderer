// Started 04/05/21




// Settings

boolean UseFullScreen = true;

int Width = 512;
int Height = 512;

int Zoom = 2;

int NumOfThreads = 5;





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





void draw() {
  
  RenderingData.Zoom = Zoom;
  TR.Render();
  
  if (mousePressed) {
    RenderingData.Map [mouseX/16/Zoom] [mouseY/16/Zoom] = 1;
  }
}
