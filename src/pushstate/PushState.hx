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

import js.JQuery;
import hsl.haxe.DirectSignaler;
import pushstate.History;
import pushstate.PopStateEvent;

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
	static var history:History;
	static var basePath:String;

	/**
	* onStateChange is fired when the URL of the page changes, so
	*  - When the page first loads
	*  - When a link is clicked with the rel='pushstate' attribute
	*  - Back or Forward is clicked in the browser
	*  - PushState.push() is called manually
	* Listen to this event to be able to change your pages content
	* as the URL is updated.
	*/
	static public var onStateChange:DirectSignaler<StateData>;

	function new()
	{
		// HSL Signalers need to be tied to an instance
		// Hence needing to have a singleton.
		PushState.onStateChange = new DirectSignaler(this);
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
	public static function init(?basePath = "/")
	{
		// Set up the instance
		inst = new PushState();
		history = Reflect.field(js.Lib.window, "history");
		PushState.basePath = basePath;

		// Load on window.onload(), so that permanent URLs work
		new JQuery(js.Lib.document).ready(function (e) {
			// Trigger Events
			handleOnPopState(null);

			// Load when a <a href="#" rel="pushstate">PushState Link</a> is pressed
			new JQuery("a[rel=pushstate]").click(function (e) {
				push(JQuery.cur.attr("href"));
				e.preventDefault();
			});
			
			// Load when we get a window.onPopState() event
			Reflect.setField("window", "onpopstate", handleOnPopState);
		});
	}

	static function handleOnPopState(e:Dynamic)
	{
		// Read the path from the document location
		var path:String = untyped __js__('document.location.pathname');
		
		// Get the relevant part of the URL
		path = stripURL(path);
		
		// Pass back and launch event
		var state:StateData = {
			url: path
		};
		PushState.onStateChange.dispatch(state);
	}

	static function stripURL(path:String)
	{
		// strip the basePath from the path, if it is present
		if (path.substr(0,basePath.length) == basePath)
		{
			path = path.substr(basePath.length);
		}
		return path;
	}

	/**
	* push()
	* Use this to manually change the URL of the page without reloading.
	* An onStateChange event is dispatched, which you can use to load 
	* the appropriate content.
	*/
	public static function push(url:String)
	{
		var state:StateData = {
			url: stripURL(url)
		};
		history.pushState({}, "", url);
		PushState.onStateChange.dispatch(state);
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
	public static function replace(url:String)
	{
		var state:StateData = {
			url: stripURL(url)
		};
		history.pushState({}, "", url);
		PushState.onStateChange.dispatch(state);
	}
}

/**
* StateData
* 
* Contains data about the current History state.  For now we'll just use "url",
* but in future may support "title" and "data" from the browser History API.
*/
typedef StateData = {
	var url:String;
	// Future: support these also?
	//var data:Dynamic
	//var title:String
}