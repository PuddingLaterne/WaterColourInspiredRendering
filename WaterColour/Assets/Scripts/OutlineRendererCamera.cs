using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineRendererCamera : MonoBehaviour
{
    public Shader OutlineShader;

    public RenderTexture Target { get; private set; }
    private Camera cam;

    private void OnEnable()
    {
        AdjustCameraSettings();
        CreateRenderTexture();
        cam.targetTexture = Target;
        cam.SetReplacementShader(OutlineShader, "Outline");
    }

    private void AdjustCameraSettings()
    {
        cam = GetComponent<Camera>();
        cam.CopyFrom(Camera.main);
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = Color.white;
    }

    private void CreateRenderTexture()
    {
        Target = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
        Target.Create();
    }

    private void OnDisable()
    {
        Target.Release();
    }
}
