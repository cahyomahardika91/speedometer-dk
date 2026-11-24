# Speedometer

A Flutter GPS speedometer for Android and iOS: a glowing circular dial with a
digital read-out, three speed units, a configurable speed limit with a beeping
alert, and live trip statistics.

## Features

- Live speed from the device GPS, smoothed so the needle glides.
- Animated gauge: gradient arc, tick scale, limit marker, needle, glow that
  shifts from cyan to amber to red as the limit approaches and is exceeded.
- Digital speed display in the middle of the dial.
- Units: `km/h`, `m/s` and `mph` — switchable at any time, without altering the
  recorded trip values.
- Speed limit: slider, quick presets, arm/disarm switch. When the limit is
  exceeded the dial pulses, a `LIMIT EXCEEDED` badge appears and a bundled beep
  repeats until the speed drops back under the limit.
- Average speed, top speed and distance for the current trip, resettable, with
  pause/resume of trip tracking from the `LIVE` badge.
- Settings (unit, limit, alert sound) persist between launches.
- Handles location permission, permanently denied permission and location
  services being switched off, with a banner that leads to the right fix.

## Architecture

Clean Architecture, one feature (`speedometer`), BLoC for state:

```
lib/
  core/                 theme, formatter, beep player, composition root
  features/speedometer/
    domain/             entities, repository contracts, use cases
      entities/         SpeedUnit, SpeedSample, TripStats, SpeedSettings,
                        LocationReadiness
      repositories/     LocationRepository, SettingsRepository, AlertRepository
      usecases/         WatchSpeed, CheckLocationReadiness,
                        OpenLocationSettings, LoadSettings, SaveSettings,
                        PlayAlert
    data/               data sources + repository implementations
      datasources/      GeolocatorLocationDataSource,
                        SharedPreferencesSettingsDataSource
      repositories/     *_impl
    presentation/       BLoC + widgets + page
      bloc/             SpeedometerEvent, SpeedometerState, SpeedometerBloc
      pages/            SpeedometerPage
      widgets/          SpeedGauge, DigitalSpeedDisplay, UnitSelector,
                        StatsPanel, SpeedLimitSheet
```

Dependencies point inwards: presentation depends on use cases, use cases on
repository contracts, and the data layer implements those contracts. Every
dependency is wired once in `lib/core/di/injection.dart`.

The BLoC owns the alarm: crossing the limit starts a repeating beep timer,
dropping back under it (or muting, or disarming the limit) stops it.

## Running

```bash
flutter pub get
flutter run            # a connected device or emulator
flutter analyze
flutter test
```

Android needs the location permissions declared in
`android/app/src/main/AndroidManifest.xml` (already added), and iOS needs the
usage strings in `ios/Runner/Info.plist` (also added). GPS speed is only
meaningful on a physical device; emulators report the speed you feed them.

## Packages

`flutter_bloc` + `equatable` (state), `geolocator` (GPS), `shared_preferences`
(settings), `audioplayers` (limit beep, `assets/sounds/beep.wav`).
