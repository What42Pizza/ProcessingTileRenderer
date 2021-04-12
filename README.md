# Processing Tile Renderer

This is a multithreaded tile renderer designed to work with Processing 3. You feed it a tile map and tile set, and it does all the rendering for you. There is a static class (RenderingData) you can write to that holds all the rendering data. If you want to use this, the file TileRenderer.pde is the only one you need to use.

<br />

On my laptop (2.3GHz dual-core), it can render a full 1080p screen in an average of anywhere between 10 - 20 ms, though it only runs at around 30 fps because of loadPixels() and updatePixels().

<br />

If you have any problems or questions, feel free to contact me on discord: What42Pizza#0283

<br />
<br />
<br />
<br />
<br />

## RenderingData variables:

<br />

### Changes per frame:

- int Zoom   -  how many pixels (squared) should be rendered to Pixels[] for each pixel of the texture (a Zoom of 3 means the textures are rendered 3 (actually 9) times larger)
- float CameraX   -  the x position of the left side of the camera (for example, a CameraX of 1.5 means starting halfway through the second tile (first in 0 indexing))
- float CameraY   - the y position of the top side of the camera

<br />

### Mostly final:

- int [] [] TileMap   -  holds the texture index of each tile
- PImage[] TileSet   -  holds all the textures
- int TextureSize   -  the size of the textures (IMPORTANT NOTE: THIS IS THE LOG BASE 2 OF THE WIDTH OF THE TEXTURE (a texture width of 16 corresponds to a TextureSize of 4))
- int ScreenXStart   -  where to start rendering to Pixels[] in the x direction
- int ScreenYStart   -  where to start rendering to Pixels[] in the y direction
- int ScreenWidth   -  how wide the image rendered to Pixels[] should be
- int ScreenHeight   -  how tall the image rendered to Pixels[] should be
- int NumOfThreads   -  the number of threads used to render the image
- int[] Pixels   -  the array to be rendered to
- int PixelsWidth   -  the width for Pixels[]

<br />
<br />
<br />
<br />
<br />

## TileRenderer functions:

- void Render()   -  this just renders to the screen
- void Render (int[] Pixels)   -  this renders to the given array

<br />
<br />
<br />
<br />
<br />

## TileRenderer constructors:

- TileRenderer()
- TileRenderer (int [] [] TileMap,  PImage[] TileSet,  int TextureSize,  int NumOfThreads)
- TileRenderer (int [] [] TileMap,  PImage[] TileSet,  int TextureSize,  int NumOfThreads,  int PixelsWidth,  int ScreenXStart,  int ScreenYStart,  int ScreenWidth,  int ScreenHeight)

<br />
<br />
<br />
<br />
<br />

Readme last updated 04/12/21