Shader "Unlit/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Brightness("Brightness",Float)=1
		_Saturation("Saturation",Float)=1
		_Contrast("Contrast",FLoat)=1
    }
    SubShader
    {
        Pass
        {
			ZTest Always Cull Off ZWrite Off//防止挡住后面被渲染的物体
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

            struct v2f
            {
                float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderTex=tex2D(_MainTex,i.uv);
				//得到对于按屏幕的采样结果
				fixed3 finalColor=renderTex.rgb*_Brightness;
				//乘以亮度系数
				fixed luminance=0.2125*renderTex.r+0.7154*renderTex.g+0.0721*renderTex.b;
				//通过乘以特定的系数得到亮度值
				fixed3 luminanceColor=fixed3(luminance,luminance,luminance);
				finalColor=lerp(luminanceColor,finalColor,_Saturation);
				//进行插值
				fixed3 avgColor=fixed3(0.5,0.5,0.5);
				finalColor=lerp(avgColor,finalColor,_Contrast);
				return fixed4(finalColor,renderTex.a);
            }
            ENDCG
        }
    }
	FallBack Off
}
