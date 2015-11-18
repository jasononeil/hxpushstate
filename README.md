Pushstate
=========

This is a haxe library wrapping the basic Pushstate functionality for Javascript.  It allows you to update the contents of the page, in an AJAX like way, while still updating the browser's history - so Forward, Back and Bookmark continue to function normally.

The aim of this library is to give Haxe/JS very simple access to the underlying browser functionality, and to help with some common use-cases.

We do not try to provide a fallback for older browsers currently.

### Installation

    haxelib install pushstate

### Usage

To initialise (call this before anything else):

	// init() does the following:
	//   Set up the internal state, so the rest of the library will work.
	//   Intercept link clicks on <a rel="pushstate"> or <a class="pushstate"> links and push a new history state.
	//   Intercept form submits on <form class="pushstate"> and push a new history state containing form data.
	//   Add a window.onpopstate event handler so we can respond to history changes.
	//   Optionally trigger an initial event, in case you need to execute something when the page first loads.
	PushState.init( ?basePath="/", ?trigger=true );

To add a listener for pushstate events:

	PushState.addListener(function (url:String) {
		trace ("Load this page: " + url);
	});

To clear listeners:

	PushState.removeListener(myListener);

To manually force a page change:

	// This will trigger all of the event listeners and the change in the address bar.
	// Path is relative to root directory of app
	PushState.push("/go/somewhere/");

To change the URL without creating a new item in the browser history (all listeners will still be triggered):

	PushState.replace("/change/url/and/execute/actions/");

To change the URL without creating a new item in the browser history, and without triggering any listeners:

	PushState.silentReplace("/change/url/without/executing/actions/");

### Methods

	PushState.init(basePath:String,trigger:Bool);
	PushState.addListener(f:String->Void);
	PushState.removeListener(f:String->Void);
	PushState.clearEventListeners();
	PushState.push(url:String);
	PushState.replace(url:String);
	PushState.silentReplace(url:String);

### State data

You can also store some extra data with each history state, on top of just the URL.

	PushState.addListener(f:String->{}->Void);
	PushState.removeListener(f:String->{}->Void);
	PushState.clearEventListeners();
	PushState.push(url:String,data:{});
	PushState.replace(url:String,data:{});
	PushState.silentReplace(url:String,data:{});

Data should be a simple object, something a browser can serialize and deserialize easily.

### Form submission

As well as intercepting link clicks, PushState can intercept form submissions and emulate them.

	<form metod="POST" action="/auth" class="pushstate">
		<input type="text" name="username" />
		<input type="password" name="password" />

		<input type="checkbox" name="subscribe" value="Haxe" />
		<input type="checkbox" name="subscribe" value="PushState" />
		<input type="checkbox" name="subscribe" value="Ufront" />

		<button type="submit" name="type" value="signup">Sign up</button>
		<button type="submit" name="type" value="login">Log In</button>
	</form>

When this form is submitted, pushstate will trigger a call equivalent to:

	PustState.push("/auth", {
		username:["jason"],
		password:["my_little_secret"],
		subcribe:["Haxe","Pushstate"],
		type:["signup"],
		__postData:"username=jason&password=my_little_secret&subscribe=Haxe&subscribe=Pushstate&type=signup"
	});

If the form method was `GET` instead of `POST`, PushState will trigger a call equivalent to:

	PushState.puh("/auth?username=jason&password=my_little_secret&subscribe=Haxe&subscribe=Pushstate&type=signup");

Most common form elements are supported.  If you find any that aren't or that could be improved please file an issue.

A note on submit buttons: if `document.activeElement` is a submit button, the value of that button will be used.
Otherwise, if the first submit button that is a child of the form will be considered the default submit button, and it will be used.

### Demo

To run the demo:

1. Clone the repository, and run `haxe build.hxml`.  
2. From the 'demo/build' directory, run `nekotools server -rewrite`
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
