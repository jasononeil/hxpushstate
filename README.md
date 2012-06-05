Pushstate
=========

This is a haxe library wrapping the basic Pushstate functionality for Javascript.  It allows you to update functionality

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

