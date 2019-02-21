# Pushstate Changes

## 2.1.0

- Add support for including file uploads (Javascript `FileList` objects) in the history state.
- Add support for reading `<input type=file>` while intercepting form submissions.
- Make `currentPath`, `currentState` and `currentUploads` readonly.
- Add `PushState.silentReplace()` to update the URL and state without checking preventers or triggering listeners.
- Get rid of the old (and unused) `pushstate.History` interface.

## 2.0.1

- Add values from submit buttons in a way closer to normal submission (respecting which button was clicked, or choosing the first submit button as the "default" if the form was submitted without clicking a button).

## 2.0.0

- Add optional `ignoreAnchors` parameter to `init()`, to ignore changes that are only jumping between anchors on the same page. Default is true (ignore anchors).
- Handle POST submissions differently, storing each parameter as a property of the `state` object. The POST string is still available as `state.__postData`.

## 1.1.0

- Remove dependencies on Detox or jQuery, use plain Javascript APIs instead.
- Add optional `triggerFirst` parameter to `init()`, default value is true.

## 1.0.0

- First stable release.
- See git history for older revision information.
