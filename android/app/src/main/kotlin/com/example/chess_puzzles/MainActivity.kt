package com.example.chess_puzzles

import android.app.ActivityManager
import android.graphics.BitmapFactory
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		// Ensure the task description (recent apps) uses the same launcher icon.
		// Wrap in a try/catch to avoid process crash on some devices/ROMs if icon decoding fails.
		try {
			val icon = BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
			val label = applicationInfo.loadLabel(packageManager).toString()
			this.setTaskDescription(ActivityManager.TaskDescription(label, icon))
		} catch (t: Throwable) {
			// Log the error but continue so the app doesn't crash on startup.
			Log.w("MainActivity", "Failed to set task description", t)
		}
	}
}
