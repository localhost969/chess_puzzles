This folder should contain the font files used by the app. To make fonts work offline, download the following open-source fonts and place the required TTF files here:

- Poppins (https://fonts.google.com/specimen/Poppins)
  - Poppins-Regular.ttf
  - Poppins-Medium.ttf
  - Poppins-SemiBold.ttf

- Orbitron (https://fonts.google.com/specimen/Orbitron)
  - Orbitron-Regular.ttf
  - Orbitron-Bold.ttf

Make sure to re-run:
```bash
flutter pub get
```
You can automatically fetch the above fonts using the included script:
```bash
chmod +x tools/fetch_fonts.sh
./tools/fetch_fonts.sh
flutter pub get
```

If you want to use different fonts, change the entries in pubspec.yaml to match the file names you add.
