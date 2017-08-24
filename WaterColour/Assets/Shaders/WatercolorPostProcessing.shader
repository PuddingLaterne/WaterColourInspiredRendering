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
			sampler2D _PaperTex;
			sampler2D _PaperNormalTex;
			fixed _MaxLuminance;
			fixed _Darkening;
			fixed _Distortion;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed2 paperUV = (tex2D(_PaperNormalTex, i.uv).xy - 0.5) * 2.0;
				fixed2 distortedUV = i.uv + paperUV * _Distortion;

				fixed4 col = tex2D(_MainTex, distortedUV);
				fixed4 outline = tex2D(_OutlineTex, distortedUV);
				col = (col - (col - pow(col, 2.0)) * (1.0 - outline)) * 0.5 + col * outline * 0.5;
						
				fixed lum = Luminance(col);
				fixed4 paperCol = tex2D(_PaperTex, i.uv);

				fixed4 combined = col * paperCol + col * 0.2;
				col = lerp(col, combined, _Darkening * (1.0 - smoothstep(_MaxLuminance, 1.0, lum)));
				return col;
			}
			ENDCG
		}
	}
}
