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

    private Material mat;
    private OutlineRendererCamera outlineRenderer;

    public void Awake()
    {
        mat = new Material(Shader);
        outlineRenderer = FindObjectOfType<OutlineRendererCamera>();
        SetShaderValues();
    }


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (UpdateAtRuntime)
            SetShaderValues();

        mat.SetTexture("_OutlineTex", outlineRenderer.Target);
        Graphics.Blit(source, destination, mat);
    }

    private void SetShaderValues()
    {
        if(BlurOutlines)
        {
            mat.EnableKeyword("OUTLINE_BLUR_ON");
            mat.DisableKeyword("OUTLINE_BLUR_OFF");
        }
        else
        {
            mat.EnableKeyword("OUTLINE_BLUR_OFF");
            mat.DisableKeyword("OUTLINE_BLUR_ON");
        }
        mat.SetTexture("_PaperTex", PaperTexture);
        mat.SetTexture("_PaperNormalTex", PaperNormal);
        mat.SetFloat("_Darkening", Darkening);
        mat.SetFloat("_MaxLuminance", MaxLuminance);
        mat.SetFloat("_Distortion", Distortion * 0.01f);
    }
}
