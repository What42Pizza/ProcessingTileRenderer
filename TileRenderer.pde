public static class RenderingData {
  
  // changes per frame
  static int Zoom;
  static float CameraX;
  static float CameraY;
  static int RenderTime;
  
  // mostly final
  static int[][] TileMap;
  static PImage[] TileSet;
  static int TextureSize;
  static int ScreenXStart;
  static int ScreenYStart;
  static int ScreenWidth;
  static int ScreenHeight;
  static int NumOfThreads;
  static int[] Pixels;
  static int PixelsWidth;
  
  // threading (don't change manually)
  static int CurrThreadID;
  static volatile int FinishedThreads;
  
}










public class TileRenderer {
  
  
  
  public TileRenderer() {}
  
  public TileRenderer (int[][] TileMap, PImage[] TileSet, int TextureSize, int NumOfThreads) {
    RenderingData.TileMap = TileMap;
    RenderingData.TileSet = TileSet;
    RenderingData.TextureSize = TextureSize;
    RenderingData.NumOfThreads = NumOfThreads;
  }
  
  public TileRenderer (int[][] TileMap, PImage[] TileSet, int TextureSize, int NumOfThreads, int PixelsWidth, int ScreenXStart, int ScreenYStart, int ScreenWidth, int ScreenHeight) {
    RenderingData.TileMap = TileMap;
    RenderingData.TileSet = TileSet;
    RenderingData.TextureSize = TextureSize;
    RenderingData.NumOfThreads = NumOfThreads;
    RenderingData.PixelsWidth = PixelsWidth;
    RenderingData.ScreenXStart = ScreenXStart;
    RenderingData.ScreenYStart = ScreenYStart;
    RenderingData.ScreenWidth = ScreenWidth;
    RenderingData.ScreenHeight = ScreenHeight;
  }
  
  
  
  
  
  public void Render (int[] Pixels) {
    int StartMillis = millis();
    
    // set rendering data
    RenderingData.Pixels = Pixels;
    RenderingData.FinishedThreads = 0;
    RenderingData.CurrThreadID = 0;
    
    // launch threads
    for (int i = 0; i < RenderingData.NumOfThreads; i ++) {
      thread ("Threaded_RenderTiles");
    }
    
    // wait for threads to finish
    while (RenderingData.FinishedThreads < RenderingData.NumOfThreads) DoBusyWork();
    
    // calc time taken
    RenderingData.RenderTime = millis() - StartMillis;
    
  }
  
  
  
  public void Render () {
    loadPixels();
    //pixels = new color [width * height];
    Render (pixels);
    updatePixels();
  }
  
  
  
}





void Threaded_RenderTiles() {
  
  int ThreadID = GetAndIncThreadID();
  
  int[][] TileMap = RenderingData.TileMap;
  PImage[] TileSet = RenderingData.TileSet;
  int TextureSize = RenderingData.TextureSize;
  int TextureWidth = 1 << TextureSize;
  int NumOfThreads = RenderingData.NumOfThreads;
  int[] Pixels = RenderingData.Pixels;
  int PixelsWidth = RenderingData.PixelsWidth;
  
  int ScreenXStart = RenderingData.ScreenXStart;
  int ScreenYStart = RenderingData.ScreenYStart;
  int ScreenWidth = RenderingData.ScreenWidth;
  int ScreenHeight = RenderingData.ScreenHeight;
  
  int Zoom = RenderingData.Zoom;
  float CameraX = RenderingData.CameraX;
  float CameraY = RenderingData.CameraY;
  
  float TileStepX = 1.0 / TextureWidth / Zoom;
  float TileStepY = TileStepX * NumOfThreads;
  
  
  
  // Tile goes from 0 - 1 and Texture goes from 0 - TextureWidth
  
  // get vertical vars
  int TileY = ((int) CameraY) + ((int) (TileStepX * ThreadID));
  float SubTileY = (CameraY % 1) + ((TileStepX * ThreadID) % 1);
  float CamTileY = TextureWidth * (CameraY % 1);
  int TextureY = (((int) CamTileY) + (ThreadID / Zoom)) % TextureWidth;
  int TextureBitAnd = (1 << TextureSize) - 1;
  int SubTextureY = ((int) ((CamTileY % 1) * Zoom)) + (ThreadID % Zoom);
  
  // from top to bottom
  for (int YPos = ThreadID; YPos < ScreenHeight; YPos += NumOfThreads) {
    
    // get horizontal vars
    int TileX = (int) CameraX;
    float SubTileX = CameraX % 1;
    float CamTileX = TextureWidth * SubTileX;
    int TextureX = (int) CamTileX;
    int SubTextureX = (int) ((CamTileX % 1) * Zoom);
    PImage CurrentTexture = TileSet [TileMap [TileX] [TileY]];
    int TextureIndex = TextureX + (TextureY << TextureSize);
    int IndexBitAnd = (1 << (TextureSize * 2)) - 1; // TextureWidth^2 - 1
    color CurrColor = CurrentTexture.pixels[TextureIndex];
    int Index = ScreenXStart + (ScreenYStart + YPos) * PixelsWidth;
    
    // from left to right
    for (int XPos = 0; XPos < ScreenWidth; XPos ++) {
      
      // fill pixel w/ cached color
      Pixels[Index] = CurrColor;
      Index ++;
      
      // move within texture
      SubTextureX ++;
      if (SubTextureX == Zoom) {
        TextureX ++;
        TextureX &= TextureBitAnd;
        SubTextureX = 0;
        TextureIndex = (TextureIndex + 1) & IndexBitAnd;
        CurrColor = CurrentTexture.pixels[TextureIndex];
      }
      
      // move within map
      SubTileX += TileStepX;
      if (SubTileX >= 1) {
        TileX += (int) SubTileX;
        SubTileX %= 1;
        CurrentTexture = TileSet [TileMap [TileX] [TileY]];
        TextureIndex = TextureX + (TextureY << TextureSize);
        CurrColor = CurrentTexture.pixels[TextureIndex];
      }
      
    }
    
    // move within texture
    SubTextureY += NumOfThreads;
    if (SubTextureY >= Zoom) {
      TextureY += SubTextureY / Zoom;
      TextureY &= TextureBitAnd;
      SubTextureY %= Zoom;
    }
    
    // move within map
    SubTileY += TileStepY;
    if (SubTileY >= 1) {
      TileY += (int) SubTileY;
      SubTileY %= 1;
    }
    
  }
  
  // finish
  IncFinishedThreads();
  
}










synchronized int GetAndIncThreadID() {
  RenderingData.CurrThreadID ++;
  return RenderingData.CurrThreadID - 1;
}

synchronized void IncFinishedThreads() {
  RenderingData.FinishedThreads ++;
}

void DoBusyWork() {
  long EndNano = System.nanoTime() + 1000; // wait 1 microsecond
  while (System.nanoTime() < EndNano) {
    byte Void = -128;
    while (Void < 127) Void ++;
  }
}
