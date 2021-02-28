// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/RampTexture"
{
    Properties
	{
		_RampTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
 
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

            struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldpos : TEXCOORD1;
				float3 worldnormal : TEXCOORD2;
			};
 
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _RampTex);
				o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldnormal = UnityObjectToWorldNormal(v.normal);
 
				return o;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 worldnormal=normalize(i.worldnormal);
				fixed3 worldlightDir=normalize(UnityWorldSpaceLightDir(i.worldpos));
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed halflambert=0.5*dot(worldnormal,worldlightDir)+0.5;
				fixed3 diffuseColor=tex2D(_RampTex,fixed2(halflambert,halflambert)).rgb*_Color.rgb;
				fixed3 diffuse=_LightColor0.rgb*diffuseColor;
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldpos));
				fixed3 halfDir=normalize(worldlightDir+viewDir);
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldnormal,halfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG
        }
    }
	FallBack "Specular"
}
