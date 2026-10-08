import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/flutter_html.dart' as html_style;
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart' as app_fonts;
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/aboutview-model.dart';
import 'package:provider/provider.dart';

class GetHelpPage extends StatefulWidget {
  const GetHelpPage({Key? key}) : super(key: key);

  @override
  State<GetHelpPage> createState() => _GetHelpPageState();
}

class _GetHelpPageState extends State<GetHelpPage>
    with TickerProviderStateMixin {
  String? _lastLang;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AboutViewModel>(context, listen: false).getHelpData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = context.locale.languageCode;
    if (_lastLang != null && _lastLang != currentLang) {
      Provider.of<AboutViewModel>(context, listen: false).getHelpData();
    }
    _lastLang = currentLang;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "about_app".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: app_fonts.FontSize.s20),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AboutViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (viewModel.data == null || viewModel.data!.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('failed_load_data'.tr(),
                      style: getMediumStyle(color: Colors.grey, fontSize: app_fonts.FontSize.s16)),
                ],
              ),
            );
          }

          final data = viewModel.data!;
          final isAr = context.locale.languageCode == 'ar';

          final tabCount = data.items.length + 1;
          if (_tabController.length != tabCount) {
            _tabController.dispose();
            _tabController =
                TabController(length: tabCount, vsync: this);
          }

          return Column(
            children: [
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: getBoldStyle(color: Colors.white, fontSize: app_fonts.FontSize.s14),
                  unselectedLabelStyle:
                      getMediumStyle(color: Colors.grey, fontSize: app_fonts.FontSize.s14),
                  tabs: () {
                    List<Widget> t = [];
                    for (int i = 0; i < data.items.length; i++) {
                      final item = data.items[i];
                      String title = isAr ? item.titleAr : item.titleEn;
                      if (i == 1) {
                        title = isAr ? "هدف التطبيق" : "Our Goal";
                      } else if (i == 2) {
                        title = isAr ? "ملف الشركة" : "Company Profile";
                      }
                      t.add(Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(title),
                        ),
                      ));
                    }
                    t.add(Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(isAr ? "مميزات التطبيق" : "App Features"),
                      ),
                    ));
                    return t;
                  }(),
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: () {
                    List<Widget> c = [];
                    final tabCount = data.items.length + 1;
                    for (int i = 0; i < tabCount; i++) {
                      String content = "";
                      String imageUrl = "";
                      
                      if (i < data.items.length) {
                        final item = data.items[i];
                        imageUrl = item.image;
                        content = isAr ? item.textAr : item.textEn;
                        if (isAr) {
                          if (i == 0 || item.titleAr.contains('من نحن')) {
                            content = _aboutUsTextAr;
                          } else if (i == 1) {
                            content = _appGoalTextAr;
                          } else if (i == 2) {
                            content = _companyProfileTextAr;
                          }
                        } else {
                          if (i == 1) {
                            content = _appGoalTextEn;
                          } else if (i == 2) {
                            content = _companyProfileTextEn;
                          }
                        }
                      } else {
                        content = isAr ? _appFeaturesTextAr : _appFeaturesTextEn;
                      }

                      c.add(SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          if (imageUrl.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  "https://sys.harvestcollege.co.uk/uploads/\$imageUrl",
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(),
                                ),
                              ),
                            ),

                          // Content Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Html(
                              data: content,
                              style: {
                                "*": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                  fontSize: html_style.FontSize(16),
                                  color: context.textPrimary,
                                ),
                                "body": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                  fontSize: html_style.FontSize(16),
                                  lineHeight: LineHeight(1.9),
                                  color: context.textPrimary,
                                  textAlign: TextAlign.right,
                                ),
                                "p": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                  fontSize: html_style.FontSize(16),
                                  lineHeight: LineHeight(1.9),
                                  margin: Margins.only(bottom: 12),
                                  color: context.textPrimary,
                                ),
                                "span": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                  fontSize: html_style.FontSize(16),
                                  color: context.textPrimary,
                                ),
                                "li": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                  fontSize: html_style.FontSize(16),
                                  lineHeight: LineHeight(1.9),
                                  color: context.textPrimary,
                                  margin: Margins.only(bottom: 8),
                                ),
                                "strong": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: html_style.FontSize(16),
                                  color: primaryColor,
                                ),
                                "u": Style(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: html_style.FontSize(16),
                                  color: primaryColor,
                                  textDecoration: TextDecoration.underline,
                                ),
                                "ul": Style(
                                  margin: Margins.only(right: 8),
                                  padding: HtmlPaddings.zero,
                                ),
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
                    }
                    return c;
                  }(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String get _aboutUsTextAr => '''
<p><strong>نبذة عن هارفست بريتيش كوليدج | أفضل مركز لتدريب اللغة الإنجليزية في مصر</strong><br>
تُعد <strong>هارفست بريتيش كوليدج</strong> واحدة من أبرز مراكز تدريب <strong>اللغة الإنجليزية في مصر</strong>، حيث تقدم برامج ودورات تدريبية احترافية معتمدة تساعد المتدربين على تطوير مهاراتهم والوصول إلى الطلاقة بثقة.</p>
<p>🎓 توفر هارفست <strong>دورات اللغة الإنجليزية والهولندية والدبلومات المتخصصة والتدريب الأونلاين</strong> وفق مناهج دولية معتمدة، مما يجعلها وجهة مميزة للباحثين عن تعلم الإنجليزية والهولندية في مصر والخليج والشرق الأوسط.</p>
<p>🌍 على مدار أكثر من 15 عاماً من الخبرة، نجحت هارفست في تدريب أكثر من <strong>600,000 متدرب</strong> من مختلف الأعمار والمستويات، وساعدتهم على تحسين مهارات التحدث والاستماع والقراءة والكتابة، بالإضافة إلى دعم المؤسسات في تطوير مهارات التواصل الفعّال.</p>
<p>🏆 هارفست جهة تدريب معتمدة ومسجلة، ومعتمدة <strong>من مؤسسة كامبريدج البريطانية</strong> مما يعزز من قوة الشهادات وفرصها في سوق العمل.</p>
<p>📚 تعتمد برامج هارفست على منهج تدريبي متدرج يبدأ من المبتدئين وحتى المستويات المتقدمة، مع دبلومات متخصصة لتأهيل المتدربين لسوق العمل واختبارات مثل TOEFL وIELTS، بطريقة عملية تعتمد على التطبيق والممارسة وليس الحفظ فقط.</p>
<p>💻 تقدم هارفست خدماتها من خلال فروع متعددة داخل القاهرة والجيزة، بالإضافة إلى نظام <strong>التدريب الأونلاين (Online Learning)</strong> الذي يتيح للمتدربين في مصر ودول الخليج والشرق الأوسط التعلم بسهولة ومرونة.</p>
<p>🎯 وخلال السنوات الأخيرة، واصلت هارفست توسعها وتطوير برامجها لتشمل لغات إضافية مثل الألمانية والإسبانية والهولندية، إلى جانب دورات ICDL، مما يعزز من فرص المتدربين في سوق العمل المحلي والدولي.</p>
<p>🏅 واليوم تفخر هارفست بتخريج أكثر من <strong>100,000 خريج حاصلين على شهادات معتمدة من كامبريدج</strong>، مع استمرارها في تقديم تجربة تدريبية متكاملة تجمع بين الجودة، المرونة، والاعتماد الدولي.</p>
''';

  String get _appGoalTextAr => '''
<p><strong>مهمتنا</strong><br>
تلتزم هارفست بتقديم برامج تدريب اللغة الإنجليزية عالية الجودة من خلال منظومة تدريب شاملة ومتكاملة. ونهدف إلى إعداد جيل من المتحدثين باللغة الإنجليزية يمتلكون مهارات قوية في التواصل، الصوتيات (Phonetics)، لغة الأعمال، والترجمة.</p>
<p>كما نركز على مفهوم التدريب من أجل التوظيف، وتنمية مهارات الإبداع والإنتاج، بما يساهم في تمكين الأفراد والمؤسسات، وتعزيز مكانة هارفست كشركة مصرية رائدة في مجال تدريب اللغة الإنجليزية محلياً وإقليمياً، من خلال ثقة واعتماد العملاء من الأفراد والشركات.</p>
<p><strong>رؤيتنا</strong><br>
نطمح لأن نكون واحدة من المؤسسات التعليمية الرائدة عالمياً في مجال تعليم وتدريب اللغة الإنجليزية، والمعروفة بالتميز والابتكار في تطوير المهارات اللغوية مدى الحياة.</p>
<p>نهدف إلى تمكين المتدربين من تحقيق أهدافهم المهنية والشخصية، وخدمة مجتمعاتهم بكفاءة أعلى. ويقود هذا التوجه فريق عمل محترف ومدربون معتمدون، يقدمون برامج تدريبية حديثة، تفاعلية، وممتعة، تركز على تطوير المهارات اللغوية الأساسية بأعلى جودة ممكنة.</p>
<p><strong>قيمنا</strong><br>
نؤمن أن النزاهة، الشجاعة، التمكين، الاحترام والأمانة هم قيمنا، وليسوا بالشيء الجديد، هم فقط يوضحوا ما يحدث بالفعل في هارفست منذ البداية.</p>
''';

  String get _appGoalTextEn => '''
<p><strong>Our Mission</strong><br>
Harvest is committed to providing high-quality English language training programs through a comprehensive and integrated training system. We aim to prepare a generation of English speakers with strong skills in communication, phonetics, business language, and translation.</p>
<p>We also focus on the concept of training for employment, and developing creativity and production skills, contributing to the empowerment of individuals and institutions, and strengthening Harvest's position as a leading Egyptian company in the field of English language training locally and regionally, through the trust and accreditation of individual and corporate clients.</p>
<p><strong>Our Vision</strong><br>
We aspire to be one of the leading educational institutions globally in the field of English language teaching and training, known for excellence and innovation in lifelong language skills development.</p>
<p>We aim to empower trainees to achieve their professional and personal goals, and serve their communities more efficiently. This approach is led by a professional team and certified trainers, who provide modern, interactive, and enjoyable training programs, focusing on developing essential language skills with the highest possible quality.</p>
<p><strong>Our Values</strong><br>
We believe that Integrity, Courage, Empowerment, Respect, and Honesty are our values, and they are not something new, they just explain what actually happens at Harvest since the beginning.</p>
''';

  String get _companyProfileTextAr => '''
<p>تلتزم هارفست بريتيش كوليدج بتقديم برامج تدريب اللغة الإنجليزية بمعايير جودة عالية، تهدف إلى تطوير مهارات المتدربين في التواصل واللغة الإنجليزية وفق مناهج حديثة معتمدة، بما يساهم في إعداد كوادر قادرة على المنافسة في سوق العمل وتحقيق أهدافها التعليمية والمهنية.</p>
<p>📄 <strong>للاطلاع على ملف الشركة الكامل:</strong></p>
''';

  String get _companyProfileTextEn => '''
<p>Harvest British College is committed to providing English language training programs with high quality standards, aimed at developing trainees' communication and English language skills according to modern accredited curricula, which contributes to preparing cadres capable of competing in the labor market and achieving their educational and professional goals.</p>
<p>📄 <strong>To view the full company profile:</strong></p>
''';

  String get _appFeaturesTextAr => '''
<p>يُوفر تطبيق هارفست تجربة تدريب رقمية متكاملة تساعد المتدربين على متابعة تقدمهم في دوراتهم التدريبية بكل سهولة ومرونة.</p>
<p>✨ <strong>أهم المميزات:</strong></p>
<ul>
<li>📚 متابعة البرامج التدريبية والدورات بسهولة من أي مكان وفي أي وقت.</li>
<li>🏫👦 الوصول إلى المحتوى التدريبي والمحاضرات بشكل منظم وسهل الاستخدام.</li>
<li>📊 متابعة مستوى التقدم والتقييمات واختبارات تحديد المستوى.</li>
<li>📝 إجراء اختبارات كتابية وشفهية أونلاين بكل سهولة.</li>
<li>📄 الحصول على تقارير الأداء وتحديد نقاط القوة والضعف.</li>
<li>🔔 تنبيهات وإشعارات بالمواعيد والمحاضرات والتحديثات المهمة.</li>
<li>📅 حجز الدورات التدريبية والدبلومات بسهولة مباشرة من التطبيق.</li>
<li>💳 إدارة الاشتراكات وتجديدها ومتابعة خطط الدفع.</li>
<li>🎁 الاطلاع على أحدث العروض والخصومات المتاحة بشكل مستمر.</li>
<li>💳 إمكانية الدفع الإلكتروني ومتابعة الاشتراكات.</li>
<li>🎯 تجربة استخدام سهلة تدعم جميع مستويات المتدربين.</li>
</ul>
<p>🌟 <strong>تطبيق هارفست صُمم ليكون وسيلتك الذكية لمتابعة رحلتك التدريبية وتحقيق أفضل النتائج بسهولة ومرونة.</strong></p>
''';

  String get _appFeaturesTextEn => '''
<p>The Harvest app provides an integrated digital training experience that helps trainees track their progress in their training courses with ease and flexibility.</p>
<p>✨ <strong>Key Features:</strong></p>
<ul>
<li>📚 Easily follow training programs and courses from anywhere, at any time.</li>
<li>🏫👦 Access training content and lectures in an organized and user-friendly way.</li>
<li>📊 Track progress, assessments, and placement tests.</li>
<li>📝 Easily take written and oral exams online.</li>
<li>📄 Get performance reports and identify strengths and weaknesses.</li>
<li>🔔 Alerts and notifications for appointments, lectures, and important updates.</li>
<li>📅 Easily book training courses and diplomas directly from the app.</li>
<li>💳 Manage and renew subscriptions and track payment plans.</li>
<li>🎁 View the latest offers and discounts continuously.</li>
<li>💳 Online payment capability and subscription tracking.</li>
<li>🎯 An easy user experience that supports all trainee levels.</li>
</ul>
<p>🌟 <strong>The Harvest app is designed to be your smart tool to track your training journey and achieve the best results with ease and flexibility.</strong></p>
''';
}
