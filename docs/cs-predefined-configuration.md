# Case Study: Predefined Channel Configuration

## Overview

The sample app normally starts on its configuration screen, where a brand ID, channel ID and
environment have to be entered — or picked from a preset — before a chat can be prepared. For an
automated suite that screen is pure overhead: several taps, a scrolling dropdown, and a dependency on
the presets bundled in `environment.json`.

The app can instead be launched with the channel already configured, supplied as **environment
variables on the app process**. The values are read in `SDKDemoApp.init()`, before the first frame is
rendered, so the configuration screen is never presented at all.

Optionally the same mechanism can supply a guest identity, in which case the login screen is skipped too
and the app opens directly on the store with chat ready — zero interactions.

This is a convenience for test automation and local development. It is not required to run the sample
app, and nothing changes for a normal launch.

> 📖 All values in this document are placeholders. Substitute the brand, channel and environment details
> for the channel under test; do not commit them.

## How It Works

Appium's XCUITest driver sets environment variables on the process it launches, via
`setProcessArguments`. This is the iOS analogue of the Intent extras used on Android. On a simulator the
same variables can be passed with `xcrun simctl launch`.

At launch the app reads them, validates them as a whole, persists the configuration through the same
`LocalStorageManager.configuration` path the manual flow uses, and routes straight to login (or to the
store, if a guest identity was supplied). If anything is missing or malformed the entire set is rejected,
a warning is logged, and the app falls back to its normal configuration screen.

## The Two Forms

The brand and channel are always required. The **environment** is then expressed one of two ways, and
the two forms are mutually exclusive.

### Form 1 — Built-in region (3 variables)

Use this for the production regions the SDK knows about.

| Variable | Notes |
|---|---|
| `CXONE_BRAND_ID` | Integer, non-zero |
| `CXONE_CHANNEL_ID` | Non-empty |
| `CXONE_ENVIRONMENT` | Case-sensitive; one of `NA1`, `EU1`, `AU1`, `CA1`, `UK1`, `JP1` |
| `CXONE_ENVIRONMENT_NAME` | Optional; display label only, defaults to the region name |

```bash
CXONE_BRAND_ID=<!-- Brand ID -->
CXONE_CHANNEL_ID=<!-- Channel ID -->
CXONE_ENVIRONMENT=<!-- NA1 | EU1 | AU1 | CA1 | UK1 | JP1 -->
```

### Form 2 — Custom environment (7 variables)

Use this for any backend that is **not** a built-in production region — which includes every
non-production environment.

| Variable | Required | Notes |
|---|---|---|
| `CXONE_BRAND_ID` | yes | Integer, non-zero |
| `CXONE_CHANNEL_ID` | yes | Non-empty |
| `CXONE_CHAT_URL` | yes | Absolute `http(s)://` URL with a host |
| `CXONE_SOCKET_URL` | yes | Absolute `ws(s)://` URL with a host |
| `CXONE_LOGGER_URL` | yes | Absolute `http(s)://` URL with a host |
| `CXONE_TOKEN_URL` | yes | Absolute `http(s)://` URL with a host |
| `CXONE_ENVIRONMENT_NAME` | no | Display label only; defaults to `Custom` |

```bash
CXONE_BRAND_ID=<!-- Brand ID -->
CXONE_CHANNEL_ID=<!-- Channel ID -->
CXONE_CHAT_URL=<!-- Chat URL -->
CXONE_SOCKET_URL=<!-- Socket URL -->
CXONE_LOGGER_URL=<!-- Logger URL -->
CXONE_TOKEN_URL=<!-- Token URL -->
CXONE_ENVIRONMENT_NAME=<!-- Environment label, optional -->
```

The four URLs correspond exactly to the fields of an `environment` entry in `environment.json`, so they
can be copied from the entry for the channel under test.

## ⚠️ Non-Production Environments Require Form 2

`CXoneChatSDK.Environment` has six cases and they are **all production regions**. Any QA, test or staging
backend is therefore *not* a member of that enum, cannot be selected with `CXONE_ENVIRONMENT`, and must
use the custom URL form.

An **incomplete** URL set is rejected rather than falling back to a built-in region. This is deliberate:
a typo in one variable must never silently point a test run at production.

