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
	import js.JQuery;
	import js.JQuery.JQueryHelper.*;
#end

import js.Browser.window in win;
import js.Browser.document in doc;
import js.html.PopStateEvent;
import pushstate.History;

/**
* PushState
* This class is used to access, trigger and listen to the HTML5 History API.
* This allows you to trigger changes to the pages content using Javascript,
* and update the URL of the page so that browser features such as bookmarking,
* clicking "back" or "forward", and sharing links still work.
* 
* This library is accessed using static methods, and accesses only part
* of the History API for simplicity.  Full support may be added later.
* 
* This library does not fix any cross-browser issues or provide a #hash fallback
* for older browsers.  I've tried to keep it lightweight and simple.
*/
class PushState 
{
	static var inst:PushState;
	static var basePath:String;
	static var listeners:Array<String->Void>;

	static var history:js.html.History;
	
	function new() {
		listeners = [];
	}

	/** 
	* init()
	* This initialises the PushState API for the current page.
	* Basically it:
	*  - sets up the PushState object
	*  - gets links with rel="pushstate" to use the PushState API
	*  - launches an initial onStateChange event so you can load your first page
	*  - listens to "onpopstate" event, so we can detect browser "Back" clicks etc.
	* In general you should call this before using any other part of the API.
	*/
	public static function init(?basePath = "/") {
		// Set up the instance
		inst = new PushState();
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

	static function handleOnPopState(e:Dynamic) {
		// Read the path from the document location
		var path:String = doc.location.pathname;
		
		// Get the relevant part of the URL
		path = stripURL(path);
		
		// Pass back and launch event
		dispatch(path);
	}

	static function stripURL(path:String) {
		// strip the basePath from the path, if it is present
		if (path.substr(0,basePath.length) == basePath) {
			path = path.substr(basePath.length);
		}
		return path;
	}

	public static function addEventListener(f:String->Void) {
		listeners.push(f);
	}

	public static function removeEventListener(f:String->Void) {
		listeners.remove(f);
	}

	public static function clearEventListeners() {
		while (listeners.length > 0) {
			listeners.pop();
		}
	}

	static function dispatch(url:String) {
		for (l in listeners) {
			l(url);
		}
	}

	/**
	* push()
	* Use this to manually change the URL of the page without reloading.
	* An onStateChange event is dispatched, which you can use to load 
	* the appropriate content.
	*/
	public static function push(url:String) {
		history.pushState({}, "", url);
		dispatch(url);
	}

	/**
	* replace()
	* This changes the URL of the page without creating a new History item.
	* So for instance
	*  - You are on the page "/kittents"
	*  - You use PushState.push("/puppies")
	*  - You are now on "/puppies", if you were to press back you 
	*    would be on "kittens"
	*  - You now use PushState.replace("/aliens")
	*  - The URL is not "/aliens", but if you were to press back
	*    it would go to "/kittens", because a new History item
	*    was not created.
	*/
	public static function replace(url:String) {
		history.pushState({}, "", url);
		dispatch(url);
	}
}