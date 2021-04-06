// Started 04/05/21




// Settings

int NumOfThreads = 1;

int Width = 1024;
int Height = 1024;

int TextureSize = 4;





// Vars

int[][] Map;
PImage[] Textures;

int Zoom = 8;

TileRenderer TR = new TileRenderer (Map, Textures, TextureSize, NumOfThreads); // Having Map and Textures in here is kinda useless sense they're null





void setup() {
  Textures = Loader.GetTextures();
  RenderingData.Textures = Textures;
  Map = new int [Width / TextureSize] [Height / TextureSize];
  RenderingData.Map = Map;
  RenderingData.XStart = 0;
  RenderingData.YStart = 0;
  RenderingData.Width = width;
  RenderingData.Height = height;
  RenderingData.PixelsWidth = width;
}

void settings() {
  size (Width, Height);
}





void draw() {
  RenderingData.Zoom = Zoom;
  loadPixels();
  RenderingData.Pixels = pixels;
  TR.Render();
  updatePixels();
  if (mousePressed) {
    RenderingData.Map [mouseX/8] [mouseY/8] = 1;
  }
  println (RenderingData.Map [mouseX/8] [mouseY/8]);
}
