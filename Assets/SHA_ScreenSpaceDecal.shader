Shader "Unlit/SHA_ScreenSpaceDecal"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DecalScale("Decal Scale", Range(0.1, 5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent+50" }

		LOD 100

		ZWrite off Cull Off Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldRay : TEXCOORD0;
				float4 hpos : TEXCOORD1;
			};

			Texture2D         _MainTex;
			float4            _MainTex_TexelSize;
			SamplerState      _MainTex_Linear_Clamp_Sampler;
			float             _DecalScale;

			uniform sampler2D _CameraDepthTexture;
			uniform float4x4  _matProjectorViewProj;
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldRay = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
				o.hpos = o.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 depthTexCoord = i.hpos.xy / i.hpos.w * 0.5 + 0.5;

			#if UNITY_UV_STARTS_AT_TOP
				if (_ProjectionParams.x < 0)
					depthTexCoord.y = 1 - depthTexCoord.y;
			#endif

				float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, depthTexCoord)));
				float3 worldPos = i.worldRay / i.hpos.w * depth + _WorldSpaceCameraPos;
				
				float3 localPos = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
				clip(0.5 - abs(localPos.xyz));

				float2 decal = localPos.xz * -0.5 + 0.5;

			#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					decal.y = 1 - decal.y;
			#endif

				decal = decal.xy * (_DecalScale + 1) - _DecalScale * 0.5;
				return _MainTex.Sample(_MainTex_Linear_Clamp_Sampler, decal);
			}
			ENDCG
		}
	}
}
