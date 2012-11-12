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

package demo;

import js.JQuery;
import pushstate.PushState;

class Test 
{
	static var stateChangeCount = 0;

	public static function main()
	{
		// First we initialise the pushstate library for this page
		// PushState events will be triggered by forward/back and links with rel="pushstate"
		PushState.init();

		// Next we add a listener to any changes
		PushState.onStateChange.bind(function (event) {

			// Show user if this was a page reload or pushstate
			stateChangeCount++;
			if (stateChangeCount > 1)
			{
				new JQuery("#load-type").text("This content was a push-state");
			}
			
			// Change the content.  
			// In real life this would probably be an AJAX call
			new JQuery("#content").text("I want to become a " + event.url);

		});

		// We can also trigger changes to the history API (and therefore pushstate events) manually
		new JQuery(js.Lib.document).ready(function (e) {
			new JQuery("#animal-form").submit(function (e) {
				// When the form is submitted, use the value of the input as our new URL, and trigger PushState
				var value = JQuery.cur.find("input").val();
				PushState.push("/" + value); 
				e.preventDefault();
			});
		});
	}
}