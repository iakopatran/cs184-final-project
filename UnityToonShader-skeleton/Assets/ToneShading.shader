﻿Shader "Roystan/Tone"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
		_Outline("Outline", Range(0,1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Blue("Blue", Range(0, 1)) = 0.5
		_Alpha("Alpha", Range(0, 1)) = 0.5
		_Yellow("Yellow", Range(0, 1)) = 0.5
		_Beta("Beta", Range(0, 1)) = 0.5
	}
		SubShader
		{
				Pass {

				Cull Front

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				float _Outline;
				fixed4 _OutlineColor;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
				};

				v2f vert(a2v v) {
					v2f o;

					float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
					float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
					normal.z = -1;
					pos = pos + float4(normalize(normal), 0) * _Outline;
					o.pos = mul(UNITY_MATRIX_P, pos);

					return o;
				}

				float4 frag(v2f i) : SV_Target {
					return float4(_OutlineColor.rgb, 1);
				}

				ENDCG
			}
			Pass
			
		{
		Tags
{
	"LightMode" = "ForwardBase"
	"PassFlags" = "OnlyDirectional"
}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
			float3 viewDir : TEXCOORD1;
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				TRANSFER_SHADOW(o)
				return o;
			}

			float4 _Color;
			float4 _AmbientColor;
			float _Glossiness;
			float4 _SpecularColor;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
			float _Blue;
			float _Alpha;
			float _Yellow;
			float _Beta;
			float4 frag (v2f i) : SV_Target
			{

			float3 normal = normalize(i.worldNormal);
			float NdotL = dot(_WorldSpaceLightPos0, normal);
			float shadow = SHADOW_ATTENUATION(i);

			float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
			float4 light = lightIntensity * _LightColor0;

			float3 viewDir = normalize(i.viewDir);

			float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
			float NdotH = dot(normal, halfVector);

			float4 sample = tex2D(_MainTex, i.uv);
			float diff = dot(normal, _WorldSpaceLightPos0);
			diff = (diff * 0.5 + 0.5) * shadow;

			float3 k_d = sample.rgb * _Color.rgb;

			float3 k_blue = float3(0, 0, _Blue);
			float3 k_yellow = float3(_Yellow, _Yellow, 0);
			float3 k_cool = k_blue + _Alpha * k_d;
			float3 k_warm = k_yellow + _Beta * k_d;

			float3 diffuse = _LightColor0.rgb * (diff * k_warm + (1 - diff) * k_cool);
			float3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(normal, halfVector)), _Glossiness);

			float4 rimDot = 1 - dot(viewDir, normal);
			float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
			rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
			float4 rim = rimIntensity * _RimColor;
			

				return float4(_AmbientColor + diffuse + specular, 1.0);
			}
			ENDCG
		}
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
