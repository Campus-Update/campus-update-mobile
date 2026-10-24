<h1 align="center">
CAMPUS UPDATE — Mobile App
</h1>

<p align="center">
A Flutter mobile application that delivers verified campus information — news, announcements, events and academic dates — directly from schools to students and staff.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.35.2-blue.svg" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.9.0-0175C2.svg" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84.svg" alt="Platform" />
</p>

## 📱 About

Students currently get school information through WhatsApp groups, social media and
word of mouth — which is slow, easy to miss, and often unverified. CAMPUS UPDATE gives
schools one trusted channel to reach them directly.

Content is targeted down the hierarchy of **institution → faculty → department →
programme → level**, so students see what is relevant to them, and every item is
labelled with its source so official school communication is never confused with
sponsored or external content.

This repository is the **Student/Staff app**. The admin dashboards are separate projects.

> Everything important happening on your campus, in one place.

## 📋 Requirements

- [Flutter SDK 3.35.2](https://docs.flutter.dev/get-started/install) (Dart 3.9.0)
- [Android Studio](https://developer.android.com/studio) with Android SDK 36
- [OpenJDK 17](https://openjdk.org/projects/jdk/17/)
- [VS Code](https://code.visualstudio.com/) with the Flutter extension, or Android Studio

Verify your setup:

```bash
flutter doctor
```

## 🚀 Quick Start

### 1. Clone and install

```bash
git clone <repository-url>
cd campus-update-mobile-app
flutter pub get
```

### 2. Prepare an Android device

On the phone, enable **Developer options**, then turn on:

- **USB debugging**
- **Stay awake** — otherwise the screen locks and the dev session drops

Connect by USB and confirm it is detected:

```bash
flutter devices
```

### 3. Run

```bash
flutter run -d <device-id>
```

On Transsion phones (TECNO, Infinix, itel) a dialog asks permission for each USB
install — keep the screen unlocked and tap **Install**.

To iterate on UI without waiting for a Gradle build:

```bash
flutter run -d chrome
```

## 🔥 Development

While `flutter run` is attached:

| Key | Action |
|---|---|
| `r` | Hot reload — applies changes, keeps state |
| `R` | Hot restart — clears state |
| `q` | Quit |

Saving a file in VS Code triggers hot reload automatically. Adding a package to
`pubspec.yaml` or changing anything in `android/` needs a full `flutter run`.

## 🧪 Quality Assurance

```bash
flutter analyze     # static analysis
flutter test        # widget and unit tests
dart format .       # formatting
```

Both `analyze` and `test` should be clean before opening a pull request.

### Run the checks automatically

A pre-commit hook runs all three and blocks the commit if any fails. Enable it once
after cloning:

```bash
git config core.hooksPath hooks
```

It takes about twenty seconds per commit and catches what CI would reject, before the
push rather than after. In a genuine emergency, `git commit --no-verify` skips it — CI
still runs the same checks on the pull request.

## 🩺 Troubleshooting

**`Lost connection to device`** — the app usually keeps running; reattach instead of
rebuilding:

```bash
flutter attach -d <device-id>
```

**`adb: device not found`** — unlock the phone, then `adb kill-server && adb start-server`.

**`Skipped N frames`** — expected in debug builds on low-end devices. Measure
performance with `flutter run --profile` instead.

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Commit changes: `git commit -m 'feat: add amazing feature'`
3. Push the branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

Ensure `flutter analyze` and `flutter test` pass before opening the PR.

---

<p align="center">Built by DIVACA Tech</p>
