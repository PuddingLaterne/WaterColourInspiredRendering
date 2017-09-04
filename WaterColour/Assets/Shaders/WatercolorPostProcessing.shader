Shader "Hidden/WatercolorPostProcessing"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#pragma multi_compile OUTLINE_BLUR_ON OUTLINE_BLUR_OFF
			#pragma multi_compile BG_BLUR_ON BG_BLUR_OFF

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _OutlineTex;
			sampler2D _BackgroundTex;
			sampler2D _EffectTex;
			sampler2D _PaperTex;
			sampler2D _PaperNormalTex;
			fixed _MaxLuminance;
			fixed _Darkening;
			fixed _Distortion;
			fixed _EffectVisibility;
			fixed2 _BrightnessOrigin;
			fixed _BrighteningFadeStart;
			fixed _BrighteningFadeEnd;
			fixed _BrighteningStrength;

			fixed4 sampleAndInterpolate(sampler2D tex, fixed2 uv)
			{
				fixed offsetX = _ScreenParams.z - 1.0;
				fixed offsetY = _ScreenParams.w - 1.0;

				fixed4 result;
				for (int i = 0; i < 3; i++)
				{
					for (int j = 0; j < 3; j++)
					{
						result += tex2D(tex, uv + fixed2(offsetX * (i - 1.0), offsetY * (j - 1.0)));
					}
				}
				result /= 9.0;
				return result;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed2 paperUV = (tex2D(_PaperNormalTex, i.uv).xy - 0.5) * 2.0;
				fixed2 distortedUV = i.uv + paperUV * _Distortion;

				fixed4 col = tex2D(_MainTex, distortedUV);
				fixed4 colBG = fixed4(0.0, 0.0, 0.0, 0.0);
				fixed4 colEffect = tex2D(_EffectTex, i.uv);

				#ifdef BG_BLUR_ON
				colBG = sampleAndInterpolate(_BackgroundTex, distortedUV);		
				#endif 

				#ifdef BG_BLUR_OFF
				colBG = tex2D(_BackgroundTex, distortedUV);
				#endif

				colBG = lerp(colBG, colEffect, colEffect.a * _EffectVisibility);
				col = lerp(colBG, col, col.a);

				fixed outline;

				#ifdef OUTLINE_BLUR_ON	
				outline = sampleAndInterpolate(_OutlineTex, distortedUV).r;
				#endif

				#ifdef OUTLINE_BLUR_OFF
				outline = tex2D(_OutlineTex, distortedUV).r;
				#endif	

				outline = ((1.0 - outline) - 0.5) * 2.0;
				col = col - (col - pow(col, 2.0)) * (outline);
						
				fixed lum = Luminance(col);
				fixed4 paperCol = tex2D(_PaperTex, i.uv);

				fixed4 combined = col * paperCol + col * 0.2;
				col = lerp(col, combined, _Darkening * (1.0 - smoothstep(_MaxLuminance, 1.0, lum)));

				fixed brightening = distance(_BrightnessOrigin, distortedUV);
				brightening = 1.0 - smoothstep(_BrighteningFadeStart, _BrighteningFadeEnd, brightening);
				brightening *= _BrighteningStrength;
				
				col = col - (col - pow(col, 2.0)) * (-brightening);
				return col;
			}
			ENDCG
		}
	}
}
