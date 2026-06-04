---
name: react-native-expo
description: Implements React Native and Expo screens, navigation, and native-safe UI in this repo. Use when editing app/, components, or when the user mentions React Native or Expo.
disable-model-invocation: true
---

# React Native / Expo

## Paths

- App entry: `{{ROUTES_PATH}}` (e.g. `app/` for Expo Router)
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Prefer platform-safe APIs; avoid web-only DOM APIs.
- Match existing navigation (Expo Router, React Navigation) before adding routes.
- Test on the simulator/emulator the team uses; do not assume web CSS.

## Do not edit

{{FORBIDDEN_PATHS}}, `ios/build`, `android/build`, `.expo`
