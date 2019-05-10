using UnityEngine;
 
[ExecuteInEditMode]
public class Edge : MonoBehaviour {
 
    public Material material;
    
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
    }
 
    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Graphics.Blit(src, dest, material);
        
    }
}