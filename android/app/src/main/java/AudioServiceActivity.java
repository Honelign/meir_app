package mrblab.news_app;

import android.content.Context;
import mrblab.news_app.AudioServicePlugin;
import androidx.annotation.NonNull;
import com.fl.pip.FlPiPActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class AudioServiceActivity extends FlPiPActivity{
    @Override
    public FlutterEngine provideFlutterEngine(@NonNull Context context) {
        return AudioServicePlugin.getFlutterEngine(context);
    }
}