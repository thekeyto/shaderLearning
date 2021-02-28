Shader "LZ/effectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _outLineSize("outLineSize",int)=4
        _outLineTex("outLineTex",2D)="black"{}
        _renderTex("renderTex",2D)="black"{}
    }

    //Founction    
    CGINCLUDE

    float _outLineSize;
    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    struct a2v{
        float4 vertex:POSITION;
        float2 uv:TEXCOORD0;
    };
    struct v2f{
        float4 pos:SV_POSITION;
        float2 uv[5]:TEXCOORD0;
    };

    v2f vert_heng(a2v v){
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float2 uv=v.uv;
        o.uv[0] = uv;
        o.uv[1] = uv + float2(1,0) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[2] = uv + float2(-1,0) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[3] = uv + float2(2,0) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[4] = uv + float2(-2,0) * _outLineSize * _MainTex_TexelSize.xy;
        return o;
    }

    v2f vert_shu(a2v v){
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float2 uv=v.uv;
        o.uv[0] = uv;
        o.uv[1] = uv + float2(0,1) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[2] = uv + float2(0,-1) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[3] = uv + float2(0,2) * _outLineSize * _MainTex_TexelSize.xy;
        o.uv[4] = uv + float2(0,-2) * _outLineSize * _MainTex_TexelSize.xy;
        return o;
    }

    fixed4 frag(v2f i):SV_TARGET{
        float3 col = tex2D(_MainTex,i.uv[0]).xyz *0.4026;
        float3 col1 = tex2D(_MainTex,i.uv[1]).xyz *0.2442;
        float3 col2 = tex2D(_MainTex,i.uv[2]).xyz *0.2442;
        float3 col3 = tex2D(_MainTex,i.uv[3]).xyz *0.0545;
        float3 col4 = tex2D(_MainTex,i.uv[4]).xyz *0.0545;
        float3 finalCol = col+col1+col2+col3+col4;
        return fixed4(finalCol,1.0);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always


        
        pass{
            CGPROGRAM
            #include"UnityCG.cginc"
            #pragma vertex vert_heng
            #pragma fragment frag 
            ENDCG
        }

        pass{
            CGPROGRAM
            #include"UnityCG.cginc"
            #pragma vertex vert_shu
            #pragma fragment frag 
            ENDCG
        }

//pass 2 ---renderTex------------------------------------------------------------------------------
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f1
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f1 vert (appdata v)
            {
                v2f1 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //sampler2D _MainTex;
            sampler2D _renderTex;


            fixed4 frag (v2f1 i) : SV_Target
            {
                
                float3 col= tex2D(_MainTex,i.uv).xyz;
                float3 commandCol=tex2D(_renderTex,i.uv).xyz;
                float3 finalCol=col-commandCol;
                return fixed4(finalCol,1.0);
            }
            ENDCG
        }


//pass3 add outlineTex--------------------------------------------------------------------------------------------------

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f2
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f2 vert (appdata v)
            {
                v2f2 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //sampler2D _MainTex;
            sampler2D _outLineTex;

            fixed4 frag (v2f2 i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 lineCol=tex2D(_outLineTex,i.uv);
                col.xyz+=lineCol.xyz;
                return col;
            }
            ENDCG
        }
    }
}
