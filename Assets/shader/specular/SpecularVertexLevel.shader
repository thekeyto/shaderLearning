﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SpecularVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		//控制高光反射颜色
		_Gloss("Gloss",Range(8.0,256))=20
		//控制高光区域的大小
    }
    SubShader
    {

        Pass
        {
			Tags { "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
				float3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldnormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//将法线转换为世界空间
				fixed3 worldlightDir=normalize(_WorldSpaceLightPos0.xyz);
				//得出入射光方向
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldnormal,worldlightDir));
				//计算漫反射光
				fixed3 reflectDir=normalize(reflect(-worldlightDir,worldnormal));
				//计算反射方向
				fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				//计算视角方向
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
				o.color=ambient+diffuse+specular;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1.0);
            }
            ENDCG
        }
    }
	FallBack "Specular"
}
