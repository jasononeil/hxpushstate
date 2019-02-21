Pushstate
=========

Haxe utilities for working with the HTML5 history API.

Or: Change the URL in your single-page-app without breaking the back button.

The aim of this library is to provide an easy API for responding to page changes in a single page app using the HTML5 History `pushState()`, `replaceState()` and `onpopstate` features.

We do not try to provide a fallback for older browsers currently.

### Installation

	haxelib install pushstate

And then compile with:

	-lib pushstate

### Usage

	import pushstate.PushState;

- Init
	- `PushState.init(?basePath, ?trigger, ?ignoreAnchors)`
- Listeners
	- `PushState.addEventListener(fn)`
	- `PushState.removeEventListener(fn)`
	- `PushState.clearEventListeners()`
- Preventers
	- `PushState.addPreventer(fn)`
	- `PushState.removePreventer(fn)`
	- `PushState.clearPreventers()`
- Manual Changes
	- `PushState.push(url, ?state, ?uploads)`
	- `PushState.replace(url, ?state, ?uploads)`
	- `PushState.silentReplace(url, ?state, ?uploads)`

#### Init

Call `PushState.init()` before anything else:

	PushState.init( ?basePath="/", ?trigger=true, ?ignoreAnchors=true );

This will:

 - Set up the internal state.
 - Add event listeners for intercepting link clicks (see below).
 - Add event listeners for intercepting form submissions (see below).
 - Add a `window.onpopstate` event handler so we can respond to history changes (such as clicking back and forward).
 - Optionally trigger an initial event, in case you need to execute something when the page first loads.
   This is useful if your server does not render the page, and relies on client side JS to respond to the URL and render the current page.

#### Listeners

You can add listeners to respond to PushState events. These events include:

- Calls to `PushState.push()` or `PushState.replace()`.
- Any PushState link clicks or form submissions that were intercepted.
- The user navigating back and forward in the browser history.
- The initial page load if `init()` was called with `triggerFirst=true`.

Listeners can respond to the URL, the state and the uploads:

	PushState.addEventListener(function (url:String) {});
	PushState.addEventListener(function (url:String, state:Dynamic) {});
	PushState.addEventListener(function (url:String, state:Dynamic, uploads:Dynamic<FileList>) {});

To remove listeners:

	var myListener = PushState.addEventListener(someFunc);
	PushState.removeEventListener(myListener)
	PushState.clearEventListeners();

#### Preventers

You can add preventers to prevent PushState from navigating away from the current page.
This can be useful, for example, if you would like to prevent the user leaving a form without saving.

Preventers will be called when:

- Calls to `PushState.push()` or `PushState.replace()` are made.
- Any PushState link clicks or form submissions are intercepted.
- The user navigates back and forward in the browser history.

If any of the preventers return false, then the change will be prevented: no listeners will be called, no history items created, and no URLs changed.

Preventers can check against the new URL, the new state, and the new uploads:

	PushState.addPreventer(function (url:String) { return false; });
	PushState.addPreventer(function (url:String, state:Dynamic) { return false; });
	PushState.addPreventer(function (url:String, state:Dynamic, uploads:Dynamic<FileList>) { return false; });

If all preventers return true, then the changes will go ahead.

To remove preventers:

	var myPreventer = PushState.addPreventer(someFunc);
	PushState.removePreventer(myPreventer)
	PushState.clearPreventers();

**Warning**: If the user uses the "back" and "forward" buttons, and a preventer wishes to prevent them moving pages, we cannot cancel those events properly - the URL and state will already have changed.  What we do in this situation is call `PushState.silentReplace()` to restore the old values. This is usually fine, but it will mean there is now an item missing in the browsers history. The page they tried to get "back" to will now be replaced with the page they were previously on.  If you can think of a better solution - please let us know!

#### Manual Changes

	PushState.push(url);
	PushState.push(url,state);
	PushState.push(url,state,uploads);

	PushState.push("/go/somewhere/");
	PushState.push("/go/somewhere/", { name:"Jason", age:28 });
	PushState.push("/go/somewhere/", { name:"Jason", age:28 }, { photo:fileInput.files });

Calling `PushState.push()` will:

- Check that no preventers are blocking us.
- If the preventers are blocking us:
	- The `push()` will be prevented, no changes will be made, and no listeners executed.
	- The function will return `false`.
