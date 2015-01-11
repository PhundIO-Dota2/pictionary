package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.utils.getDefinitionByName;
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	
	public class ColorPicker extends MovieClip {

		var gameAPI:Object;
		var globals:Object;
		
		public function ColorPicker() {
		}
		
		public function setup(api:Object, globals:Object) {
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			
			this.btnRed.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnBlue.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnGreen.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnYellow.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnPink.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnOrange.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnBrown.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnPurple.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.btnTeal.addEventListener(MouseEvent.CLICK, onButtonClicked);

			this.btnStyle1.addEventListener(MouseEvent.CLICK, onButtonClickedStyle);
			this.btnStyle2.addEventListener(MouseEvent.CLICK, onButtonClickedStyle);

			//pictionary_drawer_changed
			//this listener listens to the game event
			this.gameAPI.SubscribeToGameEvent("pictionary_drawer_changed", this.onDrawerChanged);
			this.visible = false;
		}

		public function onDrawerChanged(args:Object) : void {
			//get the ID of the player this UI belongs to
			var pID:int = globals.Players.GetLocalPlayer();
			
			//check of the player in the event is the owner of this UI
			if (args.player_ID == pID) {
				//if we can not afford another ability point, we will make the button fly out of the screen
				this.visible = true;
			}
			else {
				this.visible = false;
			}
		}

        private function onButtonClicked(event:MouseEvent) : void {
			var btnName:String = event.target.name;
			var pID:int = globals.Players.GetLocalPlayer();
			this.gameAPI.SendServerCommand("ColorChange " + btnName.substring(3,btnName.length).toLowerCase());
        }
		
        private function onButtonClickedStyle(event:MouseEvent) : void {
			var btnName:String = event.target.name;
			var pID:int = globals.Players.GetLocalPlayer();
			this.gameAPI.SendServerCommand("StyleChange " + btnName.substring(8,btnName.length));
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
