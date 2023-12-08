import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mtrl;
import 'package:introduction_screen/introduction_screen.dart';
import 'package:news_app/blocs/sign_in_bloc.dart';
import 'package:news_app/config/config.dart';
import 'package:news_app/pages/home.dart';
import 'package:news_app/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  
  void afterIntroComplete (){
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    sb.setSignIn();
    nextScreenReplace(context, HomePage());
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: mtrl.TextDirection.rtl,
      child: IntroductionScreen(
        pages: [
          introPage(context, 'intro-title1', 'intro-description1', Config().introImageNew)
        ],
        onDone: () {
          afterIntroComplete();
        },
        onSkip: () {
          afterIntroComplete();
        },
        globalBackgroundColor: Colors.white,
        showSkipButton: true,
        skip: const Text('skip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)).tr(),
        next: const Icon(Icons.navigate_next),
        done: const Text("done", style: TextStyle(fontWeight: FontWeight.w600)).tr(),

        dotsDecorator: DotsDecorator(
            size: const Size.square(7.0),
            activeSize: const Size(20.0, 5.0),
            activeColor: Theme.of(context).primaryColor,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0))),
      ),
    );
  }
}




PageViewModel introPage (context, String title, String subtitle, String image){
  return PageViewModel(

      titleWidget: Column(

        children: <Widget>[
          Text("ברוכים הבאים בשם ה'",
          textAlign: TextAlign.center,
          style:  TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            wordSpacing: 1,
            color: Colors.black),
          ).tr(),
          SizedBox(height: 8,),
          Container(
            height: 3,
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10)
            ),
          )
        ],
      ),

      body: 'זיכנו הקב"ה ישתבח שמו לפתוח אפליקציה שיהיה הצוהר והפתח שיוכלו ישראל להיכנס לתיבת נח הנזכרת, לתפוס מחסה ממבול הטומאה והבלבול שבחוץ, ובבית המדרש הזה ניתן לצפות בשיעורים בהלכה באגדה במוסר ובפרשיות השבוע ועוד, וילוו אותך בלכתך בדרך בשכבך ובקומך, כי אין לתורה שמירת זכויות וכל המפיץ הרי זה משובח, ויטול שכרו כפול מהשמים.',
      image: Image(
        width: double.maxFinite,
        image: AssetImage(Config().introImageNew),
        fit: BoxFit.fitWidth,
      ),

      decoration: const PageDecoration(
        pageColor: Colors.white,
        bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        bodyPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 50),
        titlePadding: EdgeInsets.only(bottom: 10),
        //descriptionPadding: EdgeInsets.only(left: 30, right: 30),
        //imagePadding: EdgeInsets.all(30),
        imageFlex: 2,

      ),
    );

}


