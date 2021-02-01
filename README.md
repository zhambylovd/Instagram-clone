# Instagram-clone

## Requirements

- Xcode version 11.7+
- Swift 5
- iPhone 8 or higher
- iOS 12.0+


## Installation

1. Install CocoaPods
2. Open Terminal and run pod install directly in Instagram clone folder.
3. In order for Firebase to work, create a new project for your application.
4. Download GoogleService-Info.plist from your newly created Firebase project and replace it with the old one.
5. Enable Email/Password authentication method
6. Enable Firebase storage
7. Create Realtime Database
8. Set Realtime Database rules to:

```
{
  "rules": {
     ".read": true,
     ".write": true     
  }
}
```
