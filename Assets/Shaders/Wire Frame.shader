Shader "Custom/Wire Frame"
{
    Properties
    {
       [MainTexture] _MainTex ("Base (RGB)", 2D) = "white" {}
        [HDR] _Color ("Base Color", Color) = (1., 1., 1., 1.)
        [HideInInspector] _Face("Render Face", Float) = 2.0
        _WireframeVal ("Wireframe width", Range(0., 0.5)) = 0.05
        [HDR] _WireFrameColor ("Wire Frame color", Color) = (1., 1., 1., 1.)
        [Toggle] _RemoveDiag("Remove diagonals?", Float) = 0.
    }
    CustomEditor "EdgeCustomShader"
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Pass
        {
            Cull [_Face]
            CGPROGRAM
           
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #pragma shader_feature __ _REMOVEDIAG_ON

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;
            float _WireframeVal;
            fixed4 _WireFrameColor;

            // The built-in Unity variable for texture tiling and offset
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g {
                float4 worldPos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f {
                float4 pos : SV_POSITION;
                float3 bary : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2g vert(appdata v) {
                v2g o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
                float3 param = float3(0., 0., 0.);

                #if _REMOVEDIAG_ON
                float EdgeA = length(IN[0].worldPos - IN[1].worldPos);
                float EdgeB = length(IN[1].worldPos - IN[2].worldPos);
                float EdgeC = length(IN[2].worldPos - IN[0].worldPos);

                if(EdgeA > EdgeB && EdgeA > EdgeC)
                    param.y = 1.;
                else if (EdgeB > EdgeC && EdgeB > EdgeA)
                    param.x = 1.;
                else
                    param.z = 1.;
                #endif

                g2f o;
                o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
                o.bary = float3(1., 0., 0.) + param;
                o.uv = IN[0].uv;
                triStream.Append(o);
                o.pos = mul(UNITY_MATRIX_VP, IN[1].worldPos);
                o.bary = float3(0., 0., 1.) + param;
                o.uv = IN[1].uv;
                triStream.Append(o);
                o.pos = mul(UNITY_MATRIX_VP, IN[2].worldPos);
                o.bary = float3(0., 1., 0.) + param;
                o.uv = IN[2].uv;
                triStream.Append(o);
            }

            fixed4 frag(g2f i) : SV_Target {
                // Apply tiling and offset to the UV coordinates
                float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                fixed4 baseColor = tex2D(_MainTex, uv) * _Color;
                float minBary = min(min(i.bary.x, i.bary.y), i.bary.z);

                if(minBary <= _WireframeVal)
                {
                    // Edge pixel: blend wireframe color with base color
                    return lerp(baseColor, _WireFrameColor, 1.0); // Adjust the blending factor as needed
                }
                else
                {
                    // Non-edge pixel: return base color
                    return baseColor;
                }
            }

            ENDCG
        }
    }
}
