# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**시장여지도 (SijangYeojido)** — A Flutter app for navigating traditional Korean markets with an interactive map, store info, deals, and reservations.

## Common Commands

```bash
# Run the app
flutter run

# Build for specific platform
flutter build ios
flutter build apk

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get
```

## Architecture

**State management:** Stateful widgets + `setState()` only — no Provider, Bloc, or Riverpod.

**Navigation:** `Navigator.push/pop` for screen transitions; `IndexedStack` for bottom tab navigation in `MainScaffold`.

**Data layer:** All data is mocked in `lib/data/mock_data.dart` — no backend or persistence.

### Screen Flow

```
MarketSelectionScreen  →  MainScaffold
                              ├── Tab 0: MarketMapScreen
                              │      └── StoreDetailScreen → DealDetailScreen
                              ├── Tab 1: ReservationListScreen
                              └── Tab 2: ProfileScreen
```

### Key Files

| File | Role |
|------|------|
| `lib/main.dart` | Entry point, status bar config |
| `lib/screens/market_selection_screen.dart` | Market picker (first screen) |
| `lib/screens/main_scaffold.dart` | Bottom tab shell |
| `lib/screens/map/market_map_screen.dart` | Interactive map with filter/search; uses `DraggableScrollableSheet` |
| `lib/screens/map/market_painter.dart` | `CustomPainter` for zones, aisles, POIs, store pins; includes tap hit detection |
| `lib/models/models.dart` | All data models (`Store`, `Deal`, `Zone`, `POI`, `Reservation`) and enums |
| `lib/data/mock_data.dart` | Mock stores, deals, POIs |
| `lib/theme/app_colors.dart` | All color constants |
| `lib/theme/app_theme.dart` | `ThemeData` config (Noto Sans KR, component themes) |

### Map Coordinate System

Store and POI positions use normalized coordinates (0.0–1.0) stored in `mapX`/`mapY`. `MarketPainter` scales these to canvas size at paint time. Hit detection uses a 20px radius around each store's scaled position.

### Map Zones

Four zones (A–D) are painted as colored rects with normalized boundaries. Zone A = textiles, B = food, C = seafood, D = produce.

### Deals & Reservations

`Deal` has `remainingQty`, `expiresAt`, and a computed `discountPercent`. `Reservation` is created in `DealDetailScreen` and shown in `ReservationListScreen`. Both are in-memory only (lost on restart).

## Dependencies

- `google_fonts: ^6.2.1` — Noto Sans KR typography
- `intl: ^0.19.0` — Number/currency formatting
- `cupertino_icons: ^1.0.8` — iOS icons

## Language & Locale

UI text is in Korean. Variable/method names are in English. Korean text literals appear directly in widget code (no localization layer).
