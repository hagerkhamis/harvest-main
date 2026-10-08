import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_theme.dart';


class ExamsAppBar extends StatelessWidget {
  const ExamsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppTheme.bottomBgColor,
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width*.05,
          right: MediaQuery.of(context).size.width*.05,
          top: 25,bottom: 5
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: ()=>Navigator.pop(context),
              child: Icon(Icons.arrow_back,color: AppTheme.btnColor,)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/harvest_logo.png",width: MediaQuery.of(context).size.width*.2,),
              Text("Welcome To Harvest",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "auth_fonts",color: Colors.white,fontSize: 18),),
              SizedBox(width: MediaQuery.of(context).size.width*.05,)
            ],
          ),
          Icon(Icons.menu,color: AppTheme.bottomBgColor,),
        ],
      ),
    );
  }
}
