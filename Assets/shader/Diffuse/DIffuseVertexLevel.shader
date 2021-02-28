// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "DiffuseVertexLevel"
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
				fixed3 color : COLOR;
				//把顶点着色器计算得到的光照颜色传递给片元着色器
			};
			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//完成把顶点位置从模型空间转换到裁剪空间
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldnormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));;
				//_World2Object是模型空间到时间空间变换的逆矩阵
				fixed3 worldlight = normalize(_WorldSpaceLightPos0.xyz);
				//得到光源方向
				//由于颜色数值范围为[0,1],使用normalize对象量进行归一化
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldnormal,worldlight));
				//使用saturate对计算结果进行取大于0处理
				o.color=ambient+diffuse;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}	 
	}
	FallBack "Diffuse"
}
