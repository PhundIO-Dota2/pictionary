package  {
	
	import flash.display.MovieClip;
	
	
	public class ColorBoxBackground extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		
		public function ColorBoxBackground() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object) {
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			
			// replace stuff with valve components.
			
		}
		
		public function screenResize(stageW:int, stageH:int, xScale:Number, yScale:Number, wide:Boolean){
			this.x = stageW/2;
			this.y = stageH/2; //A bit on top of the middle to show the chat
					 
			//Now we just set the scale of this element, because these parameters are already the inverse ratios
			this.scaleX = xScale;
			this.scaleY = yScale;
		}
		
		//Parameters: 
			//mc - The movieclip to replace
			//type - The name of the class you want to replace with
			//keepDimensions - Resize from default dimensions to the dimensions of mc (optional, false by default)
		public function replaceWithValveComponent(mc:MovieClip, type:String, keepDimensions:Boolean = false) : MovieClip {
			var parent = mc.parent;
			var oldx = mc.x;
			var oldy = mc.y;
			var oldwidth = mc.width;
			var oldheight = mc.height;
			
			var newObjectClass = getDefinitionByName(type);
			var newObject = new newObjectClass();
			newObject.x = oldx;
			newObject.y = oldy;
			if (keepDimensions) {
				newObject.width = oldwidth;
				newObject.height = oldheight;
			}
			
			parent.removeChild(mc);
			parent.addChild(newObject);
			
			return newObject;
		}
		
	}
	
}
