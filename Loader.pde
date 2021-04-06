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
