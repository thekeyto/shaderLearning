using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class edgeDetection : PostEffectsBase
{
    public Shader edgeShader;
    private Material edgeMaterial;
    public Material material
    {
        get
        {
            edgeMaterial = CheckShaderAndCreateMaterial(edgeShader, edgeMaterial);
            return edgeMaterial;
        }
    }
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1.0f;
    //用于控制采样距离
    public float sensitivityDepth = 1.0f;
    public float sensitivityNormals = 1.0f;
    //控制灵敏度
    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
            Graphics.Blit(src, dest, material);
        }
        else Graphics.Blit(src, dest);
    }
}