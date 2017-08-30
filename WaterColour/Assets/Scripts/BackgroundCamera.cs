using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackgroundCamera : MonoBehaviour
{
    public RenderTexture Target { get; private set; }

    private void OnEnable()
    {
        CreateRenderTexture();
        GetComponent<Camera>().targetTexture = Target;
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