For the same reason, a custom set whose `CXONE_CHAT_URL` equals a built-in region's chat URL is also
rejected. The app derives the region from the chat URL, and a match means the region's socket, logger and
token gateways are used in place of the three supplied ones — so such a set could not be honoured as
written. To target a region, use `CXONE_ENVIRONMENT` on its own.

## Skipping the Login Screen

Supply **both** names and the guest identity is applied for you, taking the app straight to the store:

| Variable | Notes |
|---|---|
| `CXONE_FIRST_NAME` | Must be paired with `CXONE_LAST_NAME` |
| `CXONE_LAST_NAME` | Must be paired with `CXONE_FIRST_NAME` |

| Names supplied | Where the app lands |
|---|---|
| Both | **Store**, chat ready — no interactions at all |
| Neither | **Login** screen, channel already configured |
| Only one | Whole set rejected — configuration screen |

On channels with **authorization enabled** the login screen is still presented even with both names,
because a name is not a credential there. That is expected, not a failure.

⚠️ The "Neither" row describes a clean state. Supplying no names does **not** clear an identity a previous
run already stored: re-supplying the *same* channel deliberately preserves the session (see *Switching
Channels Between Runs*), and a stored identity is part of it — so the app goes straight to the store
again. A test that needs the login screen must either target a different channel or start from a clean
install (`xcrun simctl uninstall`).

## Example Usage — Appium

Add the variables to the iOS capabilities. `ProcessArguments` ships with the Appium Java client, so no
new dependency is needed.

```java
XCUITestOptions iosOptions = new XCUITestOptions();
// ... existing platform, udid, bundleId, app setup ...

iosOptions.setProcessArguments(new ProcessArguments(List.of(), Map.of(
        "CXONE_BRAND_ID",         brandId,
        "CXONE_CHANNEL_ID",       channelId,
        "CXONE_ENVIRONMENT_NAME", environmentLabel,
        "CXONE_CHAT_URL",         chatUrl,
        "CXONE_SOCKET_URL",       socketUrl,
        "CXONE_LOGGER_URL",       loggerUrl,
        "CXONE_TOKEN_URL",        tokenUrl,
        "CXONE_FIRST_NAME",       firstName,
        "CXONE_LAST_NAME",        lastName)));
```

For a production region, drop the four URL variables and use a single `CXONE_ENVIRONMENT` instead:

```java
iosOptions.setProcessArguments(new ProcessArguments(List.of(), Map.of(
        "CXONE_BRAND_ID",    brandId,
        "CXONE_CHANNEL_ID",  channelId,
        "CXONE_ENVIRONMENT", region)));
```

Read the values from the automation project's own configuration rather than hardcoding them, and keep
them out of version control. Because the channel differs per test — single-thread, multi-thread, live
chat — they should come from whatever already selects the environment for a test.

## Example Usage — Simulator

`xcrun simctl` forwards variables to the launched process when they are prefixed with `SIMCTL_CHILD_`.
The app itself reads the **unprefixed** names:

```bash
SIMCTL_CHILD_CXONE_BRAND_ID=<!-- Brand ID --> \
SIMCTL_CHILD_CXONE_CHANNEL_ID=<!-- Channel ID --> \
SIMCTL_CHILD_CXONE_ENVIRONMENT_NAME=<!-- Environment label --> \
SIMCTL_CHILD_CXONE_CHAT_URL=<!-- Chat URL --> \
SIMCTL_CHILD_CXONE_SOCKET_URL=<!-- Socket URL --> \
SIMCTL_CHILD_CXONE_LOGGER_URL=<!-- Logger URL --> \
SIMCTL_CHILD_CXONE_TOKEN_URL=<!-- Token URL --> \
SIMCTL_CHILD_CXONE_FIRST_NAME=<!-- First name --> \
SIMCTL_CHILD_CXONE_LAST_NAME=<!-- Last name --> \
  xcrun simctl launch booted <!-- app bundle identifier -->
```

Uninstall first when checking behaviour, or a configuration persisted by an earlier run will mask the
result:

```bash
xcrun simctl uninstall booted <!-- app bundle identifier -->
```

In Xcode the same variables can be set under **Product → Scheme → Edit Scheme → Run → Arguments →
Environment Variables**. Note that `xcodegen` regenerates the scheme, so those entries are lost on the
next `scripts/setup.sh` run — which also keeps them out of the repository.

## Expected Behaviour

