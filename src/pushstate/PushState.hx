/****
* Copyright (c) 2013 Jason O'Neil
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
****/

package pushstate;

#if detox
	using Detox;
#else 
	import haxe.ds.Option;
	import js.JQuery;
	import js.JQuery.JQueryHelper.*;
#end

import js.Browser.window in win;
import js.Browser.document in doc;
import js.html.PopStateEvent;
import js.html.Event;
import pushstate.History;

/**
	PushState

	This class is used to access, trigger and listen to the HTML5 History API.
	This allows you to trigger changes to the pages content using Javascript,
	and update the URL of the page so that browser features such as bookmarking,
	clicking "back" or "forward", and sharing links still work.
	
	This library is accessed using static methods, and accesses only part
	of the History API for simplicity.  Full support may be added later.
	
	This library does not fix any cross-browser issues or provide a #hash fallback
	for older browsers.  I've tried to keep it lightweight and simple.
**/
class PushState 
{
	static var basePath:String;
	static var preventers:Array<Preventer>;
	static var listeners:Array<Listener>;
	static var history:js.html.History;

	public static var currentPath:String;
	public static var currentState:Dynamic;

	/** 
		Initialize the PushState API for the current page.
		
		Basically it:

		 - initialize the internal state
		 - gets links with rel="pushstate" to use the PushState API
		 - launches an initial onStateChange event so you can load your first page
		 - listens to "onpopstate" event, so we can detect browser "Back" clicks etc.
		
		It will use either Detox or jQuery to run these at startup. (Detox if you're using it already, jQuery otherwise)

		In general you should call this before using any other part of the API.
	**/
	public static function init(?basePath = ""):Void {
		listeners = [];
		preventers = [];
		history = win.history;
		PushState.basePath = basePath;

		// Load on window.onload(), so that permanent URLs work
		#if detox 
			Detox.ready(function () {
				// Trigger Events
				handleOnPopState(null);

				// Load when a <a href="#" rel="pushstate">PushState Link</a> is pressed
				Detox.document.on("click", "a[rel=pushstate]", function (e) {
					var link:DOMNode = cast e.target;
					while (link.tagName() != "a" && link.parent() != null) {
						link = link.parent();
					}
					if (link.tagName() == "a") {
						push(link.attr("href"));
						e.preventDefault();
					}
				});
				
				// Load when we get a window.onPopState() event
				win.onpopstate=handleOnPopState;
			});
		#else 
			J(win).ready(function (e) {
				// Trigger Events
				handleOnPopState(null);

				// Load when a <a href="#" rel="pushstate">PushState Link</a> is pressed
				J(doc.body).delegate("a[rel=pushstate]", "click", function (e) {
					push(JTHIS.attr("href"));
					e.preventDefault();
				});
				
				// Load when we get a window.onPopState() event
				win.onpopstate = handleOnPopState;
			});
		#end
	}

	static function handleOnPopState(e:PopStateEvent) {
		// Read the path from the document location
		var path:String = stripURL(doc.location.pathname);
		var state = (e!=null) ? e.state : null;

		// Check that no preventers are blocking us
		if (e!=null) {
			for (p in preventers) {
				if ( !p(path, e.state) ) {
						e.preventDefault();
					history.replaceState( currentState, "", currentPath );
					return;
				}
			}
		}

		currentPath = path;
		currentState = state;

		dispatch(path, state);
		return;
	}

	static function stripURL(path:String) {
		// strip the basePath from the path, if it is present
		if (path.substr(0,basePath.length) == basePath) {
			path = path.substr(basePath.length);
		}
		return path;
	}

	/**
		Add event listener

		Event listeners take the form `function (url:String, state:Dynamic):Void`

		Alternatively a simple form `function (url:String):Void` can be used.

		This will return the Listener that you added, which is handy for removing it later.
	**/
	public static function addEventListener(?l:Listener, ?s:SimpleListener):Listener {
		if ( l!=null ) {
			listeners.push( l );
		}
		else if ( s!=null ) {
			l = function( url, _ ) return s( url );
			listeners.push( l );
		}
		return l;
	}

	/** 
		Remove a specific event listener 
	**/
	public static function removeEventListener(l:Listener):Void {
		listeners.remove(l);
	}

