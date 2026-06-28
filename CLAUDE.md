# SharableComponents

A SwiftUI component library — a living catalog of reusable, self-contained UI components that can be copied or SPM-linked into any iOS/macOS app.

## Project Purpose

This project exists to design, build, and document reusable SwiftUI components. Each component must be:

- **Self-contained** — minimal dependencies, no coupling to app-specific state or services
- **Configurable** — exposed via clean, protocol-driven or closure-based APIs
- **Previewed** — every component has a `#Preview` showing common configurations
- **Portable** — can be dropped into another project with minimal friction (ideally a single file copy)

Components live in `SharableComponents/Components/<ComponentName>/`. Each component folder contains:

```
Components/
  AppReviewRequest/
    AppReviewRequestConfig.swift    # All configuration knobs
    AppReviewRequestStyle.swift     # Visual styling
    AppReviewRequestManager.swift   # State / logic
    AppReviewRequestView.swift      # The SwiftUI view
    View+AppReviewRequest.swift     # .appReviewRequest() view modifier
```

## Platform & Toolchain

- **Language:** Swift 5.9+
- **UI framework:** SwiftUI
- **Minimum deployment:** iOS 17 / macOS 14 (update here if changed)
- **Xcode project:** `SharableComponents.xcodeproj`
- **Tests:** `SharableComponentsTests/` (unit), `SharableComponentsUITests/` (UI automation)

## Component Catalog

### AppReviewRequest ✓

Prompts the user to leave an App Store review after configurable trigger conditions are met. Deep-links directly to the App Store write-a-review page via `itms-apps://`.

**Trigger conditions:** minimum launch count OR minimum days since first launch (either fires the prompt). Defaults favor launch count (`minLaunches: 10`); days is set to 365 to be effectively off unless the caller lowers it.

**Ask Later cooldown:** same symmetric logic — launches OR days, whichever comes first. Defaults: 3 launches / 365 days.

**Usage:**
```swift
// In App.init:
var config = AppReviewRequestConfig(appStoreID: "YOUR_APP_STORE_ID")
config.minLaunches = 10
AppReviewRequestManager.shared.configure(config)
AppReviewRequestManager.shared.recordLaunch()

// On root view:
ContentView()
    .appReviewRequest()
```

**Storage:** `UserDefaults` with a configurable suite name to avoid key collisions across apps.

**Files:** `Components/AppReviewRequest/`

---

### FeedbackManager ✓

User-initiated in-app feedback component. A button opens a sheet where the user picks a feedback category from a configurable list; tapping "Open Mail" launches the Mail app with a pre-populated draft (recipient, subject, and a system-info footer).

**Button:** SF Symbol `bubble.left.and.text.bubble.right` by default, fully stylable. Available as a toolbar modifier (`.feedbackButton()`) or a standalone `FeedbackButtonView` for custom placement.

**Subject line:** `[AppName] <selected category>` — categories are a caller-supplied `[String]` array.

**Email body footer (auto-appended when `includeSystemInfo: true`):**
App name, version, build number, iOS version, device model.

**Usage:**
```swift
// Toolbar button (simplest):
ContentView()
    .feedbackButton()

// Custom config:
var config = FeedbackManagerConfig()
config.recipientEmail = "you@example.com"
config.subjectCategories = ["Bug", "Feature Request", "Other"]

ContentView()
    .feedbackButton(config: config)

// Standalone button anywhere in your layout:
FeedbackButtonView(config: config, isSheetPresented: $isPresented)
```

**Files:** `Components/FeedbackManager/`

---

### InAppPurchase ✓

Freemium paywall component for one-time "unlock the full app" purchases. Displays a full-screen paywall after a configurable free trial window, with an escalating deferral system that lets users postpone until their extensions run out — then hard-blocks until they purchase.

**Free trial:** configurable by launch count (`minLaunches: 15`) or days since install (`minDaysSinceFirstLaunch: 365`), whichever comes first. Default launch count is set 5 above the `AppReviewRequest` default to sequence them.

