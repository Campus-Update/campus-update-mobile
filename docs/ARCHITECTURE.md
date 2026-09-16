# CAMPUS UPDATE — Mobile App Architecture

Flutter application for the CAMPUS UPDATE platform (DIVACA Tech).
This document describes how the mobile codebase is organised and why.

**Scope:** the Student/Staff mobile app only. The School Admin and Super Admin
dashboards are separate surfaces and are not part of this repository.

---

## 1. Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Routing | `go_router` — declarative routes + shell route for the tab bar |
| State | Riverpod — covers both client state and server-state caching |
| HTTP | `dio` with interceptors |
| API models | generated from the backend OpenAPI/Swagger spec — never hand-edited |
| Secure storage | `flutter_secure_storage` — auth tokens |
| Preferences | `shared_preferences` — non-sensitive settings |
| Push | `firebase_core` + `firebase_messaging` (FCM only — no Firestore, no Firebase Auth) |
| Dates | `intl` |

Package identifiers:

```
Android applicationId   com.divacatech.campus_update
iOS bundle identifier   com.divacatech.campusUpdate
```

These differ by design — iOS bundle IDs cannot contain underscores. Both must be
registered separately in Firebase.

---

## 2. Folder structure

```
lib/
├── main.dart                          entry point only
│
├── app/
│   ├── app.dart                       MaterialApp.router, theme, localisation
│   ├── router.dart                    routes + tab shell
│   └── theme/
│       ├── app_theme.dart             ThemeData light + dark
│       ├── app_colors.dart            semantic colour tokens
│       ├── app_text_styles.dart       type scale
│       └── app_spacing.dart           spacing scale
│
├── core/                              cross-cutting infrastructure
│   ├── network/
│   │   ├── dio_client.dart            base URL, timeouts
│   │   ├── auth_interceptor.dart      token injection + single-flight refresh
│   │   └── api_exception.dart         error normalising
│   ├── auth/
│   │   ├── auth_repository.dart       login, register, refresh, logout
│   │   └── auth_state.dart            signed in / out / loading
│   ├── storage/
│   │   ├── secure_storage.dart        tokens
│   │   └── prefs_storage.dart         preferences
│   ├── notifications/
│   │   ├── fcm_service.dart           token registration, message handlers
│   │   └── notification_router.dart   deep-link a notification tap to a screen
│   ├── analytics/
│   │   └── analytics_service.dart     MVP success metrics
│   ├── env/
│   │   └── env.dart                   dev / staging / prod configuration
│   └── lifecycle/
│       └── app_lifecycle_observer.dart  foreground / background transitions
│
├── shared/
│   ├── domain/                        models used by every feature
│   │   ├── audience_target.dart       institution → faculty → department →
│   │   │                              programme → level, plus role
│   │   ├── content_source.dart        officialSchool | campusUpdate |
│   │   │                              sponsored | externalEvent
│   │   └── content_item.dart          base: id, title, body, images, source,
│   │                                  target, publishedAt
│   ├── widgets/                       design system primitives
│   │   ├── widgets.dart               barrel export
│   │   ├── screen_header.dart         back arrow, centred title, spacer
│   │   ├── app_scaffold.dart          standard page shell + safe area
│   │   ├── app_button.dart
│   │   ├── app_input.dart
│   │   ├── app_search_bar.dart
│   │   ├── loader.dart
│   │   ├── empty_state.dart
│   │   ├── error_state.dart
│   │   ├── source_badge.dart          the trust indicator — see §6
│   │   └── content_card.dart          the card every content type renders as
│   └── utils/
│       ├── date_format.dart
│       └── validators.dart
│
└── features/
    ├── home/
    │   └── presentation/screens/      home — aggregates the other surfaces
    │
    ├── auth/
    │   ├── domain/                    Credentials, AuthUser
    │   ├── data/
    │   └── presentation/
    │       ├── screens/               splash, login, register, forgot_password
    │       └── widgets/               institution → level cascade picker
    │
    ├── news/
    │   ├── domain/news_item.dart      category
    │   ├── data/news_repository.dart
    │   └── presentation/
    │       ├── screens/               news_list, news_detail
    │       └── widgets/               category_chips, news_tile
    │
    ├── announcements/
    │   ├── domain/announcement.dart   urgency: normal | important | urgent
    │   ├── data/
    │   └── presentation/screens/ + widgets/
    │
    ├── events/
    │   ├── domain/event.dart          official | external, date, location
    │   ├── data/
    │   └── presentation/screens/ + widgets/
    │
    ├── calendar/
    │   ├── domain/calendar_entry.dart exam | registration | resumption | holiday
    │   ├── data/
    │   └── presentation/screens/ + widgets/
    │
    ├── notifications/
    │   ├── domain/notification_item.dart   read / unread
    │   ├── data/
    │   └── presentation/screens/
    │
    └── profile/
        ├── domain/user_profile.dart
        ├── data/
        └── presentation/
            ├── screens/               profile, edit_profile, preferences
            └── widgets/               personalised vs all-campus toggle
```

