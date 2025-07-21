package com.example.age_calculator_smart // تأكد من أن هذا السطر يطابق اسم الحزمة لديك

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    // هذه الدالة تُستدعى بعد تهيئة محرك فلاتر
    // نستخدمها لتخصيص واجهة الأندرويد الأصلية
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // هذا السطر هو الأهم:
        // يجعل واجهة فلاتر تمتد خلف أشرطة النظام (الحالة والتنقل)
        // مما يسمح لنا بإنشاء تصميم يملأ الشاشة بالكامل
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
