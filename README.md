# Flutter Portfolio

Flutter web portfolio with dark/light theming, section navigation, and a live
contact form submission flow.

## Run Locally

```bash
flutter pub get
flutter run -d chrome
```

## Firebase Setup (Free Tier Only)

This repository is preconfigured for Firebase project `rohithao-portfolio`:

- `.firebaserc` points to `rohithao-portfolio`
- `firebase.json` configures Hosting only (`build/web` + SPA rewrite)

Use Firebase for static web hosting and use a free form provider
(Formspree/Web3Forms) as `CONTACT_FORM_ENDPOINT`.

### Example with Formspree

1. Create a form endpoint at [Formspree](https://formspree.io/).
2. Build/run with that endpoint:

```bash
flutter run -d chrome \
  --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId
```

Production:

```bash
flutter build web --release \
  --dart-define=CONTACT_FORM_ENDPOINT=https://formspree.io/f/yourFormId
npx -y firebase-tools@latest deploy --only hosting --project rohithao-portfolio
```

If `CONTACT_FORM_ENDPOINT` is not provided, the app shows a fallback error
instead of silently failing.

## Resume Link Recommendation

Use a stable HTTPS URL (custom domain preferred), for example:

- `https://yourname.dev`
- `https://portfolio.yourname.dev`