	/** 
		Remove all event listeners 
	**/
	public static function clearEventListeners():Void {
		while (listeners.length > 0) {
			listeners.pop();
		}
	}

	/** 
		Add a preventer

		A preventer is a simple function that takes the form `function (url:String, state:Dynamic):Bool`

		If it returns false, will prevent the page history from being changed and any listeners from being fired.

		Alternatively, a simpler `function (url:String):Bool` syntax may be used.

		If you wish merely to defer the change in state, you can keep the url and state data and use it again with:
		  `Pushstate.push( url, state );`
		at a later time.

		**Note**: If a preventer cancels a "popstate" event from the browser (eg. they clicked 'back'), your history can get messed up.
		We can't cancel the event properly, so we prevent the handlers from firing and we use `history.replaceState` to reset the URL.  
		This will overwrite that URL in the history, which may not be the behaviour you want.  If you have a suggested workaround, please let me know!

		This returns the preventer added, so you can remove it later.
	**/
	public static function addPreventer(?p:Preventer, ?s:SimplePreventer):Preventer {
		if (p!=null) {
			preventers.push( p );
		}
		else if (s!=null) {
			p = function( url, _ ) return s( url );
			preventers.push( p );
		}
		return p;
	}

	/** Remove a specific preventer */
	public static function removePreventer(p:Preventer):Void {
		preventers.remove(p);
	}

	/** Remove all preventers */
	public static function clearPreventers():Void {
		while (preventers.length > 0) {
			preventers.pop();
		}
	}

	static function dispatch(url:String, state:Null<Dynamic>) {
		for (l in listeners) {
			l(url, state);
		}
	}

	/**
		Use this to manually change the URL of the page without reloading.
		
		If any preventer functions you have added return false, nothing will happen.

		Otherwise, each of your listeners will be executed and the page history / url will be updated.

		Will return true if the push was successful (not prevented), or false if it was prevented.
		
		**URL**

		The new history entry's URL is given by this parameter. Note that the browser won't attempt to load this URL after a call to pushState(), but it might attempt to load the URL later, for instance after the user restarts her browser. The new URL does not need to be absolute; if it's relative, it's resolved relative to the current URL. The new URL must be of the same origin as the current URL; otherwise, pushState() will throw an exception. This parameter is optional; if it isn't specified, it's set to the document's current URL.

		**STATE**

		The state object is a JavaScript object which is associated with the new history entry created by pushState(). Whenever the user navigates to the new state, a popstate event is fired, and the state property of the event contains a copy of the history entry's state object.
		The state object can be anything that can be serialized. Because Firefox saves state objects to the user's disk so they can be restored after the user restarts her browser, we impose a size limit of 640k characters on the serialized representation of a state object. If you pass a state object whose serialized representation is larger than this to pushState(), the method will throw an exception. If you need more space than this, you're encouraged to use sessionStorage and/or localStorage.
	**/
	public static function push(url:String, ?state:Dynamic):Bool {
		if (state==null) state = {};
		for (p in preventers) {
			if (!p(url,state)) return false;
		}
		history.pushState(state, "", url);
		currentPath = url;
		currentState = state;
		dispatch(url,state);
		return true;
	}

	/**
		Identical to `push()` except this changes the URL of the page without creating a new History item.

		So for instance:
		-
		 - You are on the page "/kittents"
		 - You use PushState.push("/puppies")
		 - You are now on "/puppies", if you were to press back you would be on "kittens"
		 - You now use PushState.replace("/aliens")
		 - The URL is not "/aliens", but if you were to press back it would go to "/kittens" (NOT "/puppies"), because a new History item was not created.

		Will return true if the request was successful (not prevented) or false if it was prevented.
	**/
	public static function replace(url:String, ?state:Dynamic):Bool {
		if (state==null) state = Dynamic;
		for (p in preventers) {
			if (!p(url,state)) return false;
		}
		history.replaceState(state, "", url);
		currentPath = url;
		currentState = state;
		dispatch(url,state);
		return true;
	}
}

typedef Listener = String->Dynamic->Void;
typedef Preventer = String->Dynamic->Bool;
typedef SimpleListener = String->Void;
typedef SimplePreventer = String->Bool;