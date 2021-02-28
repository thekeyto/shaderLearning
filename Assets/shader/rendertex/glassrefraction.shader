// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/glassrefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BumpMap("Normal Map",2D)="bump"{}
		_Cubemap("Environment Cubemap",Cube)="_Skybox"{}
		_Distortion("Distortion",Range(0,100))=10
		_RefractAmount("Refract Amount",Range(0.0,1.0))=1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }
		GrabPass {"_RefractionTex"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float2 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
				float4 scrPos:TEXCOORD0;
				float4 uv:TEXCOORD1;
				float4 TtoW0:TEXCOORD2;
				float4 TtoW1:TEXCOORD3;
				float4 TtoW2:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumapMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos=ComputeGrabScreenPos(o.pos);
				o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw=TRANSFORM_TEX(v.texcoord,_BumapMap);
				float3 worldpos=mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldnormal=UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal=cross(worldnormal,worldTangent)*v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldnormal.x, worldpos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldnormal.y, worldpos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldnormal.z, worldpos.z);  
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 worldpos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 worldviewDir=normalize(UnityWorldSpaceViewDir(worldpos));
				fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				float2 offset=bump.xy*_Distortion*_RefractionTex_TexelSize.xy;
				i.scrPos.xy=offset+i.scrPos.xy;
				fixed3 refrCol=tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;
				bump=normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
				fixed3 reflDir=reflect(-worldviewDir,bump);
				fixed4 texColor=tex2D(_MainTex,i.uv.xy);
				fixed3 reflCol=texCUBE(_Cubemap,reflDir).rgb*texColor.rgb;
				fixed3 finalColor=reflCol*(1-_RefractAmount)+refrCol*_RefractAmount;
				return fixed4(finalColor,1.0);
            }
            ENDCG
        }
    }
	Fallback "Diffuse"
}
