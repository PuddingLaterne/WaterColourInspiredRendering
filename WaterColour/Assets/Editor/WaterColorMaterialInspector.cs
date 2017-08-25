using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

public class WaterColorMaterialInspector : MaterialEditor
{
    private Material mat;

    private bool Toggle(string toggleKeyword, string label)
    {
        EditorGUI.BeginChangeCheck();
        bool toggle = mat.IsKeywordEnabled(toggleKeyword);
        toggle = EditorGUILayout.Toggle(label, toggle);
        if (EditorGUI.EndChangeCheck())
        {
            if (toggle)
            {
                mat.EnableKeyword(toggleKeyword);
            }
            else
            {
                mat.DisableKeyword(toggleKeyword);
            }
            EditorUtility.SetDirty(mat);
        }
        return toggle;
    }

    private bool Toggle(string toggleKeywordOn, string toggleKeywordOff, string label)
    {
        EditorGUI.BeginChangeCheck();
        bool toggle = mat.IsKeywordEnabled(toggleKeywordOn);
        toggle = EditorGUILayout.Toggle(label, toggle);
        if (EditorGUI.EndChangeCheck())
        {
            if (toggle)
            {
                mat.EnableKeyword(toggleKeywordOn);
                mat.DisableKeyword(toggleKeywordOff);
            }
            else
            {
                mat.DisableKeyword(toggleKeywordOn);
                mat.EnableKeyword(toggleKeywordOff);
            }
            EditorUtility.SetDirty(mat);
        }
        return toggle;
    }

    public override void OnInspectorGUI()
    {
        if (!isVisible) return;

        mat = target as Material;
        Material[] matArray = new Material[] { mat };

        GUIStyle headerStyle = new GUIStyle();
        headerStyle.fontStyle = FontStyle.Bold;

        EditorGUILayout.LabelField("Noise", headerStyle);
        ShaderProperty(GetMaterialProperty(matArray, "_Noise"), "Texture");
        ShaderProperty(GetMaterialProperty(matArray, "_BaseNoiseInfluence"), "Base Influence");
        ShaderProperty(GetMaterialProperty(matArray, "_AdditionalNoiseInfluence"), "Additional Influence");

        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Base Color", headerStyle);
        if(Toggle("COLOR_TEXTURE", "COLOR_SIMPLE", "Use Texture"))
        {
            ShaderProperty(GetMaterialProperty(matArray, "_ColorTex"), "Texture");
        }
        else
        {
            ShaderProperty(GetMaterialProperty(matArray, "_Color"), "Color");
        }
        ShaderProperty(GetMaterialProperty(matArray, "_IntensityInfluence"), "Intensity Influence");

        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Highlights", headerStyle);
        ShaderProperty(GetMaterialProperty(matArray, "_HighlightThreshold"), "Threshold");
        ShaderProperty(GetMaterialProperty(matArray, "_HighlightSoftness"), "Softness");
        ShaderProperty(GetMaterialProperty(matArray, "_HighlightTint"), "Tint");
        ShaderProperty(GetMaterialProperty(matArray, "_HighlightTintStrength"), "Tint Strength");

        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Shadows", headerStyle);
        ShaderProperty(GetMaterialProperty(matArray, "_ShadowThreshold"), "Threshold");
        ShaderProperty(GetMaterialProperty(matArray, "_ShadowSoftness"), "Softness");
        ShaderProperty(GetMaterialProperty(matArray, "_ShadowTint"), "Tint");
        ShaderProperty(GetMaterialProperty(matArray, "_ShadowTintStrength"), "Tint Strength");

        EditorGUILayout.Separator();
        EditorGUILayout.LabelField("Specular Highlights", headerStyle);
        if (Toggle("SPECULAR_ON", "Enabled"))
        {
            ShaderProperty(GetMaterialProperty(matArray, "_Specularity"), "Specularity Coefficient");
            ShaderProperty(GetMaterialProperty(matArray, "_SpecularHighlightColor"), "Color");
            ShaderProperty(GetMaterialProperty(matArray, "_SpecularThreshold"), "Threshold");
            ShaderProperty(GetMaterialProperty(matArray, "_SpecularSoftness"), "Softness");
        }

        if (mat.HasProperty("_OutlineOpacity"))
        {
            EditorGUILayout.Separator();
            EditorGUILayout.LabelField("Outline", headerStyle);
            ShaderProperty(GetMaterialProperty(matArray, "_MinOutlineThickness"), "Minimum Thickness");
            ShaderProperty(GetMaterialProperty(matArray, "_MaxOutlineThickness"), "Maximum Thickness");
            ShaderProperty(GetMaterialProperty(matArray, "_OutlineOpacity"), "Opacity");
            ShaderProperty(GetMaterialProperty(matArray, "_OutlinePos"), "Position");
        }
    }
}
