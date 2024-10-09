Shader "Custom/WinterColorCorrection"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {} // Base texture
        _WinterTint ("Winter Tint Color", Color) = (0.5, 0.6, 1, 1) // Light blue tint for a winter effect
        _Saturation ("Saturation", Range(0, 1)) = 0.3  // Reduces the saturation to give a desaturated look
        _Brightness ("Brightness", Range(0, 2)) = 1.0  // Adjusts the overall brightness of the texture
        _Contrast ("Contrast", Range(0, 2)) = 1.1     // Increases contrast for more pronounced differences
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" } // Defines the object type as opaque
        LOD 200 // Level of detail for the shader

        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Vertex shader
            #pragma fragment frag // Fragment shader
            #include "UnityCG.cginc" // Includes common Unity shader functions

            // Properties
            sampler2D _MainTex; // Texture input
            float4 _WinterTint; // Color for winter tint
            float _Saturation; // Saturation level
            float _Brightness; // Brightness level
            float _Contrast; // Contrast level

            struct appdata
            {
                float4 vertex : POSITION; // Vertex position data
                float2 uv : TEXCOORD0; // Texture coordinate data
            };

            struct v2f
            {
                float2 uv : TEXCOORD0; // Output texture coordinate
                float4 pos : SV_POSITION; // Screen-space position
            };

            // Vertex shader: transforms vertices to screen space
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // Convert to screen-space position
                o.uv = v.uv; // Pass through texture coordinates
                return o;
            }

            // Function to adjust saturation
            fixed4 ApplySaturation(fixed4 color, float saturation)
            {
                // Calculate the luminance (grayscale value)
                float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
                // Interpolate between grayscale and original color based on saturation
                return lerp(float4(luminance, luminance, luminance, color.a), color, saturation);
            }

            // Fragment shader: processes each pixel
            fixed4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply the winter tint color
                col.rgb = lerp(col.rgb, _WinterTint.rgb, 0.3); // Blend texture color with winter tint

                // Apply saturation adjustment
                col = ApplySaturation(col, _Saturation);

                // Apply contrast and brightness
                col.rgb = ((col.rgb - 0.5) * max(_Contrast, 0)) + 0.5; // Adjust contrast
                col.rgb *= _Brightness; // Adjust brightness

                return col; // Return the final color
            }
            ENDCG
        }
    }

    // Fallback for shader in case the custom one can't be used
    Fallback "Diffuse"
}
