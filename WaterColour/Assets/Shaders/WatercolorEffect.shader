Shader "Watercolor/WatercolorEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE
		
	#include "UnityCG.cginc"
	#pragma target 3.0

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	
	float _Diffusion;
	float _Evaporation;
	float _MinPigmentDiffusionWetness;
	float _MaxPigmentDiffusionWetnessDelta;
	
	sampler2D _PaperTex;
	sampler2D _PigmentEmitters;
	sampler2D _BackgroundTex;
			
	struct appdata 
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
		
	struct v2f 
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
		
	v2f vert (appdata IN) 
	{
		v2f OUT;
		OUT.vertex = UnityObjectToClipPos(IN.vertex);
		OUT.uv = IN.uv;
		return OUT;
	}
	
	void sample (float2 uv, sampler2D tex, out float4 o, out float4 l, out float4 t, out float4 r, out float4 b) 
	{
		float2 texel = _MainTex_TexelSize.xy;
		o = tex2D(tex, uv);
		l = tex2D(tex, uv + float2(-texel.x,        0));
		t = tex2D(tex, uv + float2(	   0, -texel.y));
		r = tex2D(tex, uv + float2( texel.x,        0));
		b = tex2D(tex, uv + float2(       0,  texel.y));
	}

	float flow(float sourceHeight, float sourceWater, float destHeight, float destWater)
	{
		float source = sourceHeight + sourceWater;
		float destination = destHeight + destWater;

		float sourceFlow = max(0.0, _Diffusion * min(source - destination, source - max(destHeight, sourceHeight * 2.0)) * 0.25);
		float destFlow = max(0.0, _Diffusion * min(destination - source, destination - max(sourceHeight, destHeight * 2.0)) * 0.25);
		return sourceFlow - destFlow;
	}

	float3 pigmentSpread(float flow, float3 colorSource, float3 colorDest, float waterSource, float waterDest)
	{
		float lSource = Luminance(colorSource);
		float lDest = Luminance(colorDest);
		float f = 1.0 - min(1.0, lDest / (lSource + lDest)); //prevents white bleeding in
		float pigmentMixFactor = max(0.0, sign(waterSource - _MinPigmentDiffusionWetness)) * max(0.0, sign(_MaxPigmentDiffusionWetnessDelta - abs(waterSource - waterDest))); //mixes pigment even if there is no flow
		f *= max(max(0.0, sign(flow)), pigmentMixFactor);
		return lerp(colorDest, colorSource, f);
	}
	
	float4 waterFlow (float2 uv) 
	{
		float4 oP, lP, tP, rP, bP;
		float4 oC, lC, tC, rC, bC;
		sample(uv, _MainTex, oC, lC, tC, rC, bC);
		sample(uv, _PaperTex, oP, lP, tP, rP, bP);

		float4 result = oC;		
		float wetness = oC.w;

		float flowL = flow(1.0 - lP.r, lC.w, 1.0 - oP.r, wetness);
		float flowT = flow(1.0 - tP.r, tC.w, 1.0 - oP.r, wetness);
		float flowR = flow(1.0 - rP.r, rC.w, 1.0 - oP.r, wetness);
		float flowB = flow(1.0 - bP.r, bC.w, 1.0 - oP.r, wetness);

		float3 mixL = pigmentSpread(flowL, lC.rgb, result.rgb, lC.w, wetness);
		float3 mixR = pigmentSpread(flowR, rC.rgb, result.rgb, rC.w, wetness);
		float3 mixT = pigmentSpread(flowT, tC.rgb, result.rgb, tC.w, wetness);
		float3 mixB = pigmentSpread(flowB, bC.rgb, result.rgb, bC.w, wetness);

		result.rgb = (mixL + mixR + mixT + mixB) / 4.0;

		wetness += flowL + flowR + flowT + flowB;
		result.w = max(wetness, 0.0);

		return result;
	}
	
	float4 evaporate (float4 color, float4 backgroundColor) 
	{
		color.rgb = lerp(color.rgb, backgroundColor.rgb, _Evaporation);
		color.w = max(color.w - _Evaporation, 0.0);
		return color;
	}
	
	ENDCG
	
	SubShader 
	{
		Cull Off ZWrite Off ZTest Always
		
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment init
			
			float4 init (v2f IN) : SV_Target 
			{
				float4 col = tex2D(_BackgroundTex, IN.uv);
				col.a = 0.0;
				return col;
			}
			
			ENDCG
		}
		
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment waterUpdate
			
			float4 waterUpdate (v2f IN) : SV_Target 
			{
				return evaporate(waterFlow(IN.uv), tex2D(_BackgroundTex, IN.uv));
			}
			
			ENDCG
		}
		
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment visualize
			
			float4 visualize (v2f IN) : SV_Target 
			{
				float4 col = tex2D(_MainTex, IN.uv);
				return lerp(float4(1.0, 1.0, 1.0, 1.0), col, col.w);
			}
			
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment combine

			float4 combine(v2f IN) : SV_TARGET
			{
				float4 col = tex2D(_MainTex, IN.uv);
				float4 emitter = tex2D(_PigmentEmitters, IN.uv);
				col = lerp(col, emitter, smoothstep(0.9, 1.0, emitter.w));
				col = lerp(col, emitter, emitter.w);
				return col;
			}
			ENDCG
		}

	} 
}
