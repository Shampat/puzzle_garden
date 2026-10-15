-keep class io.flutter.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.ump.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# WorkManager - MUST keep or it crashes on startup
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase$* { *; }
-keep class androidx.startup.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses

-dontwarn androidx.work.**
-dontwarn com.google.android.gms.**
