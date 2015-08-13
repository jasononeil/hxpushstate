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

import js.Browser.*;
import js.html.*;
import pushstate.History;
using StringTools;

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
	static var ignoreAnchors:Bool = true;
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
		 - listens to "onpopstate" event, so we can detect browser "Back" clicks etc.
		 - gets links with `rel="pushstate"` or `class="pushstate"` to use the PushState API
		 - if `triggerFirst` is true, launches an initial `onStateChange` event so you can load your first page

		You should call `init()` before using any other part of the API.

		@param basePath - The base path of the app, this will be stripped from the raw URL value before passing to handlers.
		@param triggerFirst - Should we trigger a handler on the initial page load.  Default is true.
		@param ignorAnchors - Will clicking an anchor link (or switching between anchors using history) be ignored? Default is true.
	**/
	public static function init(?basePath = "", ?triggerFirst:Bool=true, ?ignoreAnchors:Bool=true):Void {
		listeners = [];
		preventers = [];
		history = window.history;
		PushState.basePath = basePath;
		PushState.ignoreAnchors = ignoreAnchors;

		// This event if not supported by IE8, but then neither is the History.pushstate API.
		document.addEventListener("DOMContentLoaded", function(event) {
			// Intercept <a href="..." rel="pushstate"> clicks.
			// TODO: check, does this break keyboard navigation?
			document.addEventListener("click",function(e:MouseEvent) {
				if (e.button==0 && !e.metaKey && !e.ctrlKey) {
					var link:AnchorElement = null,
					    node:Node = Std.instance(e.target,Node);
					while (link==null && node!=null) {
						link = Std.instance(node,AnchorElement);
						node = node.parentNode;
					}
					if (link!=null && (link.rel=="pushstate" || hasClass(link,"pushstate"))) {
						push(link.pathname+link.search+link.hash);
						e.preventDefault();
					}
				}
			});

			// Intercept <form rel="pushstate"> submits.
			document.addEventListener("submit",function (e:Event) {
				var form = Std.instance(e.target,FormElement);
				if (hasClass(form,"pushstate")) {
					e.preventDefault();
					interceptFormSubmit(form);
				}
			});

			// Listen to the onpopstate event.
			window.onpopstate = handleOnPopState;

			// Trigger an initial load.
			if (triggerFirst) {
				handleOnPopState(null);
			}
			else {
				currentPath = stripURL(document.location.pathname+document.location.search+document.location.hash);
			}
		});
	}

	inline static function hasClass(elm:Element, className:String) {
		return elm.classList.contains( className );
	}

	static function interceptFormSubmit(form:FormElement) {
		var params = [];
		function addParam(name:String, val:String) {
			if (name==null || name=="")
				return;
			params.push({ name:name, val:val });
		}
		// Serialization method adapted from http://stackoverflow.com/a/11661219/180995
		for (i in 0...form.elements.length) {
			var elm = form.elements.item(i);
			switch elm.nodeName.toUpperCase() {
				// TODO: only include submit button if it was the one that was clicked.
				// TODO: investigate using https://developer.mozilla.org/en-US/docs/Web/API/FormData, it seems to be IE10 only but we may require that anyway.
				case 'INPUT':
					var input = Std.instance(elm,InputElement);
					switch input.type {
						case 'text','hidden','password','submit','search','email','url','tel','number','range','date','month','week','time','datetime','datetime-local','color': addParam(input.name, input.value);
						case 'checkbox','radio' if (input.checked): addParam(input.name, input.value);
						case 'file':
					}
				case 'TEXTAREA':
					var ta = Std.instance(elm,TextAreaElement);
					addParam(ta.name, ta.value);
				case 'SELECT':
					var select = Std.instance(elm,SelectElement);
					switch select.type {
						case 'select-one': addParam(select.name, select.value);
						case 'select-multiple':
							for (j in 0...select.options.length) {
								var option:OptionElement = cast select.options[j];
								if (option.selected) {
									addParam(select.name, option.value);
								}
							}
					}
				case 'BUTTON':
					var button = Std.instance(elm,ButtonElement);
					switch button.type {
						case 'submit': addParam(button.name, button.value);
					}
			}
		}
		var paramString = params.map(function(p) return '${p.name}=${p.val.urlEncode()}').join("&");
		if ( form.method.toUpperCase()=="POST" ) {
			var paramsObj = {};
			for (p in params) {
				if (Reflect.hasField(paramsObj,p.name))
					(Reflect.field(paramsObj,p.name):Array<String>).push(p.val);
				else
					Reflect.setField(paramsObj, p.name, [p.val]);
			}
			Reflect.setField( paramsObj, "__postData", paramString );
			push(form.action,paramsObj);
		}
		else {
			push(form.action+"?"+paramString,null);
		}
	}

	static function handleOnPopState(e:PopStateEvent) {
		// Read the path from the document location
		var path = stripURL(document.location.pathname+document.location.search+document.location.hash);
		var state = (e!=null) ? e.state : null;

		// If this is just a hash change, and we're ignoring anchors, then don't trigger anything.
		if (ignoreAnchors && path==currentPath) {
			return;
		}

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

		dispatch(currentPath, currentState);
		return;
	}

	static function stripURL(path:String) {
		// strip the basePath from the path, if it is present
		if (path.substr(0,basePath.length) == basePath)
			path = path.substr(basePath.length);
		// Strip the anchor if we are ignoring them.
		if (ignoreAnchors && path.indexOf("#")>-1)
			path = path.substr(0,path.indexOf("#"));
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
		var strippedURL = stripURL(url);
		if (state==null) state = {};
		for (p in preventers) {
			if (!p(strippedURL,state)) return false;
		}
		history.pushState(state, "", url);
		currentPath = strippedURL;
		currentState = state;
		dispatch(strippedURL,state);
		return true;
	}

	/**
		Identical to `push()` except this changes the URL of the page without creating a new History item.

		So for instance:

		 - You are on the page "/kittens"
		 - You use PushState.push("/puppies")
		 - You are now on "/puppies", if you were to press back you would be on "kittens"
		 - You now use PushState.replace("/aliens")
		 - The URL is not "/aliens", but if you were to press back it would go to "/kittens" (NOT "/puppies"), because a new History item was not created.

		Will return true if the request was successful (not prevented) or false if it was prevented.
	**/
	public static function replace(url:String, ?state:Dynamic):Bool {
		var strippedURL = stripURL(url);
		if (state==null) state = Dynamic;
		for (p in preventers) {
			if (!p(strippedURL,state)) return false;
		}
		history.replaceState(state, "", url);
		currentPath = strippedURL;
		currentState = state;
		dispatch(strippedURL,state);
		return true;
	}
}

typedef Listener = String->Dynamic->Void;
typedef Preventer = String->Dynamic->Bool;
typedef SimpleListener = String->Void;
typedef SimplePreventer = String->Bool;
