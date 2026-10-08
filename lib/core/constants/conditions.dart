import 'package:flutter/material.dart';
import 'package:hatvest/core/constants/exams_app_bar.dart';

class Conditions extends StatefulWidget {
  const Conditions({super.key});

  @override
  State<Conditions> createState() => _ConditionsState();
}

class _ConditionsState extends State<Conditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            ExamsAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width*.05,
                    right: MediaQuery.of(context).size.width*.05
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15,),
                      Text("الشروط والاحكام",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      SizedBox(height: 15,),
                       Image.asset("assets/images/conditions.jpg",width: MediaQuery.of(context).size.width,fit: BoxFit.cover,height: MediaQuery.of(context).size.height*.7,)
              /*        Text("تعليمــات و بنـــود اقـــرار المتــدرب بهارفســـــت"),
                      Text("النظــــام"),
                      Text("لا يسمح بإستخدام الهاتف المحمول او تناول الأطعمة والمشروبات أثناء المحاضرة التدريبية."),
                      Text("لا يسمح للمتدرب بالحضور بنسخة مصورة من المواد العلمية لهارفست مثل الكتب والإسطوانات."),
                      Text("لا يسمح بالتحدث باللغة العربية قط أثناء المحاضرة وذلك لتحقيق فكرة مجتمع التواصل بالإنجليزية فقط."),
                      Text("امتحــــان تحــديـد المستــــوى والمـدفـوعـــات"),
                      Text("يلتـزم المتدرب بإجــراء امتحـان تحـديد المستـوى بمجـرد ملء استمــارة الحجــز بحـد أقصـي 3  أيـام عمـل."),
                      Text("يلتـزم المتدرب بسداد كافة المصروفات والرســوم المستحقــة في موعـد أقصــاه أسبـوع قبل بدء الدبلومة التدريبية، و في حالة الدفعــات، يســدد المتدرب الأقســاط المستحقة في الميعاد والتاريخ المحدد من قبل الإدارة. و في حالة الإخلال، يحق للإدارة عدم السمـاح للمتدرب بالحضور حتي ســداد واستحقـاق كامل المدفوعات."),
                      Text("يتـم تحـديد موعد بـدء التدريب أثنـاء الحجــز أو خلال15  يــوم عمـل بحد أقصي بعد إجراء امتحـان تحديد المستوى وسداد الرســوم"),
                      Text("السلــوكيــات والأخـلاقيــــات"),
                      Text("يلتـزم المتدرب بإتباع آداب الـحـوار وقواعد اللبـاقة والذوق وحسـن المعـاملة اثناء التعامل مع الزملاء والزميلات المتدربين والمحاضرين وموظفي خدمة العملاء بالإدارة والعامليـن بالشركة وكافة القائميـن علي الشئــون التدريبية والإداريـة بالشـركـة."),
                      Text("يلتـزم المتدرب بحسن السيـر والسلـوك داخل الشركـة وعـدم إثــارة أي ضـوضـاء أو شغـب. وخلاف ذلك، يحق للإدارة فصل المتدرب من البرنامج التدريبي للدبلومة"),
*/
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
