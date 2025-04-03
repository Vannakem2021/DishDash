# Adding Custom Fonts to DishDash App

This app uses two custom fonts:

- IBM Plex Sans: For body text
- Syne Mono: For headings

## Steps to Download and Add Fonts

1. Create a directory structure for fonts (if it doesn't exist):

   ```
   mkdir -p assets/fonts
   ```

2. Download the font files:

   ### IBM Plex Sans

   - Visit: https://fonts.google.com/specimen/IBM+Plex+Sans
   - Click the "Download family" button at the top right
   - Extract the downloaded ZIP file
   - Copy at least `IBMPlexSans-Regular.ttf` to your `assets/fonts` directory

   ### Syne Mono

   - Visit: https://fonts.google.com/specimen/Syne+Mono
   - Click the "Download family" button at the top right
   - Extract the downloaded ZIP file
   - Copy `SyneMono-Regular.ttf` to your `assets/fonts` directory

3. After adding the fonts:
   - Run `flutter pub get` to ensure the assets are recognized
   - Clean and rebuild the app

## Font Configuration

The fonts are already configured in the app:

- `pubspec.yaml` has the font declarations
- `lib/utils/app_theme.dart` is set up to use these fonts

You only need to add the actual font files to the project.
