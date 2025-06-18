buildscript {
    // repositories {
    //     google()
    //     mavenCentral()
    // }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// allprojects {
//     repositories {
//         google()
//         mavenCentral()
//     }
// }

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

// Plugin namespace fixes for AGP 8.x compatibility
subprojects {
    pluginManager.withPlugin("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            when (project.name) {
                "flutter_inappwebview" -> {
                    if (namespace == null) {
                        namespace = "com.pichillilorenzo.flutter_inappwebview"
                        println("Applied namespace fix for flutter_inappwebview")
                    }
                }
                "flutter_local_notifications" -> {
                    if (namespace == null) {
                        namespace = "com.dexterous.flutterlocalnotifications"
                        println("Applied namespace fix for flutter_local_notifications")
                    }
                }
                "permission_handler_android" -> {
                    if (namespace == null) {
                        namespace = "com.baseflow.permissionhandler"
                        println("Applied namespace fix for permission_handler_android")
                    }
                }
                "url_launcher_android" -> {
                    if (namespace == null) {
                        namespace = "io.flutter.plugins.urllauncher"
                        println("Applied namespace fix for url_launcher_android")
                    }
                }
                "package_info_plus" -> {
                    if (namespace == null) {
                        namespace = "dev.fluttercommunity.plus.packageinfo"
                        println("Applied namespace fix for package_info_plus")
                    }
                }
                "shared_preferences_android" -> {
                    if (namespace == null) {
                        namespace = "io.flutter.plugins.sharedpreferences"
                        println("Applied namespace fix for shared_preferences_android")
                    }
                }
                "file_picker" -> {
                    if (namespace == null) {
                        namespace = "com.mr.flutter.plugin.filepicker"
                        println("Applied namespace fix for file_picker")
                    }
                }
                "webview_flutter_android" -> {
                    if (namespace == null) {
                        namespace = "io.flutter.plugins.webviewflutter"
                        println("Applied namespace fix for webview_flutter_android")
                    }
                }
                "uni_links" -> {
                    if (namespace == null) {
                        namespace = "name.avioli.unilinks"
                        println("Applied namespace fix for uni_links")
                    }
                }
            }
        }
    }
}
