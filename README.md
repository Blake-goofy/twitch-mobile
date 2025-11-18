# Twitch Wrapper iOS App

A clean iOS app that wraps Twitch's mobile website and removes the "Open App" upsell banners.

## Features

- ✅ Full-screen Twitch mobile web experience
- ✅ Removes "Open App" upsell banners automatically
- ✅ Blocks navigation to app store upsell URLs
- ✅ Maintains login state with cookies
- ✅ Supports iOS 16+
- ✅ Built with Swift and SwiftUI

## How It Works

The app uses WebKit to load Twitch's mobile site (`https://m.twitch.tv/directory/following`) and employs two methods to remove upsell prompts:

1. **JavaScript Injection**: A user script injected at document end that:
   - Removes elements with tracking parameters `tt_medium=mweb&tt_content=top_nav_open_in_app`
   - Removes buttons/links containing "open app" text
   - Uses a `MutationObserver` to handle dynamically added content

2. **Navigation Blocking**: The WebKit navigation delegate blocks any navigation attempts to URLs containing the app upsell tracking parameters.

## Project Structure

```
TwitchWrapper/
├── TwitchWrapperApp.swift    # Main app entry point
├── ContentView.swift          # Main view showing the web view
├── TwitchWebView.swift        # WebKit wrapper with upsell removal
└── Info.plist                 # App configuration
```

## Building

1. Open `TwitchWrapper.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press Cmd+R to build and run

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

## Technical Details

### WebView Configuration

- JavaScript enabled for full site functionality
- User content controller for script injection
- Navigation delegate for URL filtering
- Default cookie behavior for persistent login

### Upsell Removal

The JavaScript removal script:
- Runs at document end (after DOM is ready)
- Targets main frame only
- Re-runs on DOM mutations for dynamic content
- Removes container elements (header, nav, div, section) for cleaner removal

### Navigation Blocking

The navigation delegate cancels any navigation with:
- URL substring: `tt_medium=mweb&tt_content=top_nav_open_in_app`

This prevents the app from opening external app store links or triggering app handoff.

## License

This project is provided as-is for educational purposes.
