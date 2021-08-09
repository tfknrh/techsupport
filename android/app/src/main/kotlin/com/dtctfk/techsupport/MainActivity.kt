package com.dtctfk.techsupport


import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.util.Timer
import kotlin.concurrent.schedule

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dtctfk.techsupport/channel" // Unique Channel

  
 var methodResult: MethodChannel.Result? = null

   override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
             super.configureFlutterEngine(flutterEngine)
          //    startService(Intent(applicationContext, MyService::class.java))
        //   val localBroadcastManager: LocalBroadcastManager 
        //   = LocalBroadcastManager(this, IntentFilter(CHANNEL))
       
 val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
// Timer("SettingUp", false).schedule(500) { 
//     channel.invokeMethod("callBack", "data1")
// }
 channel.setMethodCallHandler { call, result ->
            methodResult = result
         if (call.method.equals("execLogcat")) {
                readLogs()
                if (strLog != null) {
                    result.success(strLog)
                } else {
                    result.error("UNAVAILABLE", "logs not available.", null)
                }
            } else if (call.method.equals("runBackground")) {
               startService(Intent(applicationContext, MyService::class.java))
            } else if (call.method.equals("moveTaskToBack")) {
              moveTaskToBack(true)
            } else {
                result.notImplemented()
            }
    //    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
    //         // Note: this method is invoked on the main thread.
    //         call, result ->
            
   } 
   }
// context = flutterEngine.getApplicationContext()
//         val localBroadcastManager: LocalBroadcastManager = LocalBroadcastManager.getInstance(context)
//         localBroadcastManager.registerReceiver(this, IntentFilter(CHANNEL))
//         channel = MethodChannel(flutterEngine.getBinaryMessenger(), CHANNEL, JSONMethodCodec.INSTANCE)
//         channel.setMethodCallHandler(this)
//    }
//    fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
       
//     }
// fun onReceive(context: Context?, intent: Intent) {
//         if (intent.getAction() == null) return
//         if (intent.getAction().equalsIgnoreCase(CHANNEL)) {
//             val data: String = intent.getStringExtra("data")
//             try {
//                 val jData = JSONObject(data)
//                 if (channel != null) {
//                     channel.invokeMethod("onReceiveData", jData)
//                 }
//             } catch (e: JSONException) {
//                 e.printStackTrace()
//             } catch (e: Exception) {
//                 e.printStackTrace()
//             }
//         }
//     }


    var strLog: String? = null

    
    private fun readLogs() {
        try {
            val process = Runtime.getRuntime().exec("logcat -d")
            val bufferedReader = BufferedReader(
                    InputStreamReader(process.inputStream)
            )
            val log = StringBuilder()
            var line: String? = ""
            while (bufferedReader.readLine().also { line = it } != null) {
                log.append(line)
            }
           strLog = log.toString()
        } catch (e: IOException) {
            strLog = e.toString()
        }
    }
     
}
