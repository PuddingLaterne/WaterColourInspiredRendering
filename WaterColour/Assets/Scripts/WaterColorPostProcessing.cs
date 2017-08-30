using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterColorPostProcessing : MonoBehaviour
{
    public bool UpdateAtRuntime = false;

    public Shader Shader;
    [Header("Paper Effect")]
    public Texture PaperTexture;
    public Texture PaperNormal;
    [Range(0, 1f)]
    public float Darkening = 0.5f;
    [Range(0, 1f)]
    public float MaxLuminance = 0.8f;
    [Range(0, 1f)]
    public float Distortion = 0.5f;
    public bool BlurOutlines = true;
    public bool BlurBackground = true;

    private Material mat;
    private OutlineRendererCamera outlineRenderer;
    private BackgroundCamera background;

    public void Awake()
    {
        mat = new Material(Shader);
        outlineRenderer = GetComponentInChildren<OutlineRendererCamera>();
        background = GetComponentInChildren<BackgroundCamera>();
        SetShaderValues();
    }


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (UpdateAtRuntime)
            SetShaderValues();

        mat.SetTexture("_OutlineTex", outlineRenderer.Target);
        mat.SetTexture("_BackgroundTex", background.Target);
        Graphics.Blit(source, destination, mat);
    }

    private void SetShaderValues()
    {
        SetKeyword(BlurOutlines, "OUTLINE_BLUR_ON", "OUTLINE_BLUR_OFF");
        SetKeyword(BlurBackground, "BG_BLUR_ON", "BG_BLUR_OFF");
        mat.SetTexture("_PaperTex", PaperTexture);
        mat.SetTexture("_PaperNormalTex", PaperNormal);
        mat.SetFloat("_Darkening", Darkening);
        mat.SetFloat("_MaxLuminance", MaxLuminance);
        mat.SetFloat("_Distortion", Distortion * 0.01f);
    }

    private void SetKeyword(bool isActive, string keywordOn, string keywordOff)
    {
        if (isActive)
        {
            mat.EnableKeyword(keywordOn);
            mat.DisableKeyword(keywordOff);
        }
        else
        {
            mat.EnableKeyword(keywordOff);
            mat.DisableKeyword(keywordOn);
        }
    }
}
