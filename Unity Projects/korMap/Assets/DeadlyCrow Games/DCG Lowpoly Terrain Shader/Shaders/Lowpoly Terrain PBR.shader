// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Nature/Lowpoly Terrain PBR"
{
	Properties
	{
		[HideInInspector]_Control("Control", 2D) = "white" {}
		[HideInInspector]_Splat2("Splat2", 2D) = "white" {}
		[HideInInspector]_Splat3("Splat3", 2D) = "white" {}
		[HideInInspector]_Splat1("Splat1", 2D) = "white" {}
		[HideInInspector]_Splat0("Splat0", 2D) = "white" {}
		[HideInInspector]_Smoothness1("Smoothness1", Float) = 0
		[HideInInspector]_Smoothness3("Smoothness3", Float) = 0
		[HideInInspector]_Smoothness0("Smoothness0", Float) = 0
		[HideInInspector]_Smoothness2("Smoothness2", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Control;
		uniform float4 _Control_ST;
		uniform sampler2D _Splat0;
		uniform float4 _Splat0_ST;
		uniform sampler2D _Splat1;
		uniform float4 _Splat1_ST;
		uniform sampler2D _Splat2;
		uniform float4 _Splat2_ST;
		uniform sampler2D _Splat3;
		uniform float4 _Splat3_ST;
		uniform float _Smoothness0;
		uniform float _Smoothness1;
		uniform float _Smoothness2;
		uniform float _Smoothness3;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float localCalculateTangents70 = ( 0.0 );
			v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) );
			v.tangent.w = -1;
			float3 temp_cast_0 = (localCalculateTangents70).xxx;
			v.vertex.xyz += temp_cast_0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult34 = normalize( cross( ddy( ase_worldPos ) , ddx( ase_worldPos ) ) );
			float3 indirectNormal95 = normalizeResult34;
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode6 = tex2D( _Control, uv_Control );
			float smoothstepResult12 = smoothstep( 0.497 , 0.5 , tex2DNode6.g);
			float smoothstepResult13 = smoothstep( 0.497 , 0.5 , tex2DNode6.b);
			float smoothstepResult14 = smoothstep( 0.497 , 0.5 , tex2DNode6.a);
			float4 appendResult18 = (float4(0.0 , smoothstepResult12 , smoothstepResult13 , smoothstepResult14));
			float4 layeredBlendVar71 = appendResult18;
			float layeredBlend71 = ( lerp( lerp( lerp( lerp( _Smoothness0 , _Smoothness0 , layeredBlendVar71.x ) , _Smoothness1 , layeredBlendVar71.y ) , _Smoothness2 , layeredBlendVar71.z ) , _Smoothness3 , layeredBlendVar71.w ) );
			Unity_GlossyEnvironmentData g95 = UnityGlossyEnvironmentSetup( layeredBlend71, data.worldViewDir, indirectNormal95, float3(0,0,0));
			float3 indirectSpecular95 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal95, g95 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV97 = dot( normalize( normalizeResult34 ), ase_worldViewDir );
			float fresnelNode97 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV97, 2.5 ) );
			float clampResult101 = clamp( layeredBlend71 , 0.05 , 1.0 );
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float4 tex2DNode25 = tex2D( _Splat0, uv_Splat0 );
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 layeredBlendVar26 = appendResult18;
			float4 layeredBlend26 = ( lerp( lerp( lerp( lerp( tex2DNode25 , tex2DNode25 , layeredBlendVar26.x ) , tex2D( _Splat1, uv_Splat1 ) , layeredBlendVar26.y ) , tex2D( _Splat2, uv_Splat2 ) , layeredBlendVar26.z ) , tex2D( _Splat3, uv_Splat3 ) , layeredBlendVar26.w ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult47 = dot( ase_worldlightDir , normalizeResult34 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			UnityGI gi52 = gi;
			float3 diffNorm52 = normalizeResult34;
			gi52 = UnityGI_Base( data, 1, diffNorm52 );
			float3 indirectDiffuse52 = gi52.indirect.diffuse + diffNorm52 * 0.0001;
			float4 blendOpSrc98 = float4( ( ( indirectSpecular95 * fresnelNode97 * 0.77 ) * clampResult101 ) , 0.0 );
			float4 blendOpDest98 = ( ( layeredBlend26 * saturate( dotResult47 ) * ( ase_lightColor * ase_lightAtten ) ) + saturate( ( float4( indirectDiffuse52 , 0.0 ) * 1.0 * layeredBlend26 ) ) );
			c.rgb = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc98 ) * ( 1.0 - blendOpDest98 ) ) )).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode6 = tex2D( _Control, uv_Control );
			float smoothstepResult12 = smoothstep( 0.497 , 0.5 , tex2DNode6.g);
			float smoothstepResult13 = smoothstep( 0.497 , 0.5 , tex2DNode6.b);
			float smoothstepResult14 = smoothstep( 0.497 , 0.5 , tex2DNode6.a);
			float4 appendResult18 = (float4(0.0 , smoothstepResult12 , smoothstepResult13 , smoothstepResult14));
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float4 tex2DNode25 = tex2D( _Splat0, uv_Splat0 );
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 layeredBlendVar26 = appendResult18;
			float4 layeredBlend26 = ( lerp( lerp( lerp( lerp( tex2DNode25 , tex2DNode25 , layeredBlendVar26.x ) , tex2D( _Splat1, uv_Splat1 ) , layeredBlendVar26.y ) , tex2D( _Splat2, uv_Splat2 ) , layeredBlendVar26.z ) , tex2D( _Splat3, uv_Splat3 ) , layeredBlendVar26.w ) );
			o.Emission = ( layeredBlend26 * UNITY_LIGHTMODEL_AMBIENT ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16100
2067;32;1710;1041;4603.521;2305.857;5.13749;True;True
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-1915.379,-644.1779;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DdxOpNode;31;-1502.556,-735.3128;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdyOpNode;32;-1507.8,-502.9311;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;6;-1634.985,-37.4552;Float;True;Property;_Control;Control;0;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-1223.828,160.2849;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.497;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;33;-1084.377,-625.5598;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-1222.364,35.15244;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.497;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-1213.708,-98.84754;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.497;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-810.4708,1513.472;Float;False;Property;_Smoothness2;Smoothness2;8;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-919.7484,878.8369;Float;True;Property;_Splat2;Splat2;1;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;92;-809.4708,1400.472;Float;False;Property;_Smoothness1;Smoothness1;5;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-807.2432,1317.346;Float;False;Property;_Smoothness0;Smoothness0;7;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-805.4708,1621.472;Float;False;Property;_Smoothness3;Smoothness3;6;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;48;-585.25,-836.5107;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;25;-921.1752,439.2798;Float;True;Property;_Splat0;Splat0;4;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-898.3416,1098.616;Float;True;Property;_Splat3;Splat3;2;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-919.7487,651.9227;Float;True;Property;_Splat1;Splat1;3;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;18;-886.1068,-117.9109;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;34;-773.5129,-579.4014;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LayeredBlendNode;71;-284.1956,1043.266;Float;False;6;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;66;82.33905,199.3649;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;47;-194.4744,-543.382;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;65;137.3391,85.36493;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LayeredBlendNode;26;-320.3522,243.7621;Float;False;6;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-585.1934,-186.7858;Float;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;52;-464.0528,-258.4362;Float;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;99;1043.841,1298.763;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;0.77;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;97;799.2931,1270.418;Float;False;Standard;WorldNormal;ViewDir;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;95;410.92,924.4362;Float;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;100;138.5293,1121.245;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;62;28.68469,-496.3837;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-300.0908,-102.7331;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;294.3391,-86.63507;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;69;-51.20555,-114.6099;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;300.8553,-261.3934;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;101;320.3588,1122.245;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;897.236,1015.604;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;911.2634,845.2145;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;53;109.4035,586.9413;Float;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;706.6648,171.8315;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-69.21658,466.0216;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-879.6559,52.95598;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;98;1133.994,713.6598;Float;False;Screen;True;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;23;-725.3058,69.7841;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;70;454.8309,378.6878;Float;False;v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) )@$v.tangent.w = -1@;1;True;0;CalculateTangents;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-871.6083,184.3925;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1408.229,362.197;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;DCG/Nature/Lowpoly Terrain PBR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;30;0
WireConnection;32;0;30;0
WireConnection;14;0;6;4
WireConnection;33;0;32;0
WireConnection;33;1;31;0
WireConnection;13;0;6;3
WireConnection;12;0;6;2
WireConnection;18;1;12;0
WireConnection;18;2;13;0
WireConnection;18;3;14;0
WireConnection;34;0;33;0
WireConnection;71;0;18;0
WireConnection;71;1;91;0
WireConnection;71;2;91;0
WireConnection;71;3;92;0
WireConnection;71;4;93;0
WireConnection;71;5;94;0
WireConnection;47;0;48;0
WireConnection;47;1;34;0
WireConnection;26;0;18;0
WireConnection;26;1;25;0
WireConnection;26;2;25;0
WireConnection;26;3;27;0
WireConnection;26;4;28;0
WireConnection;26;5;29;0
WireConnection;52;0;34;0
WireConnection;97;0;34;0
WireConnection;95;0;34;0
WireConnection;95;1;71;0
WireConnection;100;0;71;0
WireConnection;62;0;47;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;58;2;26;0
WireConnection;64;0;65;0
WireConnection;64;1;66;0
WireConnection;69;0;58;0
WireConnection;60;0;26;0
WireConnection;60;1;62;0
WireConnection;60;2;64;0
WireConnection;101;0;100;0
WireConnection;96;0;95;0
WireConnection;96;1;97;0
WireConnection;96;2;99;0
WireConnection;102;0;96;0
WireConnection;102;1;101;0
WireConnection;67;0;60;0
WireConnection;67;1;69;0
WireConnection;54;0;26;0
WireConnection;54;1;53;0
WireConnection;22;0;12;0
WireConnection;22;1;13;0
WireConnection;22;2;14;0
WireConnection;98;0;102;0
WireConnection;98;1;67;0
WireConnection;23;0;22;0
WireConnection;24;0;23;0
WireConnection;0;2;54;0
WireConnection;0;13;98;0
WireConnection;0;11;70;0
ASEEND*/
//CHKSM=8BDB9E810E6770CD9EB7BBB5F5390C0549AEF3A9