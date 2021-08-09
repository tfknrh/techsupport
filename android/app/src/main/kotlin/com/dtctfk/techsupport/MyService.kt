package com.dtctfk.techsupport


import androidx.annotation.NonNull
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.widget.Toast


class MyService : Service() {
   
   override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
      onTaskRemoved(intent)
      // Toast.makeText(
      // applicationContext, "This is a Service running in Background",
      // Toast.LENGTH_SHORT
      // ).show()
 

      return START_STICKY
   }
   override fun onBind(intent: Intent): IBinder? {
      // TODO: Return the communication channel to the service.
      throw UnsupportedOperationException("Not yet implemented")
   }
   override fun onTaskRemoved(rootIntent: Intent) {
      val restartServiceIntent = Intent(applicationContext, this.javaClass)
      restartServiceIntent.setPackage(packageName)
      startService(restartServiceIntent)
      super.onTaskRemoved(rootIntent)
   }
//   fun GetMethodChannel(context: Context): MethodChannel? {
//         FlutterMain.startInitialization(context)
//         FlutterMain.ensureInitializationComplete(context, arrayOfNulls<String>(0))
//         val engine = FlutterEngine(context.getApplicationContext())
//         val entrypoint: DartExecutor.DartEntrypoint = DartEntrypoint("lib/screens/s_home.dart", "serv")
//         engine.getDartExecutor().executeDartEntrypoint(entrypoint)
//         return MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//     }

}