# Flutter & Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hive.** { *; }
-keep class * extends com.hive.** { *; }

# WorkManager (AndroidX)
-keep class androidx.work.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Our app classes
-keep class com.pavanmekala.water_reminder.** { *; }

# Play Core split-install (referenced by Flutter engine; not used in standard APK builds)
-dontwarn com.google.android.play.core.**

# General
-dontwarn sun.misc.**
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
