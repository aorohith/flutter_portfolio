# Flutter Portfolio

Flutter web portfolio with dark/light theming, section navigation, and a live
contact form submission flow.

## Run Locally

```bash
flutter pub get
flutter run -d chrome
```

## Contact Form Setup (Formspree)

1. Create a form endpoint in [Formspree](https://formspree.io/).
2. Pass it through `CONTACT_FORM_ENDPOINT` when running/building.

Example:

```bash
flutter run -d chrome \
  --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId
```

Production build:

```bash
flutter build web --release \
  --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId
```

If the endpoint is not configured, the app keeps email/phone visible and shows
an inline fallback message instead of silently failing.

## Free Hosting Options

### Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
```

Set `build/web` as the public directory, then deploy:

```bash
firebase deploy
```

### Cloudflare Pages

1. Create a Pages project from your Git repository.
2. Build command:
   `flutter build web --release --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId`
3. Output directory: `build/web`

## Resume Link Recommendation

Use a stable HTTPS URL (custom domain preferred), for example:

- `https://yourname.dev`
- `https://portfolio.yourname.dev`
