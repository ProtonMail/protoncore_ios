# Account Recovery

## Summary

This feature is intended to help a user who doesn't remember their password, but have one or several sessions open, to reset it without needing to provide their current password.

## How it works

The current state of Account Recovery, if any, is available on the `/users` API endpoint, under the `AccountRecovery` property, which is a nullable field. This is an object with the following properties:

  - `state`. This is an Int enum with the following values: 
    - 0: No account recovery in progress, default state.
    - 1: Grace period is ongoing. The user needs to wait 72 hours from the moment they request the reset, to the moment they can actually change it. This is to prevent takeover  attempts from going undetected.
    - 2: Cancelled. The process was cancelled by the user, either explicitly or by initiating a new session (which means they do remember their password)
    - 3: Insecure state, which is the moment in which the password can be changed.
    - 4: Expired. When the insecure state window has closed without the user changing their password.
 - `reason`. This is a nullable Int enum containing the reason for the process cancellation. If it is null it means there is no process ongoing.
    - 0: None, the default state, to convey that the process hasn't been cancelled.
    - 1: Cancelled by the user. The user explicitly cancelled the reset process from any of their open sessions.
    - 2: Authenticated in new session. The user initiated a new session, therefore the process was cancelled automatically.
 - `startTime`. Timestamp with the start of the current state
 - `endTime`. Timestamp at which the current state will expire.
 - `UID`. UID of the user (necessary for cancelling the process)
 
The Account Recovery screen is a SwiftUI view which viewModel, using a provided `APIService`, will query the current state of AccountRecovery and display the information. Depending on
this state, it will simply inform the user of the state, or allow them to cancel the process during the grace period.

## Integration

The Account Recovery view is meant to be accessed from the Settings view of every client. This view is available with a `UIHostingController`, for use in UIKit view hierachies. The `AccountRecoveyModule` offers a static method for instantiating the VC, which needs two arguments:
one is an `APIService` instance, and the other is a closure which the view model will use to update the last fetched state of Account Recovery. This is to avoid clients having to poll for themselves the state when returning to the Settings view.

The `AccountRecoveryModule` also offers helper methods to instantiate a Settings Item to navigate to this view, providing the needed copy for it.

TBC: Push Notification integration.
