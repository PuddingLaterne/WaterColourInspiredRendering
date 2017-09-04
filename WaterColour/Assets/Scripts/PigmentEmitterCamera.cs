using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PigmentEmitterCamera : MonoBehaviour
{
    public RenderTexture Target { get; private set; }
    private Camera cam;

    private void OnEnable()
    {
        cam = GetComponent<Camera>();
        CreateRenderTexture();
        cam.targetTexture = Target;
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