- If no preventers are blocking us:
	- Create a new history item, with the current URL and state, and update the address bar.
	- Trigger all the listeners with the new URL, state and uploads.
	- Return true

If you don't wish to create a new item in history, but still check the preventers, update the address, the state, and trigger all the listeners, you can use `PushState.replace`:

	PushState.replace(url);
	PushState.replace(url,state);
	PushState.replace(url,state,uploads);

	PushState.push("/change/address/");
	PushState.push("/change/address/", { name:"Jason", age:28 });
	PushState.push("/change/address/", { name:"Jason", age:28 }, { photo:fileInput.files });

To change the URL without creating a new item in the browser history, and without triggering any listeners or checking any preventers, use `PushState.silentReplace()`:

	PushState.silentReplace(url);
	PushState.silentReplace(url,state);
	PushState.silentReplace(url,state,uploads);

If at any time you wish to check the current state, current URL, or current uploads, you can access them:

	PushState.currentPath; // String
	PushState.currentState; // Dynamic
	PushState.currentUploads; // Dynamic<FileList>

	trace( 'We are on page ${PushState.currentPath}' );
	trace( 'My name is ${PushState.currentState.name} and I am ${PushState.currentState.age} years old' );
	trace( 'Your photo is called ${PushState.currentUploads.photo[0].name}' );

These properties should be considered read only, and modifying them will not affect the browser history.

### Link clicks

PushState will listen for all link clicks on the page, and if it is a PushState link, it will turn it into a `PushState.push()` call:

	<!-- Same as PushState.push("/profiles/jason/") -->
	<a href="/profiles/jason/" rel="pushstate">View Jason's Profile</a>

	<!-- Same as PushState.push("/profiles/anna/") -->
	<a href="/profiles/anna/" class="btn pushstate">View Anna's Profile</a>

	<!-- A regular link click, PushState will ignore it -->
	<a href="/profiles/clare/" class="btn clare">View Clare's Profile</a>

### Form submission

PushState can also intercept form submissions, emulating a `POST` request.

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

	PushState.push("/auth?username=jason&password=my_little_secret&subscribe=Haxe&subscribe=Pushstate&type=signup");

Most common form elements are supported.  If you find any that aren't or that could be improved please file an issue.

A note on submit buttons: if `document.activeElement` is a submit button, the value of that button will be included in the form data. Otherwise, if the first submit button that is a child of the form will be considered the default submit button, and it will be used. This matches the behaviour of most browsers when making regular HTTP form submissions.

### File Uploads

In the same way it is possible to save form data in the `state` of each request, we can save uploads too.
In HTML5, we can keep get a `FileList` from each `<input type=file>`, or from drag-and-drop etc.
From these `FileList` objects we can process each `File`, and read the contents, upload them in a HTTP request, etc.

Therefore, by saving a reference to a FileList in our PushState history, we can keep track of the uploaded files as the user navigates forwards and backwards through our app.

	<form metod="POST" action="/uploads" class="pushstate">
		<input type="file" name="photos" multiple />
		<button type="submit">Upload</button>
	</form>

Then in our listener we can get access to those files:

	PushState.addEventListener(function(url,state,uploads) {
		// The URL of the request (eg. "/uploads")
		trace( 'Visiting $url' );

		// The file names of the uploaded files (eg. ["Selfie.jpg","Cat.gif"])
		trace( state.photos );

		// Process the uploads using the HTML5 FileReader API.
		var fileList = uploads.photos;
		var fr = new FileReader();
		fr.onload = function() {
			var dataUrl:String = fr.result;
			var img = document.createImageElement();
			img.src = dataUrl;
			document.getElementById("images").appendChild( img );
		};
		fr.readAsDataURL( fileList[0] );
	});

**Warning:** The FileList that we save with each history item isn't actually read-only.
If we cache a FileList on one page, and then on the next page the user uses the input to select a different file, the history item for the previous page will point to the new files.
To avoid confusion, it is probably a good idea to replace each file input after it is used, ensuring that the uploads in your history do not get altered.

	// Replace the fileInput with an identical one, so any changes do not affect the uploads in our history:
	var fileInput = document.getElementById("photos");
	fileInput.parentNode.insertBefore(fileInput.cloneNode(),fileInput);
	fileInput.parentNode.removeChild(fileInput);

### Demo

To run the demo:

1. Clone the repository, and run `haxe build.hxml`.  
2. From the 'demo/build' directory, run `nekotools server -rewrite`
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
