#include "Lighting.cginc"
Shader "Unity Shaders Book/"
{
	Properties
	{
		_Diffuse("Diffuse",color) = {1,1,1,1}
	}
	Subshader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Diffuse
			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};
			v2f vert(a2v v)
			{
				v2f o;
				o.pos=mul(UNITY_MARTRIX_MVP,v.Vertex);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal=nomalize(mul(v.normal,(float3x3)_World2Object));
				fixed3 worldLight=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));
				o.color=ambient+diffuse;
				return o;
			}
			fixed4 frag(v2f i): SV_TARGET
			{
				return fixed4(i.color,1.0);
			}
			FallBack "Diffuse"
	}
}