Shader "Watercolor/Watercolor"
{
	Properties
	{
		_Noise("Noise", 3D) = "white" {}
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

	}
	SubShader
	{
		Tags 
		{ 
			"RenderType" = "Opaque" 
			"LightMode" = "ForwardBase" 
		}
		LOD 100
		
		Pass
		{
			Name "BASE"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma shader_feature SPECULAR_ON
			#pragma multi_compile COLOR_TEXTURE COLOR_SIMPLE

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct vertexOutput
			{
			    float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 noiseUV : TEXCOORD1;
				SHADOW_COORDS(3)

				float3 n : TEXCOORD4;
				float3 v : TEXCOORD5;
				float3 l : TEXCOORD6;
			};

			sampler3D _Noise;
			fixed _BaseNoiseInfluence;
			fixed _AdditionalNoiseInfluence;

			sampler2D _ColorTex;

			fixed4 _Color;
			fixed _IntensityInfluence;

			fixed _HighlightThreshold;
			fixed _HighlightSoftness;
			fixed4 _HighlightTint;
			fixed _HighlightTintStrength;

			fixed _ShadowThreshold;
			fixed _ShadowSoftness;
			fixed4 _ShadowTint;
			fixed _ShadowTintStrength;

			fixed _Specularity;
			fixed4 _SpecularHighlightColor;
			fixed _SpecularThreshold;
			fixed _SpecularSoftness;

			fixed4 darken(fixed4 color, fixed factor)
			{
				return  color - (color - color * color) * factor;
			}

			float specular(float3 normal, float3 light, float3 view)
			{
				float3 reflected = reflect(-light, normal);
				return pow(max(0, dot(reflected, view)), _Specularity);
			}

			fixed4 changeDensity(fixed4 color, fixed density)
			{
				return color - (color - pow(color, 2.0))*(density - 1.0);
			}

			fixed map(fixed input, fixed threshold, fixed softness)
			{
				return lerp(0.0, 1.0, smoothstep(threshold - softness, threshold + softness, input));
			}

			vertexOutput vert (vertexInput i)
			{
				vertexOutput o;
                o.pos = UnityObjectToClipPos(i.vertex);

				o.uv = i.texcoord.xy;
				o.noiseUV = (i.vertex.xyz + 1.0) / 2.0;

				float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
				float3 n = normalize(UnityObjectToWorldNormal(i.normal));
				float3 l = normalize(_WorldSpaceLightPos0.xyz);
				float3 v = normalize(WorldSpaceViewDir(i.vertex));

				o.n = n;
				o.l = l;
				o.v = v;
				
				TRANSFER_SHADOW(o);

                return o;
			}
			
			half4 frag (vertexOutput i) : COLOR
			{
				half4 color;
				#ifdef COLOR_TEXTURE
				color = tex2D(_ColorTex, i.uv);
				#endif
				#ifdef COLOR_SIMPLE
				color = _Color;
				#endif

				float3 n = normalize(i.n);
				float3 v = normalize(i.v);
				float3 l = normalize(i.l);

				fixed noise = tex3D(_Noise, i.noiseUV);

				fixed shadow = SHADOW_ATTENUATION(i);

				fixed intensity = max(0.0, dot(n, l)) * shadow;
				intensity += ((noise * 2.0) - 1.0) * _BaseNoiseInfluence;
				fixed highlight = lerp(0.0, 0.5, smoothstep(_HighlightThreshold - _HighlightSoftness, _HighlightThreshold + _HighlightSoftness, intensity));
				intensity = lerp(0.0, 0.5, smoothstep(_ShadowThreshold - _ShadowSoftness, _ShadowThreshold + _ShadowSoftness, intensity));
				intensity += highlight;
				intensity += ((noise * 2.0) - 1.0) * _AdditionalNoiseInfluence;
				intensity = clamp(intensity, 0.0, 1.0);

				color = lerp(color, _HighlightTint, _HighlightTintStrength * max((intensity - 0.5), 0.0) * 2.0);
				color = lerp(_ShadowTint, color, 1.0 - _ShadowTintStrength * abs(min(intensity - 0.5, 0.0)) * 2.0);

				color = changeDensity(color, 1.0 + ((1.0 - intensity - 0.5) * 2.0 * _IntensityInfluence));

				#ifdef SPECULAR_ON
				fixed spec = specular(n, l, v) * shadow;
				spec = map(spec, _SpecularThreshold, _SpecularSoftness);
				color = lerp(color, _SpecularHighlightColor, spec);
				#endif

                return color;
			}
			ENDCG
		}


		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

	}

	Fallback "VertexLit"
	CustomEditor "WaterColorMaterialInspector"
}
