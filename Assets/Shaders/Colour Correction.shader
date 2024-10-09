Shader "Custom/WinterColorCorrection"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _WinterTint ("Winter Tint Color", Color) = (0.5, 0.6, 1, 1) // Light blue
        _Saturation ("Saturation", Range(0, 1)) = 0.3  // Lowering the saturation
        _Brightness ("Brightness", Range(0, 2)) = 1.0  // Adjust overall brightness
        _Contrast ("Contrast", Range(0, 2)) = 1.1     // Increase contrast a bit
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            sampler2D _MainTex;
            float4 _WinterTint;
            float _Saturation;
            float _Brightness;
            float _Contrast;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 ApplySaturation(fixed4 color, float saturation)
            {
                float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
                return lerp(float4(luminance, luminance, luminance, color.a), color, saturation);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply the winter tint
                col.rgb = lerp(col.rgb, _WinterTint.rgb, 0.3); // Blend towards blue

                // Apply saturation adjustment
                col = ApplySaturation(col, _Saturation);

                // Apply contrast and brightness
                col.rgb = ((col.rgb - 0.5) * max(_Contrast, 0)) + 0.5; // Contrast adjustment
                col.rgb *= _Brightness; // Brightness adjustment

                return col;
            }
            ENDCG
        }
    }

    // Fallback for shader
    Fallback "Diffuse"
}
