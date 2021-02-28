using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
[ExecuteInEditMode,ImageEffectAllowedInSceneView]
public class BloomwithCommandBuffer : MonoBehaviour
{
    const int BoxDownPrefilterPass = 0;//亮度过滤Pass
    const int BoxDownPass = 1;//上采样Pass
    const int BoxUpPass = 2;//下采样Pass
    const int ApplyBloomPass = 3;//Bloom应用的Pass
    const int DebugBloomPass = 4;//debugPass

    public bool debug;
    public Shader bloomShader;
    [Range(1, 16)]
    public int iterations = 1;
    [Range(0, 10)]
    public int threshold = 1;
    [Range(0, 1)]
    public float softThreshold = 0.5f;
    [Range(0, 10)]
    public float intensity = 1;
    //控制采样次数
    [NonSerialized]
    Material bloom;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (bloom==null)
        {
            bloom = new Material(bloomShader);
            bloom.hideFlags = HideFlags.HideAndDontSave;
        }
        float knee = threshold * softThreshold;
        Vector4 filter;
        filter.x = threshold;
        filter.y = filter.x - knee;
        filter.z = 2f * knee;
        filter.w = 0.25f / (knee + 0.00001f);
        bloom.SetVector("_Filter", filter);
        bloom.SetFloat("_Intensity", Mathf.GammaToLinearSpace(intensity));
        int width = source.width / 2;
        int height = source.height / 2;
        //使采样的像素减少
        RenderTextureFormat format = source.format;
        RenderTexture[] textures = new RenderTexture[16];
        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, format);
        //使用HDR需要使用正确的格式
        Graphics.Blit(source, currentDestination,bloom,BoxDownPrefilterPass);
        RenderTexture currentSource = currentDestination;
        int i = 1;
        for(;i<iterations;i++)
        {
            width /= 2;
            height /= 2;
            if (height < 2) break;
            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(currentSource, currentDestination,bloom,BoxDownPass);
            currentSource = currentDestination;
        }

        for(i-=2;i>=0;i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination,bloom,BoxUpPass);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }
        if (debug) Graphics.Blit(currentSource, destination, bloom, DebugBloomPass);
        else
        {
            bloom.SetTexture("_SourceTex", source);
            Graphics.Blit(currentSource, destination, bloom, ApplyBloomPass);
        }
        RenderTexture.ReleaseTemporary(currentSource);
    }
}
