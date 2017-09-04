using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Utils;

public class WaterColorEffects : MonoBehaviour
{
    public Shader Shader;
    public Texture2D PaperTexture;
    [Range(0, 10)]
    public int Iterations = 4;
    [Range(0f, 1f)]
    public float Diffusion = 1.0f;
    [Range(0f, 0.005f)]
    public float Evaporation = 0.0001f;
    [Range(0, 1f)]
    public float MinPigmentDiffusionWetness = 0.4f;
    [Range(0, 1f)]
    public float MaxPigmentDiffusionWetnessDelta = 0.2f;

    public RenderTexture Texture { get { return fpp.GetReadTex(); } }

    private Material mat;
    private FboPingPong fpp;
    private PigmentEmitterCamera pigmentEmitterCam;
    private BackgroundCamera backgroundCam;

    void Start()
    {
        pigmentEmitterCam = GetComponentInChildren<PigmentEmitterCamera>();
        backgroundCam = GetComponentInChildren<BackgroundCamera>();

        fpp = new FboPingPong(Screen.width, Screen.height, FilterMode.Bilinear, TextureWrapMode.Mirror);
        mat = new Material(Shader);

        mat.SetTexture("_PaperTex", PaperTexture);

        Init();
    }

    void Update()
    {
        mat.SetTexture("_PigmentEmitters", pigmentEmitterCam.Target);

        mat.SetFloat("_Diffusion", Diffusion);
        mat.SetFloat("_MinPaperWetness", Diffusion);
        mat.SetFloat("_Evaporation", Evaporation);
        mat.SetFloat("_MinPigmentDiffusionWetness", MinPigmentDiffusionWetness);
        mat.SetFloat("_MaxPigmentDiffusionWetnessDelta", MaxPigmentDiffusionWetnessDelta);

        mat.SetTexture("_BackgroundTex", backgroundCam.Texture);
        Graphics.Blit(fpp.GetReadTex(), fpp.GetWriteTex(), mat, 3); //combine
        fpp.Swap();

        for (int i = 0; i < Iterations; i++)
        {
            Graphics.Blit(fpp.GetReadTex(), fpp.GetWriteTex(), mat, 1); // update
            fpp.Swap();
        }
    }

    void Init()
    {
        Graphics.Blit(fpp.GetReadTex(), fpp.GetWriteTex(), mat, 0); // init
        fpp.Swap();
    }
}
