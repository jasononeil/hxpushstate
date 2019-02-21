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

import pushstate.PushState;
import js.Browser.*;
import js.html.*;
using StringTools;

class Test
{
	static var stateChangeCount = 0;

	public static function main()
	{
		// First we initialise the pushstate library for this page
		// PushState events will be triggered by forward/back and links with rel="pushstate"
		PushState.init();

		// Next we add a listener to any changes
		PushState.addEventListener(function (url,state,uploads) {
			window.console.log('New pushstate URL: $url');

			if (url.endsWith("/custom")==false) {
				// Change the content.
				// In real life this would probably be an AJAX call and some complex logic.
				incrementPushstateCounter();
				document.getElementById("content").innerHTML = 'I want to become a $url';
			}
			else {
				if (uploads==null) {
					// Read the variable from the form submission.
					var animal = state.animal[0];
					console.log('Redirecting to /$animal');
					PushState.replace( '$animal' );
				}
				else {
					// Read the variable from an uploaded file.
					incrementPushstateCounter();
					var fileList = uploads.photo;
					var fr = new FileReader();
					fr.onload = function() {
						var dataUrl:String = fr.result;
						document.getElementById("content").innerHTML = 'I want to become a <img src="$dataUrl" />';
					};
					fr.readAsDataURL( fileList[0] );
					// PushState saves a reference to the FileList, but if the <input type="file"> changes,
					// it will change the file recorded in history too. The workaround is to remove the InputElement
					// from the DOM, and replace it with a new InputElement.
					var fileInput = document.getElementById("photo");
					fileInput.parentNode.insertBefore(fileInput.cloneNode(),fileInput);
					fileInput.parentNode.removeChild(fileInput);
				}
			}
		});

		document.addEventListener("DOMContentLoaded", function(event) {
			// Set up a preventer.
			var btn = document.getElementById("toggle-preventer");
			var preventer = function(url) return js.Browser.window.confirm('Switch to $url?');
			setupPreventerToggle( btn, preventer );
		});
	}

	static function incrementPushstateCounter() {
		// Show user if this was a page reload or pushstate
		stateChangeCount++;
		if (stateChangeCount > 1)
		{
			document.getElementById("load-type").innerHTML = "This content was a push-state";
		}
	}

	static function setupPreventerToggle(btn:Element, preventer:String->Bool) {
		btn.addEventListener("click", function (e) {
			if (btn.classList.contains("active")) {
				btn.classList.remove("active");
				PushState.clearPreventers();
			}
			else {
				btn.classList.add("active");
				PushState.addPreventer(preventer);
			}
		});
	}
}
