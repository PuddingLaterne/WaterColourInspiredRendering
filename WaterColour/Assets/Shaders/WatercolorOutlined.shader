Shader "Watercolor/WatercolorOutlined"
{
	Properties
	{
		_Noise("Noise", 3D) = "white" {}
		_NoiseScale("Noise Scaling", float) = 1.0
		_BaseNoiseInfluence("Base Influence", Range(0, 1.0)) = 0.5
		_AdditionalNoiseInfluence("Additional Influence", Range(0, 1.0)) = 0.5

		_ColorTex("Color Texture", 2D) = "grey" {}
		_Color("Base Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_IntensityInfluence("Intensity Influence", Range(0.0, 1.0)) = 0.5

		_HighlightThreshold("Highlight Threshold", Range(0, 1.0)) = 0.8
		_HighlightSoftness("Highlight Softness", Range(0, 1.0)) = 0.1
		_HighlightTint("Highlight Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_HighlightTintStrength("Highlight Tint Strength", Range(0, 1.0)) = 0.0

		_ShadowThreshold("Shadow Threshold", Range(0, 1.0)) = 0.4
		_ShadowSoftness("Shadow Softness", Range(0, 1.0)) = 0.1
		_ShadowTint("Shadow Tint", Color) = (0.0, 0.0, 0.0, 1.0)
		_ShadowTintStrength("Shadow Tint Strength", Range(0, 1.0)) = 0.0

		_SpecularHighlightColor("Specular Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specularity("Specularity", float) = 8.0
		_SpecularThreshold("Specular Threshold", Range(0, 1.0)) = 0.8
		_SpecularSoftness("Specular Softness", Range(0, 1.0)) = 0.1

		_FadeStrength("Fade Strength", Range(0, 1.0)) = 1.0
		_FadeColor("Fade Color", Color) = (0.5, 0.5, 0.5, 1.0)

		_MinOutlineThickness("Minimum Outline Thickness", Range(0.0, 0.1)) = 0.05
		_MaxOutlineThickness("Maximum Outline Thickness", Range(0.0, 0.1)) = 0.1
		_OutlineOpacity("Outline Opacity", Range(0.0, 1.0)) = 0.5
		_OutlinePos("Outline Position", Range(0.0, 1.0)) = 0.5
		_OuterLineBrightness("Outer Line Brightness", Range(0.0, 1.0)) = 1.0
		_InnerLineBrightness("Inner Line Brightness", Range(0.0, 1.0)) = 0.0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"LightMode" = "ForwardBase"
			"Outline" = "Default"
		}
		LOD 100

		Usepass "Watercolor/Watercolor/BASE"
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

	}

	Fallback "VertexLit"
	CustomEditor "WaterColorMaterialInspector"
}
