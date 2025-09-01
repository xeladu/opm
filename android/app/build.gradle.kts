plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "org.quickcoder.open_password_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "org.quickcoder.open_password_manager"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val props = mutableMapOf<String, String>()
                keystorePropertiesFile.readLines().forEach { line ->
                    if (line.contains("=") && !line.startsWith("#")) {
                        val (key, value) = line.split("=", limit = 2)
                        props[key.trim()] = value.trim()
                    }
                }

                val storeFilePath = props["storeFile"]
                val storePass = props["storePassword"]
                val keyPass = props["keyPassword"]
                val keyAliasName = props["keyAlias"]
                
                if (!storeFilePath.isNullOrEmpty() && !storePass.isNullOrEmpty() && 
                    !keyPass.isNullOrEmpty() && !keyAliasName.isNullOrEmpty()) {
                    val keystoreFile = rootProject.file(storeFilePath)
                    if (keystoreFile.exists()) {
                        storeFile = keystoreFile
                        storePassword = storePass
                        keyAlias = keyAliasName
                        keyPassword = keyPass
                    } 
                } 
            } 
        }
    }

    buildTypes {
        release {
            // Try to use release signing config, fallback to debug if it's incomplete
            val releaseConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseConfig.storeFile != null && 
                               releaseConfig.storePassword != null && 
                               releaseConfig.keyAlias != null && 
                               releaseConfig.keyPassword != null) {
                println("Using release signing config")
                releaseConfig
            } else {
                println("Release signing config incomplete, using debug config")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
