Shader "Unlit/Scan"
{
    Properties
    {
        _Range("Range", Range(0.1, 5.0)) = 1
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewPos : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };
        
            float _Range;
            float4 _BaseColor;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.viewPos = TransformWorldToView(TransformObjectToWorld(v.vertex));
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.screenPos.xy / i.screenPos.w;
                float depth = LinearEyeDepth(SampleSceneDepth(uv),_ZBufferParams);
                float off = depth -  (i.viewPos.z * -1);

                off *= _Range;
                off = 1 - saturate(off);

                float4 col = _BaseColor;
                col *= off;

                return col;
            }
            ENDHLSL
        }
    }
}
