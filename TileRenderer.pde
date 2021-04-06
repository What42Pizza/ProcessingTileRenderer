public class TileRenderer {
  
  
  
  public TileRenderer() {}
  
  public TileRenderer (int[][] Map, PImage[] Textures, int TextureSize, int NumOfThreads) {
    RenderingData.Map = Map;
    RenderingData.Textures = Textures;
    RenderingData.TextureSize = TextureSize;
    RenderingData.NumOfThreads = NumOfThreads;
  }
  
  
  
  public void Render (int[] Pixels, int PixelsWidth, int XStart, int YStart, int Width, int Height, int Zoom) {
    RenderingData.Pixels = Pixels;
    RenderingData.PixelsWidth = PixelsWidth;
    RenderingData.XStart = XStart;
    RenderingData.YStart = YStart;
    RenderingData.Width  = Width ;
    RenderingData.Height = Height;
    RenderingData.Zoom   = Zoom  ;
    Render();
  }
  
  
  
  public void Render (int XStart, int YStart, int Width, int Height, int Zoom) {
    loadPixels();
    RenderingData.Pixels = pixels;
    RenderingData.PixelsWidth = width;
    RenderingData.XStart = XStart;
    RenderingData.YStart = YStart;
    RenderingData.Width  = Width ;
    RenderingData.Height = Height;
    RenderingData.Zoom   = Zoom  ;
    Render();
    //pixels = RenderingData.Pixels // This already has the same pointer
    updatePixels();
  }
  
  
  
  
  
  public void Render() {
    RenderingData.FinishedThreads = 0;
    //LaunchThreads();
    Threaded_RenderTiles();
    while (RenderingData.FinishedThreads < RenderingData.NumOfThreads) DoBusyWork();
  }
  
  
  
  public void LaunchThreads() {
    RenderingData.CurrThreadID = 0;
    for (int i = 0; i < RenderingData.NumOfThreads; i ++) {
      thread ("Threaded_RenderTiles");
    }
  }
  
  
  
}





public static class RenderingData {
  
  // mostly final
  static int[][] Map;
  static PImage[] Textures;
  static int TextureSize;
  static int NumOfThreads;
  static int[] Pixels;
  static int PixelsWidth;
  
  // changes per frame
  static int Zoom;
  static int XStart;
  static int YStart;
  static int Width;
  static int Height;
  
  // threading
  static int CurrThreadID;
  static volatile int FinishedThreads;
  
}





void Threaded_RenderTiles() {
  
  int ThreadID = GetAndIncThreadID();
  
  int[][] Map = RenderingData.Map;
  PImage[] Textures = RenderingData.Textures;
  int TextureSize = RenderingData.TextureSize;
  int TextureWidth = 1 << TextureSize;
  int NumOfThreads = RenderingData.NumOfThreads;
  int[] Pixels = RenderingData.Pixels;
  int PixelsWidth = RenderingData.PixelsWidth;
  
  int Zoom = RenderingData.Zoom;
  int XStart = RenderingData.XStart;
  int YStart = RenderingData.YStart;
  int Width = RenderingData.Width;
  int Height = RenderingData.Height;
  
  float TileStepY = 1.0 / TextureWidth / Zoom;
  float TileStepX = TileStepY * NumOfThreads;
  
  
  
  int TileY = 0;
  float SubTileY = 0;
  int PixelY = 0;
  int SubPixelY = 0;
  
  // from top to bottom
  for (int YPos = 0; YPos < Height; YPos ++) {
    
    // get vars
    int TileX = 0;
    float SubTileX = 0;
    int PixelX = 0;
    int SubPixelX = 0;
    int CurrentTile = Map [TileX] [TileY];
    color CurrColor = Textures[CurrentTile].pixels[PixelX + (PixelY << TextureSize)];
    int Index = XStart + (YStart + YPos) * PixelsWidth;
    
    // from left to right
    for (int XPos = ThreadID; XPos < Width; XPos += NumOfThreads) {
      
      // fill pixel with cached color
      Pixels[Index] = CurrColor;
      Index += NumOfThreads;
      
      // check if pixel has changed
      SubPixelX += NumOfThreads;
      if (SubPixelX == Zoom) {
        PixelX += SubPixelX / Zoom;
        PixelX %= TextureWidth;
        SubPixelX = 0;
        CurrColor = Textures[CurrentTile].pixels[PixelX + (PixelY << TextureSize)];
      }
      
      // check if tile has changed
      SubTileX += TileStepX;
      if (SubTileX >= 1) {
        TileX += (int) SubTileX;
        SubTileX %= 1;
      }
      
    }
    
    // check if pixel has changed
    SubPixelY ++;
    if (SubPixelY == Zoom) {
      SubPixelY = 0;
      PixelY ++;
      PixelY %= TextureWidth;
    }
    
    // check if tile has changed
    SubTileY += TileStepY;
    if (SubTileY >= 1) {
      TileY += (int) SubTileY;
      SubTileY %= 1;
    }
    
  }
  
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
