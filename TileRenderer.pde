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
  
  // threading (don't change manually)
  static int CurrThreadID;
  static volatile int FinishedThreads;
  
}










public class TileRenderer {
  
  
  
  public TileRenderer() {}
  
  public TileRenderer (int[][] Map, PImage[] Textures, int TextureSize, int NumOfThreads) {
    RenderingData.Map = Map;
    RenderingData.Textures = Textures;
    RenderingData.TextureSize = TextureSize;
    RenderingData.NumOfThreads = NumOfThreads;
  }
  
  public TileRenderer (int[][] Map, PImage[] Textures, int TextureSize, int NumOfThreads, int PixelsWidth, int XStart, int YStart, int Width, int Height) {
    RenderingData.Map = Map;
    RenderingData.Textures = Textures;
    RenderingData.TextureSize = TextureSize;
    RenderingData.NumOfThreads = NumOfThreads;
    RenderingData.PixelsWidth = PixelsWidth;
    RenderingData.XStart = XStart;
    RenderingData.YStart = YStart;
    RenderingData.Width = Width;
    RenderingData.Height = Height;
  }
  
  
  
  
  
  public void Render (int[] Pixels) {
    
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
    
  }
  
  
  
  public void Render () {
    loadPixels();
    Render (pixels);
    updatePixels();
  }
  
  
  
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
  
  float TileStepX = 1.0 / TextureWidth / Zoom;
  float TileStepY = TileStepX * NumOfThreads;
  
  
  
  // Tile goes from 0 - 1 and Texture goes from 0 - TextureWidth
  
  // get vertical vars
  int TileY = (int) (TileStepX * ThreadID);
  float SubTileY = (TileStepX * ThreadID) % 1;
  int TextureY = ThreadID / Zoom;
  int SubTextureY = ThreadID % Zoom;
  
  // from top to bottom
  for (int YPos = ThreadID; YPos < Height; YPos += NumOfThreads) {
    
    // get horizontal vars
    int TileX = 0;
    float SubTileX = 0;
    int TextureX = 0;
    int SubTextureX = 0;
    PImage CurrentTexture = Textures [Map [TileX] [TileY]];
    color CurrColor = CurrentTexture.pixels[TextureX + (TextureY << TextureSize)];
    int Index = XStart + (YStart + YPos) * PixelsWidth;
    
    // from left to right
    for (int XPos = 0; XPos < Width; XPos ++) {
      
      // fill pixel w/ cached color
      Pixels[Index] = CurrColor;
      Index ++;
      
      // move within texture
      SubTextureX ++;
      if (SubTextureX == Zoom) {
        TextureX ++;
        TextureX %= TextureWidth;
        SubTextureX = 0;
        CurrColor = CurrentTexture.pixels[TextureX + (TextureY << TextureSize)];
      }
      
      // move within map
      SubTileX += TileStepX;
      if (SubTileX >= 1) {
        TileX += (int) SubTileX;
        SubTileX %= 1;
        CurrentTexture = Textures [Map [TileX] [TileY]];
        CurrColor = CurrentTexture.pixels[TextureX + (TextureY << TextureSize)];
      }
      
    }
    
    // move within texture
    SubTextureY += NumOfThreads;
    if (SubTextureY >= Zoom) {
      TextureY += SubTextureY / Zoom;
      TextureY %= TextureWidth;
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





// this has each thread jumps columns, the new one jumps rows
void Threaded_RenderTiles_OLD() { // works with 1-2 threads (I think), but not any more
  
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
  
  
  
  // get vertical vars
  int TileY = 0;
  float SubTileY = 0;
  int TextureY = 0;
  int SubTextureY = 0;
  
  // from top to bottom
  for (int YPos = 0; YPos < Height; YPos ++) {
    
    // get horizontal vars
    int TileX = (int) (TileStepX * ThreadID);
    float SubTileX = (TileStepX * ThreadID) % 1;
    int TextureX = ThreadID / Zoom;
    int SubTextureX = ThreadID % Zoom;
    int CurrentTile = Map [TileX] [TileY];
    color CurrColor = Textures[CurrentTile].pixels[TextureX + (TextureY << TextureSize)];
    int Index = XStart + (YStart + YPos) * PixelsWidth + ThreadID;
    
    // from left to right
    for (int XPos = ThreadID; XPos < Width; XPos += NumOfThreads) {
      
      // fill pixel with cached color
      Pixels[Index] = CurrColor;
      Index += NumOfThreads;
      
      // check if pixel has changed
      SubTextureX += NumOfThreads;
      if (SubTextureX >= Zoom) {
        TextureX += SubTextureX / Zoom;
        TextureX %= TextureWidth;
        SubTextureX %= Zoom;
        CurrColor = Textures[CurrentTile].pixels[TextureX + (TextureY << TextureSize)];
      }
      
      // check if tile has changed
      SubTileX += TileStepX;
      if (SubTileX >= 1) {
        TileX += (int) SubTileX;
        SubTileX %= 1;
        CurrentTile = Map [TileX] [TileY];
        //CurrColor = Textures[CurrentTile].pixels[TextureX + (TextureY << TextureSize)]; // not sure if this is needed, doesn't really help?
      }
      
    }
    
    // check if pixel has changed
    SubTextureY ++;
    if (SubTextureY >= Zoom) {
      SubTextureY = 0;
      TextureY ++;
      TextureY %= TextureWidth;
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
