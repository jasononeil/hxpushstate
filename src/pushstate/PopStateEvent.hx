package pushstate;

@:native("PopStateEvent")
extern class PopStateEvent extends Event {
	public var state (default,never) : Dynamic;
	public function initPopStateEvent(typeArg:String, canBubbleArg:Bool, cancelableArg:Bool, stateArg:Dynamic) : Void;
}

@:native("Event")
extern class Event extends Object {
	public static inline var CAPTURING_PHASE:Int = 1;
	public static inline var AT_TARGET:Int = 2;
	public static inline var BUBBLING_PHASE:Int = 3;
	
	public var type (default,never) : String;
	public var target (default,never) : EventTarget;
	public var currentTarget (default,never) : EventTarget;
	public var eventPhase (default,never) : Int;
	public var bubbles (default,never) : Bool;
	public var cancelable (default,never) : Bool;
	public var timeStamp (default,never) : Int;
	public var namespaceURI (default,never) : String;
	public var defaultPrevented (default,never) : Bool;
	
	public function stopPropagation() : Void;
	public function preventDefault() : Void;
	public function initEvent(eventTypeArg:String, canBubbleArg:Bool, cancelableArg:Bool) : Void;
	public function stopImmediatePropagation() : Void;
	public function initEventNS(namespaceURIArg:String, eventTypeArg:String, canBubbleArg:Bool, cancelableArg:Bool) : Void;
}

@:native("EventTarget")
extern class EventTarget extends Object {
	public function addEventListener(type:String, listener:EventListener<Dynamic>, useCapture:Bool) : Void;
	public function removeEventListener(type:String, listener:EventListener<Dynamic>, useCapture:Bool) : Void;
	public function dispatchEvent(evt:Event) : Bool;
	public function addEventListenerNS(namespaceURI:String, type:String, listener:EventListener<Dynamic>, useCapture:Bool) : Void;
	public function removeEventListenerNS(namespaceURI:String, type:String, listener:EventListener<Dynamic>, useCapture:Bool) : Void;
}

typedef EventListener<T:Event> = T->Void;