How to set a single logo for the app (launcher, round, splash screens)

1) Place your final logo PNG at `assets/logo.png` (preferably a square, 512x512 PNG). Replace the existing placeholder if present.

2) Run this script to copy `assets/logo.png` to all Android `mipmap-*/` folders as `ic_launcher.png` and `ic_launcher_round.png`:
```bash
cd tools
./generate_icons.sh
```

3) Clean Flutter build and rebuild the app:
```bash
flutter clean
flutter build apk --release
```

Notes:
- This project uses `@mipmap/ic_launcher` as the launcher icon and now creates a round icon `@mipmap/ic_launcher_round` as well.
- The splash screen is updated to show `@mipmap/ic_launcher` centered — edit `android/app/src/main/res/drawable(-v21)/launch_background.xml` if you want a different layout.
- If you prefer vector or adaptive icons (vector/foreground/background), consider using the `flutter_launcher_icons` package to generate them with proper scaling.
 
Optional: Generate proper icon sizes from a single 512x512 `assets/logo.png` using ImageMagick:

```bash
cd tools
chmod +x generate_icons_from_png.sh
./generate_icons_from_png.sh
```

This will generate scaled versions for each mipmap density before you copy them into the app.
