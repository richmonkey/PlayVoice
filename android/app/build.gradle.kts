plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.beetle.playvoice"
    compileSdk {
        version = release(37)
    }

    defaultConfig {
        applicationId = "com.beetle.playvoice"
        minSdk = 24
        targetSdk = 37
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    buildTypes {
        release {
            optimization {
                enable = false
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation(project(":room"))
    // Local AARs are packaged by the app; :room uses them only for compilation.
    implementation(files("../room/libs/libwebrtc.aar", "../room/libs/protooclient.aar"))

    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)
}
