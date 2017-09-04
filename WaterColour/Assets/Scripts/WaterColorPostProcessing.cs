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

    [Header("Brightness")]
    public Vector2 BrightnessOrigin = new Vector2(0.5f, 1.2f);
    public float BrighteningFadeStart = 0.2f;
    public float BrighteningFadeEnd = 0.8f;
    public float BrighteningStrength = 0.5f;

    [Header("Render Layers")]
    public bool BlurOutlines = true;
    public bool BlurBackground = true;
    [Range(0, 1f)]
    public float EffectVisibility = 0.5f;

    private Material mat;
    private OutlineRendererCamera outlineLayer;
    private WaterColorEffects effectLayer;
    private BackgroundCamera backgroundLayer;

    public void Awake()
    {
        mat = new Material(Shader);
        effectLayer = GetComponent<WaterColorEffects>();
        outlineLayer = GetComponentInChildren<OutlineRendererCamera>();
        backgroundLayer = GetComponentInChildren<BackgroundCamera>();
        SetShaderValues();
    }


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (UpdateAtRuntime)
            SetShaderValues();

        mat.SetTexture("_OutlineTex", outlineLayer.Texture);
        mat.SetTexture("_BackgroundTex", backgroundLayer.Texture);
        mat.SetTexture("_EffectTex", effectLayer.Texture);
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

        mat.SetVector("_BrightnessOrigin", BrightnessOrigin);
        mat.SetFloat("_BrighteningFadeStart", BrighteningFadeStart);
        mat.SetFloat("_BrighteningFadeEnd", BrighteningFadeEnd);
        mat.SetFloat("_BrighteningStrength", BrighteningStrength);

        mat.SetFloat("_EffectVisibility", EffectVisibility);
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
