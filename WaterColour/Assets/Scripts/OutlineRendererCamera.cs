using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineRendererCamera : MonoBehaviour
{
    public Shader OutlineShader;

    public RenderTexture Texture { get; private set; }
    private Camera cam;

    private void OnEnable()
    {
        AdjustCameraSettings();
        CreateRenderTexture();
        cam.targetTexture = Texture;
        cam.SetReplacementShader(OutlineShader, "Outline");
    }

    private void AdjustCameraSettings()
    {
        cam = GetComponent<Camera>();
        cam.CopyFrom(Camera.main);
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = new Color(0.5f, 0.5f, 0.5f, 1.0f);
    }

    private void CreateRenderTexture()
    {
        Texture = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
        Texture.Create();
    }

    private void OnDisable()
    {
        Texture.Release();
    }
}
