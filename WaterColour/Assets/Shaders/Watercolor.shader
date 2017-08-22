// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Watercolor"
{
	Properties
	{
		_Noise ("Noise", 3D) = "white" {}
		_HighlightColor("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_BaseColor("Base Color", Color) = (0.6, 0.6, 0.6, 1.0)
		_ShadowColor("Shadow Color", Color) = (0.1, 0.1, 0.1, 1.0)
		_HighlightThreshold("Highlight Threshold", Range(0, 1.0)) = 0.8
		_HighlightSoftness("Highlight Softness", Range(0, 1.0)) = 0.1
		_ShadowThreshold("Shadow Threshold", Range(0, 1.0)) = 0.4
		_ShadowSoftness("Shadow Softness", Range(0, 1.0)) = 0.1
		_EdgeDarkening("Edge Darkening", Range(0, 1.0)) = 0.5
		_NoiseDarkening("Noise Darkening", Range(0, 5.0)) = 1.0
		_MinLineThickness("Min Line Thickness", Range(0, 0.05)) = 0.0
		_MaxLineThickness("Max Line Thickness", Range(0, 0.05)) = 0.05
		_LineColorLight("Line Color Light", Color) = (1.0, 1.0, 1.0, 0.5)
		_LineColorDark("Line Color Dark", Color) = (0.0, 0.0, 0.0, 0.5)
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType" = "Opaque" 
			"LightMode" = "ForwardBase" 
			"Replace" = "Full"
		}
		LOD 100
		
		Pass
		{
			Tags{"Replace" = "Full"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

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
				fixed intensity : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			sampler3D _Noise;

			fixed4 _BaseColor;
			fixed4 _HighlightColor;
			fixed4 _ShadowColor;

			fixed _HighlightThreshold;
			fixed _HighlightSoftness;

			fixed _ShadowThreshold;
			fixed _ShadowSoftness;

			fixed _EdgeDarkening;
			fixed _NoiseDarkening;

			fixed4 darken(fixed4 color, fixed factor)
			{
				return  color - (color - color * color) * factor;
			}

			vertexOutput vert (vertexInput i)
			{
				vertexOutput o;
                o.pos = UnityObjectToClipPos(i.vertex);

				o.uv = i.texcoord.xy;
				o.noiseUV = (i.vertex.xyz + 1.0) / 2.0;

				float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
				float3 normal = normalize(UnityObjectToWorldNormal(i.normal));
				float3 l = normalize(_WorldSpaceLightPos0.xyz);
				o.intensity = dot(l, normal) * _LightColor0.r;

				for (int i = 0; i < 4; i++)
				{
					float3 lightPos = float3(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i]);
					float vertexToLight = lightPos - worldPos;
					float squaredDistance = dot(vertexToLight, vertexToLight);
					l = normalize(lightPos - worldPos);
					o.intensity += dot(l, normal) * (1.0 / (1.0 + unity_4LightAtten0[i] * squaredDistance)) * unity_LightColor[i].r;
				}
				o.intensity = clamp(o.intensity, 0.0, 1.0);
				
				TRANSFER_SHADOW(o);

                return o;
			}
			
			half4 frag (vertexOutput i) : COLOR
			{
				fixed n = tex3D(_Noise, i.noiseUV);
				fixed intensity = i.intensity * SHADOW_ATTENUATION(i);
				intensity = intensity * n + intensity * 0.2;

				fixed shadowEdge = 1.0 - smoothstep(0.0, _ShadowSoftness, abs(intensity - _ShadowThreshold));

				fixed highlight = lerp(0.0, 1.0, smoothstep(_HighlightThreshold - _HighlightSoftness, _HighlightThreshold + _HighlightSoftness, intensity));
				intensity = lerp(0.0, 0.5, smoothstep(_ShadowThreshold - _ShadowSoftness, _ShadowThreshold + _ShadowSoftness, intensity));
				intensity += highlight;
				intensity = clamp(intensity, 0.0, 1.0);

				fixed4 color = _BaseColor;

				color = lerp(color, _HighlightColor, max(0.0, intensity - 0.5) * 2.0);
				color = lerp(_ShadowColor, color, min(1.0, intensity * 2.0));

				color = darken(color, n * _NoiseDarkening);
				color = darken(color, shadowEdge * _EdgeDarkening);
                return color;
			}
			ENDCG
		}


		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

		Pass
		{
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed _MinLineThickness;
			fixed _MaxLineThickness;
			fixed4 _LineColorLight;
			fixed4 _LineColorDark;

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				fixed4 lineColor : TEXCOORD0;
			};

			struct fragmentOutput
			{
				fixed4 color : SV_Target0;
			};

			vertexOutput vert(appdata_base i)
			{
				vertexOutput o;
				fixed lighting = max(0.0, dot(normalize(UnityObjectToWorldNormal(i.normal)), normalize(_WorldSpaceLightPos0.xyz)));
				fixed lineThickness = lerp(_MinLineThickness, _MaxLineThickness, 1.0 - lighting);
				o.pos = UnityObjectToClipPos(i.vertex + normalize(i.normal) * lineThickness);
				o.lineColor = lerp(_LineColorDark, _LineColorLight, lighting);
				return o;
			}

			fragmentOutput frag(vertexOutput i)
			{
				fragmentOutput o;
				o.color = i.lineColor;
				return o;
			}

			ENDCG
		}

	}

	Fallback "VertexLit"
}