**Deferral escalation:** `deferralSteps: [Int]` defines the launches between each "Ask Later" tap, in order. e.g. `[5, 4, 3]` gives 3 chances to defer. Once the array is exhausted, the "Ask Later" option disappears and the paywall cannot be dismissed (`isBlocked = true`).

**Price:** auto-fetched from StoreKit 2 as a localized string — no hardcoding needed.

**Usage:**
```swift
// In App.init:
var config = InAppPurchaseConfig(productID: "com.yourapp.unlock")
config.minLaunches = 15
config.deferralSteps = [5, 4, 3]
InAppPurchaseManager.shared.configure(config)
await InAppPurchaseManager.shared.recordLaunch()

// On root view:
ContentView()
    .inAppPurchase()
```

**Storage:** `UserDefaults` with a configurable suite name.

**Files:** `Components/InAppPurchase/`

---

### TipKit ✓

Drop-in replacement for `.popoverTip()` that fixes text truncation, adds consistent styling, and provides global guards against tips firing at the wrong time (startup, covered views, sheets).

**Truncation fix:** replaces `.popoverTip()` with SwiftUI's native `.popover()` + a fixed `popoverWidth` (default 300 pt) and `fixedSize(horizontal: false, vertical: true)` on the message. Apple's `.popoverTip()` inherits its width from the anchor view; this doesn't.

**Global guards:** `TipKitGuard` provides three `@Parameter` properties — `isEnabled`, `isReady`, `isAllowed` — that callers include in their tip's `rules` array. Flip them from the app to suppress all participating tips at once.

**Catalyst:** automatically suppressed on Mac Catalyst (no-op passthrough).

**Usage:**
```swift
// In App.init:
try? Tips.configure([.displayFrequency(.immediate)])
TipKitGuard.isReady = true   // set after splash/loading is done

// On any view:
Image(systemName: "star")
    .tipPopover(MyTip())

// When presenting a sheet over tip-bearing views:
.onChange(of: isSheetPresented) { TipKitGuard.isAllowed = !$0 }

// Tip definition — include only the guards you need:
struct MyTip: Tip {
    var rules: [Rule] {
        [#Rule(TipKitGuard.$isReady)   { $0 },
         #Rule(TipKitGuard.$isAllowed) { $0 }]
    }
}
```

**Files:** `Components/TipKit/`

---

### AppColorSelection ✓

Single-accent color picker — a simpler alternative to `AppPaletteSelection` when you only need one semantic color token (accent) rather than a full palette pair. Ships with the same 51 presets as `AppPaletteSelection` (20 LongLead + 31 Apple crayon). Selection is persisted to `UserDefaults` and exposed via an `@Observable` store.

**Display modes:** `.band`, `.picker`, `.matrix(columns:)` — same as `AppPaletteSelection`.

**Usage:**
```swift
// In App.init:
let colorStore = AppColorStore(suiteName: "group.com.yourapp")

// On root view:
ContentView()
    .environment(colorStore)

// In a settings screen:
@Environment(AppColorStore.self) private var appColor

AppColorSelectionView(
    displayMode: .matrix(columns: 6),
    message: "Changes the accent color throughout the app.",
    options: AppColorPreset.all,
    selectedOption: appColor.selectedPreset,
    tintColor: appColor.accentColor
) { appColor.select($0) }

// Reading the color in any view:
Text("Hello").foregroundStyle(appColor.accentColor)
```

**Storage:** `UserDefaults` with a configurable suite name.

**Files:** `Components/AppColorSelection/`

---

### AppPaletteSelection ✓

Color palette picker that lets users choose an accent/background color pair from a set of built-in presets. Each preset is a single accent color (used for text, icons, and controls) paired with a lightly tinted background. The selection is persisted to `UserDefaults` and exposed via an `@Observable` store.

**Presets:** 20 curated LongLead palettes (Forest, Ocean, Purple, Crimson, Orange, Teal, Midnight, Burgundy, Pine, Indigo, Graphite, Olive, Mauve, Steel, Amber, Sage, Plum, Slate, Moss, Espresso) plus 31 Apple crayon colors (Cayenne through Carnation). Available as `AppPalettePreset.all`, `.longlead`, or `.crayon`.

