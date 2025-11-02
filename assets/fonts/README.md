# Poppins Font Setup

To complete the Poppins font setup, please download the font files from Google Fonts and place them in this directory:

1. Go to https://fonts.google.com/specimen/Poppins
2. Download the following files and place them in this directory:
   - Poppins-Regular.ttf (weight: 400)
   - Poppins-Medium.ttf (weight: 500)
   - Poppins-SemiBold.ttf (weight: 600)
   - Poppins-Bold.ttf (weight: 700)

Alternatively, you can download all weights and select only the ones listed above.

**Note**: The `google_fonts` package in pubspec.yaml provides a fallback, so the app will work even without local font files, but for best performance and offline availability, it's recommended to add the local font files.
