package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Image;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.BlendingFactor;
import kha.graphics5_.ConstantLocation;

class Main {
  static var screenDarkenUniform: ConstantLocation; 
  static var screenBrightenUniform: ConstantLocation; 

  static var g2: CustomG2;
  static var spriteBuffer: Image;
  static var gameBuffer: Image;

  static var gameProcessingPipeline: PipelineState;

  static function update(): Void {
  }

  static function render(frames: Array<Framebuffer>): Void {
    g2.pipeline = null;
    g2.useCanvas(spriteBuffer);
    g2.begin();
    g2.drawImage(Assets.images.chests, 0, 0);
    g2.end();

    g2.useCanvas(gameBuffer);
    g2.begin();
    g2.pipeline = gameProcessingPipeline;
    gameBuffer.g4.setFloat(screenDarkenUniform, 0.5);
    g2.drawImage(spriteBuffer, 0, 0);
    g2.end();
    g2.pipeline = null;

    g2.useCanvas(frames[0]);
    g2.begin();
    g2.drawScaledImage(
      gameBuffer,
      10,
      10,
      512,
      512
    );
    g2.end();
  }

  static function createImagePipeline(vertShader: VertexShader, fragShader: FragmentShader) {
    var pipeline = new PipelineState();
    var structure = new VertexStructure();
    structure.add("vertexPosition", VertexData.Float3);
    structure.add("vertexUV", VertexData.Float2);
    structure.add("vertexColor", VertexData.Float4);
    pipeline.inputLayout = [structure];
    pipeline.vertexShader = vertShader;
    pipeline.fragmentShader = fragShader;
    pipeline.blendSource = BlendingFactor.BlendOne;
    pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
    pipeline.alphaBlendSource = BlendingFactor.BlendOne;
    pipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
    pipeline.compile();
    return pipeline;
  }

  public static function main() {
    System.start({title: "Project", width: 1024, height: 768}, function (_) {
      spriteBuffer = Image.createRenderTarget(128, 128);
      gameBuffer = Image.createRenderTarget(128, 128);

      g2 = new CustomG2(spriteBuffer);

      gameProcessingPipeline = createImagePipeline(Shaders.painter_image_vert, Shaders.game_processing_frag);

      screenDarkenUniform = gameProcessingPipeline.getConstantLocation('darken');
      screenBrightenUniform = gameProcessingPipeline.getConstantLocation('brighten');

      Assets.loadEverything(function () {
        Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
        System.notifyOnFrames(function (frames) { render(frames); });
      });
    });
  }
}