**Display modes:** Three picker layouts selectable at call time via `AppPaletteDisplayMode`:
- `.band` — horizontal scrolling row of swatch circles (default)
- `.picker` — vertical scrollable list of swatch + name rows
- `.matrix(columns:)` — fixed-column grid; row count determined automatically

**Preview:** A live two-card preview (light + dark) uses a monochromatic rendering approach — both the surface color and the foreground text are derived from the same hue as the accent, keeping all adjustments in HSB space so the hue is never lost.

**Monochromatic preview approach:** Rather than showing the raw accent on a neutral white or black background, the surface and foreground both stay within the same hue family. All adjustments are made in HSB space (hue held constant, only saturation and brightness moved) so the color character is preserved even for very bright or very dark accents.
- *Light card:* surface = same hue, S 18%, B 97% (pale tinted wash); foreground = same hue, S ≥ 80%, B 52% (rich mid-dark)
- *Dark card:* surface = same hue, S 30%, B 15% (dark tinted shadow); foreground = same hue, S × 0.85, B 82% (bright but not washed)
- Dark accents that are already legible on a light surface are left unadjusted.

**Custom palettes:** Generic over `AppPaletteSelectable` — supply your own enum/struct conforming to the protocol to override or extend the preset list.

**Usage:**
```swift
// In App.init:
let paletteStore = AppPaletteStore(suiteName: "group.com.yourapp")

// On root view:
ContentView()
    .environment(paletteStore)

// In a settings screen:
@Environment(AppPaletteStore.self) private var palette

AppPaletteSelectionView(
    displayMode: .matrix(columns: 6),
    message: "Changes the accent and background tint throughout the entire app.",
    options: AppPalettePreset.all,
    selectedOption: palette.selectedPreset,
    tintColor: palette.accentColor
) { palette.select($0) }

// Reading colours in any view:
Rectangle().fill(palette.backgroundColor)
Text("Hello").foregroundStyle(palette.accentColor)
```

**Storage:** `UserDefaults` with a configurable suite name.

**Files:** `Components/AppPaletteSelection/`

---

### AppUpdateNotifier ✓

Shows a one-time-per-version sheet communicating what changed in a new app release. The sheet presents automatically on the first launch after an app update and yields to the IAP paywall when it is blocking the screen.

**Version detection:** Compares `CFBundleShortVersionString` against a stored value in `UserDefaults`. A version mismatch triggers the sheet. No network call required — release notes are bundled with the app.

**Dismiss vs. suppress:** The X button and "Continue" button dismiss the sheet for the current session only (it re-appears on the next launch). "Don't show again for this version" writes the current bundle version to UserDefaults, permanently suppressing the sheet until a future version is installed.

**Theming:** Accepts `accentColor` and `backgroundColor` directly — pass from whichever store the host app uses (`AppColorStore` or `AppPaletteStore`), or omit both to fall back to system accent colors.

**Sheet contents:**
- App name, version label, release date in a tinted header
- "What's New" section with separate "Enhancements" and "Bug Fixes" bullet lists (each section is suppressed if its array is empty)
- Sticky footer with "Continue" (filled pill) and "Don't show again for this version" (text link)

**Usage:**
```swift
// In App.init:
var config = AppUpdateNotifierConfig(
    appName: "MyApp",
    version: "2.1",
    releaseDate: "June 25, 2025",
    enhancements: ["Faster search", "New color themes"],
    bugFixes: ["Fixed crash on startup"]
)
AppUpdateNotifierManager.shared.configure(config)

// On root view (system accent):
ContentView()
    .appUpdateNotifier()

// With AppColorStore or AppPaletteStore:
ContentView()
    .appUpdateNotifier(
        accentColor: colorStore.accentColor,
        backgroundColor: colorStore.backgroundColor
    )
```

**Storage:** `UserDefaults` with a configurable suite name.

**Files:** `Components/AppUpdateNotifier/`

---

### CustomerIdentifier ✓

Generates and persists a stable anonymous UUID for the app install. Created once on first access and stored in `UserDefaults`; never changes unless the app is deleted and reinstalled. Primarily used to correlate feedback emails, surveys, and other user-initiated events without requiring any account or login.

