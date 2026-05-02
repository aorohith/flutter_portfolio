# Flutter Portfolio

Flutter web portfolio with dark/light theming, anchored section navigation, and
a contact form that posts to your own HTTPS endpoint (recommended:
[Formspree](https://formspree.io/)).

---

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel, Flutter 3+ / Dart 3)
- Chrome (for `flutter run -d chrome`)
- Optional: [Firebase CLI](https://firebase.google.com/docs/cli) for hosting deploys

---

## Getting started

```bash
git clone <your-repo-url>
cd flutter_portfolio
flutter pub get
```

Configure the contact endpoint (next section), then:

```bash
flutter run -d chrome --dart-define-from-file=dart_defines.json
```

---

## Configuration: compile-time defines

The app does **not** load secrets from `.env` at runtime on web. The contact
endpoint is injected at **compile time** using Dart defines.

### Files

| File | Version control | Purpose |
|------|-----------------|----------|
| [`dart_defines.example.json`](dart_defines.example.json) | **Tracked** | Template; copy to create your local defines file. |
| `dart_defines.json` | **Ignored** ([`.gitignore`](.gitignore)) | Your real `CONTACT_FORM_ENDPOINT`. Keeps form URLs off the remote if you prefer. |

Create your local file from the template:

```bash
cp dart_defines.example.json dart_defines.json
```

Edit `dart_defines.json` to a valid JSON object with string values, for example:

```json
{
  "CONTACT_FORM_ENDPOINT": "https://formspree.io/f/yourFormId"
}
```

Pass it on every **run** and **build** that should submit the contact form:

```bash
flutter run -d chrome --dart-define-from-file=dart_defines.json
flutter build web --release --dart-define-from-file=dart_defines.json
```

### Alternative: inline `--dart-define`

Equivalent to setting the same key without a file:

```bash
flutter run -d chrome \
  --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId
```

### Where it is read in code

[`CONTACT_FORM_ENDPOINT`](lib/features/portfolio/presentation/pages/portfolio_page.dart)
is compiled via `String.fromEnvironment('CONTACT_FORM_ENDPOINT')` inside
`_ContactSectionState`. If the string is **empty**, submit shows an in-app
error and directs users to email/phone from
[`assets/data/portfolio_content.json`](assets/data/portfolio_content.json).

### IDE (VS Code / Cursor)

[`.vscode/launch.json`](.vscode/launch.json) includes:

- **flutter_portfolio** — runs without reading `dart_defines.json` (contact submit will error until you configure defines another way).
- **flutter_portfolio (with contact endpoint)** — passes `--dart-define-from-file=dart_defines.json` (requires `dart_defines.json` to exist beside [`pubspec.yaml`](pubspec.yaml)).

### New clones and CI

Because `dart_defines.json` is gitignored, anyone cloning the repo must copy
from [`dart_defines.example.json`](dart_defines.example.json) (or inject the
same keys via CI secrets using `--dart-define=CONTACT_FORM_ENDPOINT=...`).

---

## Contact form — behavior and dependencies

### Packages ([`pubspec.yaml`](pubspec.yaml))

| Package | Role |
|---------|------|
| [`http`](https://pub.dev/packages/http) | `POST` to `CONTACT_FORM_ENDPOINT`. |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Persists submit cooldown (see below). |

There is no backend in this repository; the browser sends requests directly to
your endpoint.

### Request shape

Implementation reference: `_ContactSectionState._handleSubmit` in
[`portfolio_page.dart`](lib/features/portfolio/presentation/pages/portfolio_page.dart).

1. **Formspree** — if the endpoint host ends with `formspree.io`:
   - Method: `POST`
   - `Content-Type: application/x-www-form-urlencoded`
   - `Accept: application/json`
   - Body fields: `name`, `email`, `_replyto` (same as email), `message`,
     `source` (literal `portfolio-web`), `submittedAt` (ISO-8601).

2. **Any other HTTPS URL** — JSON body:
   - `Content-Type: application/json`
   - `Accept: application/json`
   - Fields: `name`, `email`, `message`, `source` (`portfolio-web`),
     `submittedAt` (ISO-8601).

The app treats HTTP **2xx** as success; other status codes surface a generic
send error.

### Cooldown

After a **successful** submit, the app stores a timestamp under the key
`last_contact_submit_at_ms` in `shared_preferences`. Another send is blocked for
**5 minutes** with a user-visible wait message.

### CORS (web)

Flutter Web runs in the browser. The endpoint must allow cross-origin `POST`
from your hosting origin (e.g. Firebase Hosting). Formspree and similar hosts
typically allow this; custom APIs must return appropriate `Access-Control-*`
headers.

### Testing

`flutter test` does not require `dart_defines.json` unless you add tests that
assert a configured endpoint. Widget tests use a test binding; contact HTTP is
only exercised when code paths run a real submit.

---

## Formspree setup

1. Create a form at [formspree.io](https://formspree.io/).
2. Copy the form’s `POST` URL (e.g. `https://formspree.io/f/xxxxx`).
3. Set it as `CONTACT_FORM_ENDPOINT` in `dart_defines.json` or pass
   `--dart-define=...` on build.

### Other providers (e.g. Web3Forms)

Use their HTTPS POST URL. If the host is **not** `formspree.io`, the app sends
**JSON** as described above. If the provider expects different field names or
form encoding, use a small proxy or a provider that accepts that JSON shape.

---

## Firebase hosting

This repo targets Firebase project **`rohithao-portfolio`**:

- [`.firebaserc`](.firebaserc) — default project alias
- [`firebase.json`](firebase.json) — `public: build/web`, SPA rewrite to `index.html`

**Build** (with contact endpoint) then **deploy**:

```bash
flutter build web --release --dart-define-from-file=dart_defines.json
npx -y firebase-tools@latest deploy --only hosting --project rohithao-portfolio
```

Ensure the Formspree form (or your backend) allows requests from your deployed
domain if CORS applies.

---

## Resume / profile URL

Prefer a stable HTTPS URL (custom domain if you have one), for example:

- `https://yourname.dev`
- `https://portfolio.yourname.dev`
