package demo;

import js.JQuery;
import pushstate.PushState;

class Test 
{
	static var stateChangeCount = 0;

	public static function main()
	{
		// First we initialise the pushstate library for this page
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

		// 
		new JQuery(js.Lib.document).ready(function (e) {
			new JQuery("#animal-form").submit(function (e) {
				var value = JQuery.cur.find("input").val();
				PushState.push("/" + value); 
				e.preventDefault();
			});
		});
	}
}