---

## 3. Screens and navigation

### Entry chain

```
main.dart          runApp(CampusUpdateApp())        — nothing else lives here
  └─ app.dart      MaterialApp.router + theme
       └─ router.dart   route table + tab shell
```

`main.dart` stays at a handful of lines permanently. Everything it would otherwise
hold — theme, routing, providers — belongs in `app/`.

### Navigation shape

Two zones, gated on auth state. Unauthenticated users can reach nothing in the
main shell; the router redirects to `/login`.

```
UNAUTHENTICATED
  /splash                     session restore, branding
  /onboarding                 first-run only
  /login
  /register                   multi-step — see cascade below
  /forgot-password

AUTHENTICATED — bottom tab shell, tabs persist across navigation
  /home            [tab 1]    default landing, aggregates the other surfaces
  /news            [tab 2]
  /announcements   [tab 3]
  /events          [tab 4]
  /profile         [tab 5]

  inside the active tab, so the tab bar stays:
    /news/:id
    /announcements/:id
    /events/:id
    /profile/edit
    /profile/preferences        personalised vs all-campus, notification settings

  above the shell, popping back to the active tab:
    /calendar                   the school calendar, opened from Home
    /notifications              the notification centre
    /search                     cross-content search
```

Detail routes sit above the tab bar rather than replacing it, so a notification
tap that deep-links to `/announcements/:id` returns the user to a sensible tab
on back.

### Screen inventory

| # | Screen | Route | Notes |
|---|---|---|---|
| 1 | Splash | `/splash` | session restore, decides auth zone |
| 2 | Onboarding | `/onboarding` | first run only |
| 3 | Login | `/login` | |
| 4 | Register | `/register` | multi-step, includes the audience cascade |
| 6 | Forgot password | `/forgot-password` | |
| 5 | Home | `/home` | default landing; surfaces announcements, news, events, calendar |
| 7 | News list | `/news` | categories, search, pagination |
| 8 | News detail | `/news/:id` | images, source badge |
| 9 | Announcements list | `/announcements` | urgency treatment per item |
| 10 | Announcement detail | `/announcements/:id` | |
| 11 | Events list | `/events` | official and external mixed |
| 12 | Event detail | `/events/:id` | date, time, location, registration info |
| 13 | Calendar | `/calendar` | month + agenda views; opened from Home, not a tab |
| 14 | Notification centre | `/notifications` | read/unread state |
| 15 | Profile | `/profile` | institution, faculty, department, level |
| 16 | Edit profile | `/profile/edit` | |
| 17 | Preferences | `/profile/preferences` | personalised vs all-campus, push settings |
| 18 | Search | `/search` | across news, announcements, events |

Eighteen screens. Every list screen needs loading, empty and error states, which
is why those live in `shared/widgets/` rather than being written per feature.

**No verification screen.** The approved PRD (16 Sep 2026) has no verification
step: a user creates an account, selects their institution, provides profile
details and enters the app. Institution isolation is enforced by targeting, not
by proving identity.

**Six surfaces, five tabs.** Adding Home would make six tabs, which does not fit
a 720px phone. Calendar is the one that moves — it is consulted occasionally
rather than daily — and opens from Home.

### The registration cascade

The most involved screen in the app. It collects the user's position in the
audience hierarchy, each step filtered by the previous:

```
Institution → Faculty → Department → Programme → Level → Student | Staff
```

Every selection narrows the next. This drives the whole targeting model, so the
values must come from the backend rather than being hardcoded in the app.

### Screens buildable before designs or API

Every screen can be built against mock repositories. The layouts change when
designs land; the routing, state handling and data flow do not.

## 4. Layer rules

1. **`domain/` is pure Dart.** No Flutter imports, no widgets. Models only.
2. **`presentation/` never calls `dio` directly.** It goes through `data/`.
   This is what allows screens to be built against mock repositories before the
   API exists, and to swap to the generated client by changing one file.
3. **Routes are containers; screens are presentational.** The route widget reads
   providers and passes plain values and callbacks into a widget that only renders.
4. **A widget starts in its feature.** It moves to `shared/widgets/` only when a
   second feature imports it. Promoting later is a one-line import change;
   guessing "shared" too early produces a junk drawer.
5. **Colours are referenced semantically** — `colorScheme.surface`, not a hex
   value. This is what makes dark mode work.

---

## 5. The audience hierarchy

Every piece of content is addressed to a slice of this tree:

```
Institution → Faculty → Department → Programme → Level
                                  ×  Student | Staff
```

