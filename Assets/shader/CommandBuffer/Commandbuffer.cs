using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
[ExecuteInEditMode]
public class Commandbuffer : MonoBehaviour
{
    private CommandBuffer commandBuffer = null;

    public Material renderMat = null;
    private RenderTexture renderTex = null;
    public Material effectMat = null;

    private Renderer targetEBO = null;
    public GameObject targetOBJ = null;
    public Shader CommandBufferShader = null;


    //value set 
    public Color outLineColor = Color.black;      //renderMat
    public int outLineSize = 4;
    public int BlurSize = 3;

    // Start is called before the first frame update
    void Start()
    {

        if (renderMat && targetOBJ != null)
        {
            //data
            targetEBO = targetOBJ.GetComponent<Renderer>();
            commandBuffer = new CommandBuffer();

            renderTex = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
            commandBuffer.SetRenderTarget(renderTex);
            commandBuffer.ClearRenderTarget(true, true, Color.black);
            commandBuffer.DrawRenderer(targetEBO, renderMat);
        }
        else
        {
            enabled = false;
        }

    }

    private void OnEnable()
    {
        if (renderTex)
        {
            RenderTexture.ReleaseTemporary(renderTex);
            renderTex = null;
        }

        if (commandBuffer != null)
        {
            commandBuffer.Release();
            commandBuffer = null;
        }

    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (renderMat && renderTex && commandBuffer != null)
        {
            //render commandBuffer
            renderMat.SetColor("_outLineColor", outLineColor);
            Graphics.ExecuteCommandBuffer(commandBuffer);
            //声明用来模糊的RT
            RenderTexture temp1 = RenderTexture.GetTemporary(src.width, src.height, 0);
            RenderTexture temp2 = RenderTexture.GetTemporary(src.width, src.height, 0);

            effectMat.SetInt("_outLineSize", outLineSize);
            //先进行一次模糊，因为无法直接用循环叠加commandBuffer
            Graphics.Blit(renderTex, temp1, effectMat, 0);
            Graphics.Blit(temp1, temp2, effectMat, 1);
            //设置模糊次数
            for (int i = 0; i < BlurSize; i++)
            {
                Graphics.Blit(temp2, temp1, effectMat, 0);
                Graphics.Blit(temp1, temp2, effectMat, 1);
            }
            //将模糊后的图片减去commandBuffer中的实心剪影
            effectMat.SetTexture("_renderTex", renderTex);
            Graphics.Blit(temp2, temp1, effectMat, 2);
            //后期处理，叠入渲染成果
            effectMat.SetTexture("_outLineTex", temp1);
            Graphics.Blit(src, dest, effectMat, 3);
            //释放RT
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
