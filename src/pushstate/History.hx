package pushstate;

@:native("History")
extern interface History {
	public var length (default,never) : Int;
	public function go(?delta:Int) : Void;
	public function back() : Void;
	public function forward() : Void;
	public function pushState(data:Dynamic, title:String, ?url:String) : Void;
	public function replaceState(data:Dynamic, title:String, ?url:String) : Void;
}