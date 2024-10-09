//Explanation: I applied an animated toon shader to the character to make it stand out in the scene. While everything else in the scene is static, the player model is contrasted by the animation and also the toon shading keeps to the retro aspect of the game while adding some sense of depth to the playable character. As this shader helps an object stand out I thought it would be best to apply it to the playable character as this is what the player's attention should be most focused on. The animation from light to darker blue also signifies a freezing kind of feeling as the environment is the ice covered mountains



Shader "Custom/AnimatedToonShader"
{
    // These are properties exposed to the Unity editor for tweaking shader settings
    Properties
    {
        _Color("Base Color", Color) = (1, 1, 1, 1)  // Base color for the object
        _ShadeColor("Shade Color", Color) = (0, 0, 0, 1)  // Color used in shaded regions
        _RampSteps("Ramp Steps", Range(1, 5)) = 3  // Number of steps for toon shading
        _OutlineThickness("Outline Thickness", Range(0.001, 0.03)) = 0.01  // Outline thickness (not used here, can be extended for outline effects)
        _TimeFactor("Time Animation Speed", Range(0.1, 5.0)) = 1.0  // Speed of the animation effect on the color
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }  // Render as an opaque object (no transparency)
        LOD 200  // Level of Detail (LOD) value for rendering quality

        Pass
        {
            CGPROGRAM
            // Vertex and fragment shader declarations
            #pragma vertex vert  // Vertex shader function name is "vert"
            #pragma fragment frag  // Fragment shader function name is "frag"

            #include "UnityCG.cginc"  // Include Unity's shader helper functions and macros

            // Define input structure for vertex shader
            struct appdata
            {
                float4 vertex : POSITION;  // Position of the vertex
                float3 normal : NORMAL;  // Normal vector of the vertex
            };

            // Define output structure for vertex-to-fragment communication
            struct v2f
            {
                float4 pos : SV_POSITION;  // Screen-space position (required by fragment shader)
                float3 normal : TEXCOORD0;  // Normal vector passed to the fragment shader
            };

            // Declare properties (connected to the Properties block above)
            float _RampSteps;  // Number of steps for the toon shading
            float4 _Color;  // Base color of the object
            float4 _ShadeColor;  // Color for shaded areas
            float _TimeFactor;  // Speed of the animated color transition

            // Vertex shader: processes each vertex of the mesh
            v2f vert (appdata v)
            {
                v2f o;
                // Transform the object's vertex position from object space to clip space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Transform the normal from object space to world space
                o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
                return o;  // Output the processed data to the fragment shader
            }

            // Fragment shader: processes each pixel (fragment) of the mesh
            float4 frag (v2f i) : SV_Target
            {
                // Normalize the normal vector (for consistent lighting calculations)
                float3 norm = normalize(i.normal);
                // Calculate lighting intensity based on the dot product between the light direction and the surface normal
                float lightIntensity = dot(norm, _WorldSpaceLightPos0.xyz);

                // Toon shading effect: use a step function to create a cel-shading look
                // This "ceil" function reduces the number of smooth lighting levels to discrete steps
                lightIntensity = ceil(lightIntensity * _RampSteps) / _RampSteps;

                // Animation effect: make the color change over time
                // Use sine wave to make the transition between base and shade color oscillate
                float animatedFactor = sin(_Time.y * _TimeFactor) * 0.5 + 0.5;

                // Blend between base color and shade color based on the animated factor
                float4 finalColor = lerp(_Color, _ShadeColor, animatedFactor);

                // Multiply the final color by the lighting intensity (toon shading)
                finalColor.rgb *= lightIntensity;

                return finalColor;  // Output the final color to the screen
            }
            ENDCG
        }
    }

    FallBack "Diffuse"  // Fallback to Unity's built-in Diffuse shader if not supported
}
