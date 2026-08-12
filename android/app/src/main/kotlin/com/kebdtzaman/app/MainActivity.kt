package com.kebdtzaman.app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by local_auth's
// Android implementation, which hosts the biometric prompt as a
// DialogFragment.
class MainActivity : FlutterFragmentActivity()
