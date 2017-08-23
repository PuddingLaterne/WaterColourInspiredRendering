﻿using System.Collections;
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

    private Material mat;

    public void Awake()
    {
        mat = new Material(Shader);
        SetShaderValues();
    }


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (UpdateAtRuntime)
            SetShaderValues();

        Graphics.Blit(source, destination, mat);
    }

    private void SetShaderValues()
    {
        mat.SetTexture("_PaperTex", PaperTexture);
        mat.SetTexture("_PaperNormalTex", PaperNormal);
        mat.SetFloat("_Darkening", Darkening);
        mat.SetFloat("_MaxLuminance", MaxLuminance);
        mat.SetFloat("_Distortion", Distortion * 0.01f);
    }
}
