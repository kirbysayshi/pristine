package
{
	import com.Flight.ThreeDee;
	
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	
	import org.ascollada.utils.FPS;

	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="31")]
	public class Flight extends MovieClip
	{
		public var threeD:ThreeDee;
		
		public function Flight()
		{
			var fps:FPS = new FPS();
			threeD = new ThreeDee(this.stage);
			this.addChild(threeD);
			this.addChild(fps);
			//stage.displayState = "fullScreen";
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
	}
}