# ML Kit : les scripts optionnels (coreen, japonais, chinois, devanagari)
# ne sont pas embarques ; on ignore les avertissements R8 correspondants.
-dontwarn com.google.mlkit.vision.text.**
-keep class com.google.mlkit.** { *; }

# Firebase / Google Play services
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Play Core : composants differes Flutter (splitinstall) non utilises
-dontwarn com.google.android.play.core.**

# Flutter
-keep class io.flutter.** { *; }