| Input | Result |
|---|---|
| Valid set, both names | Store, chat ready |
| Valid set, no names | Login screen — unless a previous run on the same channel stored an identity |
| No `CXONE_*` variables at all | Configuration screen — unchanged behaviour |
| Only optional variables (label, names) | Treated as absent — unchanged behaviour, no rejection |
| Incomplete custom URL set | Rejected → configuration screen |
| Custom `CXONE_CHAT_URL` matching a built-in region | Rejected → configuration screen |
| `CXONE_ENVIRONMENT` **and** custom URLs together | Rejected → configuration screen |
| Unknown `CXONE_ENVIRONMENT` value | Rejected → configuration screen |
| Non-numeric or zero `CXONE_BRAND_ID` | Rejected → configuration screen |
| Only one of the two names | Rejected → configuration screen |
| Malformed URL | Rejected → configuration screen |

Nothing is ever partially applied. A rejection leaves any previously persisted configuration untouched —
it stays in storage and is still offered by the configuration screen — but it is deliberately *not* used
to route the launch. A run that asked for a channel and got it wrong stops on the configuration screen
rather than continuing against whatever channel an earlier run happened to persist.

Blank values count as absent rather than malformed. `CXONE_ENVIRONMENT=""` alongside a complete set of
custom URLs is therefore the custom form, not a clash between the two forms, and a set in which *every*
variable is blank is an ordinary launch. Values are also whitespace-trimmed, so an ID or URL carrying a
trailing newline from a config file or shell substitution still works.

## Reading a Rejection

Every rejection is logged, naming the offending variable:

```
Launch configuration ignored: 'CXONE_SOCKET_URL' is not an absolute ws:// or wss:// URL with a host.
Launch configuration ignored: custom environment is incomplete — missing CXONE_LOGGER_URL, CXONE_TOKEN_URL.
Launch configuration ignored: 'CXONE_ENVIRONMENT' and the custom environment URLs are mutually exclusive — supply one form or the other, not both.
```

These warnings are emitted from `SDKDemoApp.init()`, which runs *before* `Log.configure(...)` in
`didFinishLaunching`. They therefore go through the default `PrintLogWriter` — standard output only, not
the unified log and not the app's log file. On a simulator, attach the console to the launch to see them:

```bash
SIMCTL_CHILD_CXONE_BRAND_ID=<!-- Brand ID --> \
SIMCTL_CHILD_CXONE_CHANNEL_ID=<!-- Channel ID --> \
  xcrun simctl launch --console-pty booted <!-- app bundle identifier -->
```

Running from Xcode instead, the same lines appear in the debug console.

If the app lands on the configuration screen when you expected otherwise, this log line is the first
place to look.

## Switching Channels Between Runs

Supplying a configuration for a **different** brand, channel or backend resets the session — provider
sign-out, stored identity, downloaded attachments and the chat theme — so state cannot leak between
brands. Re-supplying the **same** configuration leaves an existing session intact, so a repeated run of
the same test does not needlessly discard it.

The reset also erases the app's whole Documents folder, the same as signing out or returning to the
configuration screen. Files a test pushes there for "Choose from files" (for example
`pushFile('@com.incontact.mobileSDK.sample:documents/…')` on a device) do not survive it, so push them
only after the app has launched with its final configuration and is past any sign-out step.

The comparison is on brand ID, channel ID and all four environment URLs. The same brand and channel can
exist on more than one backend, so the URLs are part of the channel's identity; the display label is not.
Trailing slashes are ignored, so a URL that differs only by one is not treated as a different backend.

## Notes

- Values are read **once, at launch**. Changing them requires relaunching the app, which is how a test
  session starts one anyway.
- The login screen requests notification permission on first launch. This is pre-existing behaviour,
  unrelated to this feature — expect the prompt, or set `autoAcceptAlerts`. On iOS 26 simulators the
  prompt is invisible to WebDriverAgent and cannot be dismissed that way; supply
  `CXONE_SKIP_NOTIFICATION_PROMPT=1` (or `true`) alongside the other variables to skip the permission
  request entirely. Without it, behaviour is unchanged.
- Existing thread deep links (`…/threads?idOnExternalPlatform=…`) are unaffected.
- The mechanism is active in all build configurations. The configuration screen already accepts an
  arbitrary brand and channel by hand, so this grants no capability the UI does not.
- Because the values are supplied directly, the app no longer needs a matching preset in
  `environment.json`, and nothing depends on a preset's display name.
