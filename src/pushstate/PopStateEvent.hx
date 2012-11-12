/****
* Copyright (c) 2012 Jason O'Neil
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
****/

package pushstate;


#if xirsys_stdjs
	import js.w3c.level3.Events;
#else 
	@:native("Object")
	extern class Object {}

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
#end

@:native("PopStateEvent")
extern class PopStateEvent extends Event {
	public var state (default,never) : Dynamic;
	public function initPopStateEvent(typeArg:String, canBubbleArg:Bool, cancelableArg:Bool, stateArg:Dynamic) : Void;
}