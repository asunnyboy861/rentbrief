# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- App stores all data locally (SwiftData) - no iCloud sync mentioned as default
- PDF report generation - local Core Graphics, no network needed
- Photo capture for maintenance orders - PhotosUI
- CSV export - local file generation
- Subscription IAP - StoreKit 2
- Contact support - network request to feedback backend
- No push notifications detected
- No HealthKit detected
- No location services detected
- No Apple Watch detected

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| In-App Purchase | ✅ Configured | StoreKit 2 in code |
| Photo Library (maintenance photos) | ✅ Configured | PhotosUI in code |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| In-App Purchase (App Store Connect) | ⏳ Pending | Create subscription groups in App Store Connect before submission |
| Network (Feedback) | ✅ Auto | Uses App Transport Security defaults |

## No Configuration Needed
- Push Notifications: Not required
- iCloud/CloudKit: Not required (local storage only)
- HealthKit: Not applicable
- Location Services: Not required
- Apple Watch: Not applicable
- Siri: Not applicable
- Background Modes: Not required
- Camera: Uses PhotosUI picker (no direct camera access needed)

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
