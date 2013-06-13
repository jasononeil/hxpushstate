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

#if detox 
	using Detox;
#else 
	import js.JQuery.JQueryHelper.*;
#end 
import pushstate.PushState;
import js.Browser.document in doc;

class Test 
{
	static var stateChangeCount = 0;

	public static function main()
	{
		// First we initialise the pushstate library for this page
		// PushState events will be triggered by forward/back and links with rel="pushstate"
		PushState.init();

		// Next we add a listener to any changes
		PushState.addEventListener(function (url) {

			// Show user if this was a page reload or pushstate
			stateChangeCount++;
			if (stateChangeCount > 1)
			{
				#if detox 
					"#load-type".find().setText("This content was a push-state");
				#else 
					J("#load-type").text("This content was a push-state");
				#end
			}
			
			// Change the content.  
			// In real life this would probably be an AJAX call
			#if detox 
				"#content".find().setText("I want to become a " + url);
			#else 
				J("#content").text("I want to become a " + url);
			#end

		});

		// We can also trigger changes to the history API (and therefore pushstate events) manually
		#if detox 
			Detox.ready(function () {
				"#animal-form".find().submit(function (e) {
					var value = "#animal-form input".find().val();
					PushState.push("/" + value); 
					e.preventDefault();
				});
			});
		#else 
			J(untyped doc).ready(function (e) {
				J("#animal-form").submit(function (e) {
					// When the form is submitted, use the value of the input as our new URL, and trigger PushState
					var value = JTHIS.find("input").val();
					PushState.push("/" + value); 
					e.preventDefault();
				});
			});
		#end
	}
}
