Shader "Custom/Toon2" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RampTex("Ramp Texture", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf StandardOverride fullforwardshadows
			#include "UnityPBSLighting.cginc"
			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _RampTex;

			struct Input {
				float2 uv_MainTex;
			};

			struct SurfaceOutputOverride
			{
				fixed3 Albedo;
				fixed3 Normal;
				half3 Emission;
				half Metallic;
				half Smoothness;
				half Occlusion;
				fixed Alpha;
				float2 foo_uv;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;

			fixed4 LightingStandardOverride(SurfaceOutputOverride s, half3 viewDir, UnityGI gi) {

				SurfaceOutputStandard r;
				r.Albedo = s.Albedo;
				r.Normal = s.Normal;
				r.Emission = s.Emission;
				r.Metallic = s.Metallic;
				r.Smoothness = s.Smoothness;
				r.Occlusion = s.Occlusion;
				r.Alpha = s.Alpha;
				fixed4 oldResult = LightingStandard(r, viewDir, gi);

				float intensity = dot(oldResult.rgb, float3(0.2326, 0.7152, 0.0722));
				intensity = min(intensity, 0.99);
				intensity = max(intensity, 0.01);
				float2 uv = float2(1.0 - intensity, 0.5);
				fixed4 c = tex2D(_RampTex, uv) * _Color;

				return c;
			}

			inline void LightingStandardOverride_GI(SurfaceOutputOverride s, UnityGIInput data, inout UnityGI gi)
			{
				UNITY_GI(gi, s, data);
			}

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputOverride o) {
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
				o.foo_uv = IN.uv_MainTex;
			}
			ENDCG
		}
			FallBack "Diffuse"
}