import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
class GlobalFunction{
  static launchUrl(String url_) async {
    //https://api.whatsapp.com/send?phone=
    //https://wa.me/$number/?text=
    var url = url_;
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
  static  Route route(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  static  Route routeBottom(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  static  Route routeBottomLeft(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  static setData(key,value,type,valu) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setString(key, value);
    prefs.setString(type, valu);
  }
  static SuccessThenRetunHome(BuildContext context,String Message) {
    Timer(Duration(seconds: 2), (){
      Navigator.pushNamedAndRemoveUntil(context, "/HomePage", (route) => false);
    });
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child:  Container(
            width: MediaQuery.of(context).size.width*.4,
            height: 160,
            decoration: BoxDecoration(color: Color(0xff258C29),
                borderRadius: BorderRadius.all(Radius.circular(0)),
                border: Border.all(color: Color(0xffffC82d),width: 2.0)
            )
            ,padding: EdgeInsets.only(
            top:  MediaQuery.of(context).size.height*0.01,
            bottom: MediaQuery.of(context).size.height*0.01,
            left: MediaQuery.of(context).size.width*0.05,
            right: MediaQuery.of(context).size.width*0.05,
          ),

            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,color: Color(0xffffC82d),size: 60,),
                Text(Message,style: TextStyle(color:Colors.white),)
              ],
            ),

          ),
        ));
  }
  static   SuccessThenPop(BuildContext context,String Message) {
    Timer(Duration(seconds: 2), (){
      Navigator.pop(context);
    });
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child:  Container(
            width: MediaQuery.of(context).size.width*.4,
            height: 160,
            decoration: BoxDecoration(color: Color(0xff258C29),
                borderRadius: BorderRadius.all(Radius.circular(0)),
                border: Border.all(color: Color(0xffffC82d),width: 2.0)
            )
            ,padding: EdgeInsets.only(
            top:  MediaQuery.of(context).size.height*0.01,
            bottom: MediaQuery.of(context).size.height*0.01,
            left: MediaQuery.of(context).size.width*0.05,
            right: MediaQuery.of(context).size.width*0.05,
          ),

            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,color: Color(0xffffC82d),size: 60,),
                Text(Message,style: TextStyle(color:Colors.white),)
              ],
            ),

          ),
        ));
  }

  static   logout(BuildContext context) async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, "/HomePage", (route) => false);
  }
  static SucessDialog(BuildContext context,String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child:  Container(
            padding: EdgeInsets.only(
                left: 10,
                right: 10
            ),
            height: 150.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                border: Border.all(color: Colors.black12,width: 2.0),
                color: Colors.white
            ),
            child: Stack(children: <Widget>[
              Column(
                //mainAxisAlignment: MainAxisAlignment.center
                // ,crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(alignment: Alignment.center,child: Column(
                    children: [
                      SizedBox(height: 5,),
                      Container(

                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                  color: Colors.white
                              ),
                              // padding:EdgeInsets.all(2),
                              child: Icon(Icons.clear,color: Colors.white,size: 14,),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 13),
                              child: Icon(Icons.check_circle_outline,size: 50,color: Color(0xffF5941D),),
                            ),

                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                                    color: Color(0xffF5941D)
                                ),
                                padding:EdgeInsets.all(2.5),
                                child: Icon(Icons.clear,color: Colors.white,size: 20,),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10,),
                      Text(message,style: TextStyle(color: Color(0xffF5941D),fontSize: 14,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                      // Text("${title}",textAlign: TextAlign.center,)
                    ],
                  )),
                ],
              ),


            ],),
          ),
        ));
  }
  static Widget loadingImg(BuildContext context){
    return Image.asset("Assets/Images/loading.gif",
    height:MediaQuery.of(context).size.height*.15,
    );
  }
  static Widget EmptyPage(BuildContext context,String text){
    return Container(
      height: MediaQuery.of(context).size.height*.5,
      child: Center(
        child: Column(
          children: [
            Image.asset("Assets/Images/logo.png",
            height: MediaQuery.of(context).size.height*.25,
            ),
            SizedBox(height: 15,),
            Container(
                width: MediaQuery.of(context).size.width*.8,
                child: Text(text))
          ],
        ),
      ),
    );
  }
 static phoneCall(String number) async {
    var url = 'tel:$number';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  static whatsAppMessage(String number) async {
    //https://api.whatsapp.com/send?phone=
    //https://wa.me/$number/?text=
    var url = "https://api.whatsapp.com/send?phone=$number";
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
}
