using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TextureCreator : EditorWindow
{
    private string textureName = "";
    private int size = 32;
    private int octaves = 4;
    private float persistence = 0.5f;


    [MenuItem("Window/3D Perlin Noise")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(TextureCreator));
    }

    public void OnGUI()
    {
        textureName = EditorGUILayout.TextField("Texture Name", textureName);
        size = EditorGUILayout.IntField("Texture Size", size);
        EditorGUILayout.Space();
        octaves = EditorGUILayout.IntField("Octaves", octaves);
        persistence = EditorGUILayout.Slider("Persistence", persistence, 0.0f, 1.0f);
       
        if(GUILayout.Button("Create Texture"))
        {
            Texture3D tex = Create3DNoiseTexture(size, octaves, persistence);
           
            if (tex == null) return;

            string path = "Assets/Textures/" + textureName + ".asset";

            Texture3D asset = AssetDatabase.LoadAssetAtPath(path, typeof(Texture3D)) as Texture3D;
            if(asset != null)
            {
                EditorUtility.CopySerialized(tex, asset);
            }
            else
            {
                AssetDatabase.CreateAsset(tex, "Assets/Textures/" + textureName + ".asset");
            }
        }
    }

    private Texture3D Create3DNoiseTexture(int size, int octaves, float persistence)
    {
        Texture3D tex = new Texture3D(size, size, size, TextureFormat.ARGB32, false);
        float[] samples = new float[size * size * size];
        int sampleIndex = 0;
        float min = 1.0f;
        float max = 0.0f;
        for (int z = 0; z < size; z++)
        {
            for (int y = 0; y < size; y++)
            {
                for (int x = 0; x < size; x++, sampleIndex++)
                {
                    float xCoord = x / (float)size;
                    float yCoord = y / (float)size;
                    float zCoord = z / (float)size;
                    float sample = OctavePerlin(xCoord, yCoord, zCoord, octaves, persistence);
                    if (sample < min) min = sample;
                    if (sample > max) max = sample;
                    samples[sampleIndex] = sample;
                }
            }
        }
        Remap(samples, min, max);
        tex.SetPixels(SamplesToColors(samples));
        tex.Apply();
        return tex;
    }

    private static float OctavePerlin(float x, float y, float z, int octaves, float persistence)
    {
        float total = 0.0f;
        float frequency = 2.0f;
        float amplitude = 1.0f;
        float max = 0.0f;

        for(int i = 0; i < octaves; i++)
        {
            total += Perlin3D(x * frequency, y * frequency, z * frequency) * amplitude;
            max += amplitude;

            amplitude *= persistence;
            frequency *= 2.0f;
        }
        return total / max;
    }

    private static float Perlin3D(float x, float y, float z)
    {
        float xy = Mathf.PerlinNoise(x, y);
        float yz = Mathf.PerlinNoise(y, z);
        float zx = Mathf.PerlinNoise(z, x);

        float yx = Mathf.PerlinNoise(y, x);
        float zy = Mathf.PerlinNoise(z, y);
        float xz = Mathf.PerlinNoise(x, z);

        return (xy + yz + zx + yx + zy + xz) / 6f;
    }

    private static void Remap(float[] samples, float min, float max)
    {
        for(int i = 0; i < samples.Length; i++)
        {
            samples[i] = Mathf.InverseLerp(min, max, samples[i]);
        }
    }

    private static Color[] SamplesToColors(float[] samples)
    {
        var colors = new Color[samples.Length];
        for(int i = 0; i < colors.Length; i++)
        {
            colors[i] = new Color(1.0f, 1.0f, 1.0f, 1.0f) * samples[i];
        }
        return colors;
    }
}
