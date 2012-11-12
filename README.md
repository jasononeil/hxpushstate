Pushstate
=========

This is a haxe library wrapping the basic Pushstate functionality for Javascript.  It allows you to update the contents of the page, in an AJAX like way, while still updating the browser's history - so Forward, Back and Bookmark continue to function normally.

The aim of this library is to give Haxe/JS very simple access to the underlying browser functionality, and to help with some very basic use-cases.

We do not try to provide a fallback for older browsers currently.

### Installation

    haxelib install pushstate

### Usage

To initialise:
	
	// init() does the following:
	//   Load on window.onload(), so that permanent URLs work
	//   Load when a <a href="#" rel="pushstate">PushState Link</a> is pressed
	//   Load when we get a window.onpopstate() event
	//   Load when a manual change is triggered...
	PushState.init();

To add a listener for pushstate events:

	PushState.addListener(function (url:String) {
		trace ("Load this page: " + url);
	});

To clear listeners:

	PushState.removeListener(myListener);

To manually force a page change:

	// This will trigger all of the event listeners
	// and the change in the address bar.
	// Path is relative to root directory of app
	PushState.push("/go/somewhere/"); 

To associate some data with the state

	PushState.push(url, title, data);

To update the data associated with the current state

	PushState.replace(url, title, data);

### Methods

	PushState.init();
	PushState.addListener();
	PushState.removeListener();
	PushState.push();
	PushState.replace();

### Events

**How to use events:**

Bind:     PushState.myevent.bind(fn:StateData->Void);
Unbind:   PushState.myevent.unbind(fn:StateData->Void);
Dispatch: PushState.myevent.dispatch(state:StateData);

**Events:**

	// After the URL of the page changes (including first page load)
	//  - when page first loads
	//  - clicked a link with [rel='pushstate']
	//  - clicked "forward" or "back" in the browser
	//  - used PushState.push();
	PushState.onPopState

	// Before the URL of the page changes (so you can save data, update 
	// current state etc.)
	PushState.beforePopState


	// After URL changes, or after PushState.replace() has been called
	//  - when page first loads
	//  - clicked a link with [rel='pushstate']
	//  - clicked "forward" or "back" in the browser
	//  - used PushState.push();
	//  - used PushState.replace();
	PushState.onStateChange

	// Before URL changes, or before PushState.replace() has been called
	PushState.beforeStateChange

### Demo

To run the demo:

1. Clone the repository, and run `haxe build.hxml`.  
2. From the 'build' directory, run `nekotools server -rewrite`
3. Open `http://localhost:2000/` in your browser

This demo shows a few things:

 * Listening to pushstate events and updating the page accordingly
 * Using rel="pushstate" to trigger changes to the page's history
 * Using JS events (triggered from a form in this case) to trigger changes to the page's history
 * Using forward and back to trigger changes to the page's history
 * Providing a fallback for cases where the JS wasn't triggered, e.g. Old browsers, deep linking from another site or bookmark, etc.  The way this works:
 	* When the page first loads, we check the URL
 	* If it's not the default, we trigger a pushstate event and let the content update itself.
 	* This ensures the code will work on older browsers, or if someone arrives via a link or bookmark, etc.

[Click here to view the source of the demo](https://github.com/jasononeil/hxpushstate/blob/master/src/demo/Test.hx)

### Notes

Currently this library has 2 dependencies:

 * hsl-pico-1
 * jQuery (from the Haxe std library)

The dependence on jQuery can be removed, or an alternative offered, if there's demand for it.  