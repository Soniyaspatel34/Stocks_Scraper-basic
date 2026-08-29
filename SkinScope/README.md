# SkinScope

An iPhone app for tracking close-up skin photos taken with a plug-in phone
microscope (or your camera's macro lens), and suggesting general skincare
product categories with a tap-through to buy on Amazon. It's a personal photo
journal + shopping helper — **not** a diagnostic or medical device.

## Features

- **Live capture** with pinch-free zoom slider, torch toggle, and an optional
  reference grid overlay to help frame shots consistently.
- **Automatic microscope detection**: on iOS 17+, a UVC-compliant digital
  microscope plugged in via Lightning/USB-C is detected and used automatically
  (`AVCaptureDevice.DeviceType.external`). If no external microscope is
  attached, it falls back to the iPhone's ultra-wide/wide camera, which works
  well with cheap optical clip-on macro lenses.
- **Organized history** grouped by body location (face, arm, back, etc., or a
  custom label), each photo with a note and timestamp.
- **Side-by-side compare** view to pick two photos of the same spot from
  different dates and look for change.
- **Zoom + share** on any saved photo.
- **Shop tab**: a short quiz (skin type + concerns) drives a curated list of
  product categories — e.g. "oily + acne-prone" suggests a salicylic acid
  cleanser, oil-free moisturizer, and a mattifying sunscreen. Each suggestion
  links out to an Amazon search carrying your Associates tag.
- **100% local storage** — photos, notes, and quiz answers are saved on-device
  only; nothing is uploaded anywhere. A "Delete all scans" option is in the
  About tab.

## Why no AI analysis?

Deliberately left out, on both fronts:

- **Photos**: an app that scores or flags moles/lesions as benign/concerning
  would be acting as an undisclosed, unvalidated medical device — not
  something to ship without clinical validation and regulatory review.
  SkinScope sticks to consistent, comparable photos over time, so you and
  your dermatologist can see what changed.
- **Recommendations**: product suggestions come from your own quiz answers
  (self-reported skin type and concerns) via a static lookup table — the same
  kind of logic retail skincare quizzes use. Nothing is inferred from the
  photo's pixels; that would be an unreliable, over-claiming feature dressed
  up as a real assessment.

## How the Amazon shopping links work

SkinScope does **not** implement in-app checkout, payments, or actual
dropshipping/fulfillment — that would need a backend server, a payment
processor, and a registered business, which is a much larger project than an
iOS app. Instead, each recommendation links to a tagged Amazon search:

```
https://www.amazon.com/s?k=<search terms>&tag=<your Associates tag>
```

The user taps through, buys directly from Amazon (or any of its sellers), and
purchases made in that browsing session are credited to whatever Amazon
Associates tag is entered in the About tab. To earn commissions:

1. Sign up for the [Amazon Associates Program](https://affiliate-program.amazon.com/)
   (free).
2. Enter your Associates tag (e.g. `yourtag-20`) in SkinScope's About tab.
3. Amazon's operating agreement requires the "as an Amazon Associate I earn
   from qualifying purchases" disclosure wherever tagged links appear —
   that's already included on the Shop tab, so you don't need to add it
   yourself.

Leaving the tag blank still works — links just open plain, untagged Amazon
searches with no commission credited. If you'd rather use the Product
Advertising API for real product cards (live prices/images/specific ASINs
instead of a search page), that requires an *approved* Associates account
with qualifying sales history plus API credentials, which isn't something I
can obtain on your behalf — let me know if you get access and want it wired
in.

## Requirements

- Xcode 15 or later
- iOS 17.0+ deployment target (for automatic external-microscope detection;
  lower it in the project's Deployment Info if you only ever use an optical
  clip-on lens, since that path just uses the built-in camera)
- A physical iPhone to test the camera (the Simulator has no camera)

## Getting started

1. Open `SkinScope.xcodeproj` in Xcode.
2. Select your iPhone as the run destination (camera access requires a real
   device).
3. In the target's **Signing & Capabilities** tab, set your own Team so Xcode
   can code-sign the build.
4. Build & run. Grant camera access when prompted.
5. Plug in your microscope before or after launching the app — the capture
   screen shows a "Microscope connected" badge when it's detected and being
   used as the video source. Without it, aim the built-in camera (ultra-wide
   lens works best for close focus) or clip on your optical macro lens.

## Project layout

```
SkinScope/
  SkinScopeApp.swift        App entry point
  ContentView.swift         Tab bar (Scan / History / Shop / About)
  Camera/
    CameraController.swift  AVFoundation session, device selection, zoom/torch/capture
    CameraPreviewView.swift UIKit bridge for the live preview layer
  Models/
    ScanRecord.swift             Photo + metadata model, body-location presets
    SkinProfile.swift            Skin type / concern enums + quiz-answer model
    ProductRecommendation.swift  A single suggested product category
    RecommendationEngine.swift   Static skin-profile -> recommendations lookup
    AmazonLinkBuilder.swift      Builds tagged Amazon search URLs
  Persistence/
    ScanStore.swift          Local JSON index + JPEG files in Documents
    SkinProfileStore.swift   Quiz answers + Amazon Associates tag (UserDefaults)
  Views/
    CaptureView.swift          Live capture screen
    GalleryView.swift          History grouped by body location
    ScanDetailView.swift       Full-screen zoomable photo, notes, delete/share
    CompareView.swift          Side-by-side comparison across dates
    SkinQuizView.swift         Skin type + concerns quiz
    RecommendationsView.swift  Shop tab: suggestions + Amazon links
    SettingsView.swift         Disclaimer, Associates tag entry, data management
```

## Notes on plug-in microscopes

Most inexpensive "phone microscopes" are one of two kinds:

1. **Optical clip-on lenses** (most $10–30 ones) — no electronics, they just
   clip over your existing camera lens. The app doesn't need to do anything
   special; it uses the ultra-wide/wide back camera, which SkinScope selects
   by default.
2. **USB/UVC digital microscopes** with their own image sensor, connecting via
   a Lightning-to-USB or USB-C adapter — these show up to iOS 17+ as an
   external camera. SkinScope's `CameraController` watches for
   `AVCaptureDeviceWasConnected`/`Disconnected` notifications and switches to
   the external device automatically when present.

If your specific microscope isn't UVC-compliant (some cheap ones instead ship
a companion app and only expose stills via Wi-Fi or their own SDK), it won't
show up as an `AVCaptureDevice` at all — in that case, save photos from the
microscope's own app to your Photos library and there's currently no import
flow in SkinScope for that path. Let me know the exact model if you hit this
and it can be added.
