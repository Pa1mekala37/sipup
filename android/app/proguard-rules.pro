# Flutter & Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hive.** { *; }
-keep class * extends com.hive.** { *; }

# WorkManager
-keep class androidx.work.** { *; }
-keep class be.tramckrijte.workmanager.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Our app classes
-keep class com.pavanmekala.water_reminder.** { *; }

# General
-dontwarn sun.misc.**
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
