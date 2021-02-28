// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Refraction"
{
    Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
		_RefractAmount ("Refraction Amount", Range(0, 1)) = 1
		_RefractRatio("Refraction Ratio",Range(0.1,1))=0.5
		_Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			fixed4 _RefractColor;
			fixed _RefractAmount;
			fixed _RefractRatio;
			samplerCUBE _Cubemap;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldpos : TEXCOORD0;
				fixed3 worldnormal : TEXCOORD1;
				fixed3 worldviewDir : TEXCOORD2;
				fixed3 worldRefr : TEXCOORD3;
				SHADOW_COORDS(4)
			};

            v2f vert (a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
				o.worldpos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldviewDir=UnityWorldSpaceViewDir(o.worldpos);
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
				o.worldRefr=refract(-normalize(o.worldviewDir),normalize(o.worldnormal),_RefractRatio);
				TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldnormal=normalize(i.worldnormal);
				fixed3 worldlightDir=normalize(UnityWorldSpaceLightDir(i.worldpos));
				fixed3 worldviewDir=normalize(i.worldviewDir);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse=_LightColor0.rgb*_Color.rgb*max(0,dot(worldnormal,worldlightDir));
				fixed3 refraction=texCUBE(_Cubemap,i.worldRefr).rgb*_RefractColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldpos);
				return fixed4(ambient+lerp(diffuse,refraction,_RefractAmount)*atten,1.0);
			}
            ENDCG
        }
    }
	FallBack "Reflective/VertexLit"
}
