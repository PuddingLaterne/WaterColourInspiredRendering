Shader "Unlit/Outline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
			"Outline" = "Default"
		}
		LOD 100

		Pass
		{
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
			};

			fixed4 _OutlineColor;
			fixed _OutlineOpacity;
			fixed _OutlinePos;
			fixed _MinOutlineThickness;
			fixed _MaxOutlineThickness;

			vertexOutput vert(appdata_base i)
			{
				vertexOutput o;
				fixed lighting = max(0.0, dot(normalize(UnityObjectToWorldNormal(i.normal)), normalize(_WorldSpaceLightPos0.xyz)));
				fixed lineThickness = lerp(_MinOutlineThickness, _MaxOutlineThickness, 1.0 - lighting) * (1.0 - _OutlinePos);
				o.vertex = UnityObjectToClipPos(i.vertex - normalize(i.normal) * lineThickness);
				return o;
			}

			fixed4 frag(vertexOutput i) : SV_Target
			{
				fixed4 col = fixed4(1.0, 1.0, 1.0, 1.0);
				return col;
			}

			ENDCG
		}


		Pass
		{
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
			};

			fixed4 _OutlineColor;
			fixed _OutlineOpacity;
			fixed _OutlinePos;
			fixed _MinOutlineThickness;
			fixed _MaxOutlineThickness;

			vertexOutput vert (appdata_base i)
			{
				vertexOutput o;
				fixed lighting = max(0.0, dot(normalize(UnityObjectToWorldNormal(i.normal)), normalize(_WorldSpaceLightPos0.xyz)));
				fixed lineThickness = lerp(_MinOutlineThickness, _MaxOutlineThickness, 1.0 - lighting) * _OutlinePos;
				o.vertex = UnityObjectToClipPos(i.vertex + normalize(i.normal) * lineThickness);
				return o;
			}
			
			fixed4 frag (vertexOutput i) : SV_Target
			{
				fixed4 col = fixed4(0.0, 0.0, 0.0, _OutlineOpacity);
				return col;
			}
			ENDCG
		}
	}
}
