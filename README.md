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

To change the URL without creating a new item in the browser history

	PushState.replace("/go/somewhere/else/"); 

### Methods

	PushState.init(basePath:String);
	PushState.addListener(f:String->Void);
	PushState.removeListener(f:String->Void);
	PushState.clearEventListeners();
	PushState.push(url:String);
	PushState.replace(url:String);

### Demo

To run the demo:

1. Clone the repository, and run `haxe build.hxml`.  
2. From the 'build' directory, run `nekotools server -rewrite`
3. Open `http://localhost:2000/` in your browser

This demo shows a few things:

- Listening to PushState events and updating the page accordingly
- Using PushState links to trigger changes to the page's history
- Using PushState forms to read form data and save it in the page's history
- Using PushState forms to keep track of an upload.
- Using forward and back to trigger changes to the page's history.
- Using a Preventer to stop the user from changing the URL.
- Providing a fallback for cases where the JS wasn't triggered, e.g. Old browsers, deep linking from another site or bookmark, etc.  The way this works:
	- When the page first loads, we trigger a PushState event and let the content update itself.
	- This ensures the code will work on older browsers, or if someone arrives via a link or bookmark, etc.

[Click here to view the source of the demo](https://github.com/jasononeil/hxpushstate/blob/master/demo/Test.hx)
