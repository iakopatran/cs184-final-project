Shader "Unlit/EdgeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NThreshold("NormalsThreshold", float) = 0.2
        _DThreshold("DepthThreshold", float) = 0.0001
    }
    SubShader
    {
        // No culling or depth
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
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            float _NThreshold;
            float _DThreshold;
            
            float4 GetNormalDepthColor(in float2 uv) {
                float3 normals;
                float depth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normals);
                return float4(normals, depth);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 myNDC = GetNormalDepthColor(i.uv);
                float3 myN = myNDC.xyz;
                float myD = myNDC.w;
                //return myNDC;
                
                
                float4 averageNDC = float4(0,0,0,0);
                averageNDC += GetNormalDepthColor(i.uv + float2(1,1) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(0,1) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(-1,1) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(1,0) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(-1,0) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(1,-1) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(0,-1) * _MainTex_TexelSize.xy);
                averageNDC += GetNormalDepthColor(i.uv + float2(-1,-1) * _MainTex_TexelSize.xy);
                averageNDC /= 8;
                float3 avgN = averageNDC.xyz;
                float avgD = averageNDC.w;
                
                return length(myN - avgN) < _NThreshold && abs(myD - avgD) < _DThreshold ? col : float4(0, 0, 0, 0);
            }
            ENDCG
        }
    }
}