**Usage:**
```swift
// Simplest — uses UserDefaults.standard:
let id = CustomerIdentifier.shared.id

// With a shared suite (recommended — matches your other components):
let id = CustomerIdentifier(suiteName: "group.com.yourapp").id
```

**FeedbackManager integration:** When `FeedbackManagerConfig.includeSystemInfo` is `true`, the customer ID is automatically appended to the email footer as `ID: <uuid>`. Set `config.suiteName` to share the same UserDefaults group as your other components so the ID is consistent.

**Files:** `Components/CustomerIdentifier/`

---

### PushSurvey ✓

Presents a one-time-per-survey full-screen survey sheet after a configurable number of app launches. Questions and the survey lifecycle are driven entirely by a server-hosted JSON — no app update required to change the survey. Responses are PUT to `{responseBaseURL}/{surveyGuid}/{customerID}.json`.

**Survey lifecycle (per GUID):**
- **Dismissed** (tapped X) → re-presents next time launch conditions are met
- **Declined** ("Don't show again") → suppressed permanently for this survey GUID
- **Completed** (submitted) → suppressed until the server returns a new GUID

**Offline behavior:** if the fetch fails and no cached survey exists, the sheet is silently skipped.

**Question types:** `likert` (5-point scale: Critical → Don't care, customizable per survey) and `freeText` (always optional). All Likert questions must be answered before Submit enables.

**Server JSON format:**
```json
{
  "guid": "a1b2c3d4-...",
  "title": "Help shape what's next",
  "subtitle": "Takes about 30 seconds.",
  "minLaunches": 20,
  "scale": ["Critical", "Important", "Nice to have", "Not important", "Don't care"],
  "questions": [
    { "id": "widgets",   "type": "likert",   "prompt": "Home screen widgets" },
    { "id": "other",     "type": "freeText", "prompt": "Anything else?" }
  ]
}
```

**Response PUT body:**
```json
{
  "surveyGuid": "a1b2c3d4-...",
  "customerID": "F3A2...",
  "submittedAt": "2026-06-28T14:32:00Z",
  "responses": { "widgets": "Critical", "other": "Would love dark mode" }
}
```

**Usage:**
```swift
// In App.init:
var config = PushSurveyConfig(
    surveyURL: URL(string: "https://chainbreaker.app/surveys/current.json")!,
    responseBaseURL: URL(string: "https://chainbreaker.app/surveys")!
)
config.suiteName = "group.com.yourapp"
PushSurveyManager.shared.configure(config)
await PushSurveyManager.shared.recordLaunch()

// On root view:
ContentView()
    .pushSurvey()
```

**Files:** `Components/PushSurvey/`

---

### CategorizedAppPaletteSelection ✓

A browsable, filterable picker over **919 curated three-color palettes** transcribed from a color-theory sourcebook ("Moods and Color"). Unlike `AppPaletteSelection` (accent/background pair) or `AppColorSelection` (single accent), this component is a *catalog* the user searches by combining facets to find a palette that fits a feeling.

**Foundation — the Process Color chart:** All palettes are built from a fixed set of **107 process colors** (`ProcessColor`), indexed 1–107 — the canonical identifiers from the printed "Process Color Conversion Chart." Colors 1–106 are defined by their published **CMYK** values; **107 is white** (CMYK 0,0,0,0), introduced by the Pure/Graphic palette sets. Each `ProcessColor` converts CMYK→`Color` on demand and reports a fine-grained `HueFamily` (25 families).

**A palette = three chart numbers + moods.** `CategorizedPalette` stores the three `ProcessColor` ids (in book order) plus the descriptive **moods** the book assigns. It is the book's native format — the source schemes reference colors purely by these numbers.

**Four filter facets** (all optional, all combinable via `matches(hue:aspect:scheme:moods:)`):
- **Hue** (9) — *derived from the colors*: Red, Pink, Orange, Yellow, Green, Blue, Purple, Brown, Gray
- **Aspect** (8) — *derived from the colors* (CMYK-defined temperature/value): Hot, Cold, Warm, Cool, Light, Dark, Pale, Bright
- **Scheme** — *from the book's swatch grouping*: Achromatic, Analogous, Monochromatic, Neutral, Split Complementary, Primary, Secondary, Tertiary. (Clash and Complementary exist in the enum but the source only ever uses them for two-color sets, so no three-color palette carries them; the picker hides schemes that have zero palettes.)
- **Mood** (25) — *supplied per palette from the book*. Stored internally under the source words (`powerful`, `rich`, …; these key palette ids and frozen names), but **displayed as synonyms**: Strong, Opulent, Tender, Lively, Rustic, Genial, Gentle, Inviting, Dynamic, Refined, Stylish, Crisp, Heritage, Invigorating, Exotic, Enduring, Reliable, Serene, Majestic, Enchanting, Wistful, Vibrant, Muted, Pristine, Bold *(the "professional" mood was intentionally excluded)*.

Hue and Aspect are computed from member colors and never hand-maintained; Scheme and Mood are stored.

**Filter combination:** Hue, Aspect, and Scheme are AND-combined; **Mood is OR-combined** (a palette has one mood, so selecting Strong + Opulent shows palettes that are *either*). `dominantColor` / `lightestColor` / `darkestByLuminance` / `lightestByLuminance` / `dominantContrastColor` expose representative colors for theming UI from a selection.

**Light/Dark preview:** `CategorizedPalettePreview(palette:)` renders a side-by-side **light** and **dark** card (mirroring `AppPaletteSelection`'s two-card approach) — each shows the three colors as a swatch strip plus a sample title/caption/button, so you can judge how the palette reads on both surfaces. Selecting a palette in the catalog also tints the surrounding UI live via `.tint(dominantColor)` and a wash of `lightestColor`.

**Stable names:** Each palette has an evocative, color-derived display name (e.g. "Fierce Flame", "Sunlit Jade"). Names are **frozen** in `PaletteNames.byID` — generated once from `PaletteNaming` (mood-flavored adjective + hue noun, seeded by color ids, deterministically de-duplicated) and committed so labels never drift. `PaletteNaming` remains as the live fallback for any newly added palette.

**Only three-color palettes** were transcribed; the source's one- and two-color sets are intentionally omitted. The **Pure** and **Graphic** moods use a white-/black-based layout whose scheme labels weren't legible, so those palettes carry no `scheme` tag (`scheme == nil`).

**Usage:**
```swift
// Browse the whole library with facet filters:
CategorizedAppPaletteSelectionView()

// Pre-scope to one mood, capture the choice:
@State private var selectedID: String?

CategorizedAppPaletteSelectionView(
    palettes: CategorizedPalette.palettes(mood: .tropical),
    selection: $selectedID
) { palette in
    // palette.colorIDs, palette.swiftUIColors, palette.name, palette.hues, palette.aspects
}

// Programmatic filtering without the view:
let cool = CategorizedPalette.all.filter { $0.matches(aspect: .cool, scheme: .analogous) }
```

**Files:** `Components/CategorizedAppPaletteSelection/`
(`ProcessColor`, `PaletteFacets`, `CategorizedPalette`, `PaletteNaming`, `PaletteNames`, `PaletteData`, `CategorizedAppPaletteSelectionView`)

---

*Add new components below as they are designed.*

## Conventions

- No third-party dependencies unless absolutely necessary
- Each component's public surface is marked `public` so it compiles cleanly when copy-pasted into another module
- Use `@AppStorage` or injected stores — never `@EnvironmentObject` with app-specific types
- Prefer value types (`struct`) over classes unless reference semantics are genuinely needed
- Write at least one `#Preview` per view, covering the default state and at least one edge case

## Adding a New Component

1. Create `SharableComponents/Components/<Name>/` folder
2. Implement the view and any supporting types
3. Add a `#Preview` block
4. Document the component in this file under **Component Catalog**
5. Write a unit test in `SharableComponentsTests/` covering the core logic

## Running Tests

Open `SharableComponents.xcodeproj` in Xcode and press `Cmd+U`, or run:

```bash
xcodebuild test -project SharableComponents.xcodeproj \
  -scheme SharableComponents \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```
