// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/HalfLambert"
{
	Properties
	{
		_Diffuse ("Diffuse",Color)=(1,1,1,1)//控制漫反射的颜色，初始设置为白色
	}
	SubShader
	{
		Pass
		{
			Tags{"LightModel"="ForwardBase"}//用于定义pass在unity光照流水线中的角色
	
			CGPROGRAM
	
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//把模型顶点的法线信息存储在normal变量中
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldnormal:TEXCOORD0;
				//把顶点着色器计算得到的光照颜色传递给片元着色器
			};
			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//完成把顶点位置从模型空间转换到裁剪空间
				o.worldnormal=mul(v.normal,(float3x3)unity_WorldToObject);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldnormal=normalize(i.worldnormal);
				fixed3 worldlightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*(0.5*dot(worldnormal,worldlightDir)+0.5);
				fixed3 color=ambient+diffuse;
				return fixed4(color,1.0);
			}
			ENDCG
		}	 
	}
	FallBack "Diffuse"
}