This is the spine of the product, not a profile detail. It determines:

- what the feed query returns for a given user
- how push notifications are targeted
- what the sign-up cascade must collect

Users choose one of two modes in Profile:

- **Personalised** — content matching their position in the hierarchy
- **All Campus** — everything for their institution

`AudienceTarget` therefore lives in `shared/domain/`, not in any one feature.

---

## 6. Trust and verification

Section 8 of the PRD requires that users can immediately identify where
information came from. Every content item renders a `SourceBadge`:

```
Official  |  Official Event  |  Campus Update  |  Sponsored  |  Promoted Event
```

Wording follows the PRD and depends on content type: official news reads
"Official", an official event reads "Official Event", and a paid external event
reads "Promoted Event". `ContentSource.labelFor(ContentType)` resolves it.

Announcement priority is a separate badge, `UrgencyBadge`. The PRD requires
priority to be distinguishable **not by colour alone**, so each level carries
its own icon and word; colour only reinforces.

`source_badge.dart` and `content_card.dart` are the highest-leverage widgets in
the codebase — every screen renders them — and should be built first.

---

## 7. Content model

News, Announcements, Events and Calendar entries share one shape: an author, an
audience target, a source label, a timestamp and a body. They are modelled as a
common base with variants rather than four parallel implementations, because the
feed, search and notification centre all handle them uniformly.

---

## 8. Backend integration

The app does not own any data. The backend API is the source of truth.

If the backend exposes an OpenAPI/Swagger endpoint, the data layer is generated
(`swagger_parser` or openapi-generator producing Dart + `dio`) rather than
hand-written, and regenerated whenever the spec changes.

`auth_interceptor.dart` handles token injection and refresh. Refresh must be
**single-flight**: concurrent 401s queue behind one refresh call rather than
firing N parallel refreshes, which otherwise causes spurious logouts.

---

## 9. Push notifications

FCM only — `firebase_core` and `firebase_messaging`. No Firestore, no Firebase
Auth, no Firebase as backend.

FCM is unavoidable for Android push: it is the only channel that can deliver to
an app that is not currently running. Third-party services (OneSignal, Airship)
wrap FCM rather than replace it.

The backend must store device tokens mapped to the audience hierarchy so that
fan-out can target the same slices the content model uses.

---

## 10. Platform status

**Android** is the current target. The pilot audience is FOCIT students, where
Android share is dominant, so Android-first is correct sequencing rather than a
workaround.

**iOS** is deferred pending hardware. Deferred work is bounded and configuration-
shaped, not a rewrite:

- `GoogleService-Info.plist` and Firebase iOS registration
- APNs key for push
- Signing, provisioning, App Store Connect
- CocoaPods, `Info.plist` permission strings

To keep iOS cheap, verify iOS support on pub.dev before adding any package, and
keep platform-specific code isolated rather than scattered through widgets.

---

## 11. Build configuration

`android/gradle.properties` sets:

```
org.gradle.jvmargs=-Xmx2G -XX:MaxMetaspaceSize=512m
```

Flutter's template default is `-Xmx8G -XX:MaxMetaspaceSize=4G`, which exceeds
physical RAM on 8 GB machines and causes swapping or OOM. 2 GB is sufficient for
a project of this size. Raise it if release builds with R8 ever hit an
`OutOfMemoryError`.

---

## 12. Open questions

Updated 16 Sep 2026 against the approved PRD and the backend's integration guide.

**Answered**

- **User verification** — not in the MVP. The approved PRD has no verification
  step, so there is no `/verify` screen and registration goes straight to the
  app.
- **API contract** — ASP.NET Core 10, a single REST API rather than a BFF.
  `api/openapi-v1.json` holds the contract.

**Still open, and who owns each**

1. **Enums in the spec** *(backend)*. Declared `integer`, serialised as strings.
   Generating a client before this is fixed produces `int` fields and every
   response fails to parse. Blocks the generated data layer.
2. **No deployed server** *(backend)*. Everything is localhost, so nothing can
   be verified end to end on a device.
3. **Calendar shape** *(backend)*. The PRD requires session, semester,
   registration, examination, resumption and holiday dates, each openable with a
   title, category and description. The API returns one image URL.
4. **Matriculation number** *(backend / product)*. `POST /auth/register`
   requires it; the PRD's profile does not list it.
5. **Search and news categories** *(backend)*. Both required by the PRD, neither
   present in the API.
6. **Push** *(backend)*. Not implemented. The PRD makes it a per-announcement
   choice by the publisher, explicitly not driven by priority, so the API needs
   that flag and device tokens mapped to the audience hierarchy.
7. **Palette and type scale** *(design)*. Placeholders are in place; swapping
   them is one file.
8. **Offline behaviour** *(product)*. Unspecified, but pilot users are students
   on poor connectivity.
