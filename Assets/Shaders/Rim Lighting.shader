Shader "Custom/RimLighting" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {} // Base texture
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1) // Color of the rim light (white by default)
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0 // Controls the sharpness or spread of the rim light effect
    }
    SubShader {
        Tags { "RenderType"="Opaque" } // Defines the object as opaque
        CGPROGRAM
        #pragma surface surf Lambert // Lambertian lighting model

        // Declare properties
        sampler2D _MainTex; // Main texture
        float4 _RimColor; // Color for the rim lighting
        float _RimPower; // Power to control rim light intensity

        struct Input {
            float2 uv_MainTex; // UV coordinates for texture sampling
            float3 viewDir; // View direction (used to calculate the rim light effect)
        };

        // Surface shader function
        void surf(Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex); // Sample the texture at the UV coordinates
            o.Albedo = c.rgb; // Assign the texture color to the Albedo (base color)

            // Calculate rim lighting based on the view direction and normal
            float rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); // Calculate the rim factor based on view direction
            o.Emission = _RimColor.rgb * pow(rim, _RimPower); // Apply the rim lighting effect using the power parameter
        }
        ENDCG
    }
    Fallback "Diffuse" // Fallback to a diffuse shader if this one can't be used
}
