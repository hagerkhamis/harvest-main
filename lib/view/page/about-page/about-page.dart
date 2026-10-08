import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/aboutview-model.dart' show AboutViewModel;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../resources/styles.dart';
import '../../resources/styles_manager.dart';
import 'package:hatvest/view/page/connect-us/connect-us.dart';
import 'package:hatvest/view/page/branch/branch.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AboutViewModel>(context, listen: false).getAboutData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AboutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.aboutData == null) {
          return Scaffold(
            body: Center(child: Text("load_error".tr())),
          );
        }

        final about = viewModel.aboutData!;
        final filteredPages = about.pages.where((p) => 
          !p.titleAr.contains('سياسة الخصوصية') && 
          !p.titleAr.contains('سياسه الخصوصيه') && 
          !p.titleEn.toLowerCase().contains('privacy') &&
          !p.titleAr.contains('ملف الشركة') &&
          !p.titleAr.contains('ملف الشركه') &&
          !p.titleEn.toLowerCase().contains('company profile')
        ).toList();

        return DefaultTabController(
          length: filteredPages.length + 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "page_help".tr(),
                style: getBoldStyle(color: primaryColor, fontSize: AppSize.s20),
              ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: () {
                  List<Widget> t = [];
                  for (int i = 0; i < filteredPages.length; i++) {
                    final page = filteredPages[i];
                    final isAr = context.locale.languageCode == 'ar';
                    String title = isAr ? page.titleAr : page.titleEn;
                    t.add(Tab(text: title));
                  }
                  if (t.length >= 2) {
                    t.insert(2, Tab(text: "page_contact_us".tr()));
                    t.insert(3, Tab(text: "page_branches".tr()));
                  } else {
                    t.add(Tab(text: "page_contact_us".tr()));
                    t.add(Tab(text: "page_branches".tr()));
                  }
                  return t;
                }(),
              ),
            ),
            body: TabBarView(
              children: () {
                List<Widget> c = [];
                for (int i = 0; i < filteredPages.length; i++) {
                  final page = filteredPages[i];
                  final isAr = context.locale.languageCode == 'ar';
                  
                  String htmlData = isAr ? page.textAr : page.textEn;
                  if (page.titleAr.contains('الاسئلة الشائعة') || page.titleAr.contains('الأسئلة الشائعة')) {
                    htmlData = isAr ? _faqTextAr : _faqTextEn;
                  }

                  c.add(
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(
                            data: htmlData,
                          ),
                          const SizedBox(height: 24),
                          // أيقونات التواصل الاجتماعي (مرة واحدة فقط أسفل كل تاب)
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildSocialIcon(Icons.facebook, about.facebook),
                              _buildSocialIcon(Icons.camera_alt, about.instagram),
                              _buildSocialIcon(Icons.video_library, about.youtube),
                              _buildSocialIcon(Icons.linked_camera, about.linkedin),
                              _buildSocialIcon(Icons.tiktok, about.tiktok),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (c.length >= 2) {
                  c.insert(2, const ConnectUs(showAppBar: false));
                  c.insert(3, const BranchPage(showAppBar: false));
                } else {
                  c.add(const ConnectUs(showAppBar: false));
                  c.add(const BranchPage(showAppBar: false));
                }
                return c;
              }(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Icon(icon, color: primaryColor),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("open_link_failed".tr())),
      );
    }
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

  String get _faqTextAr => '''
<h3>ما هي طرق الحجز والدفع للدورات التدريبية في هارفست؟</h3>
<p>في هارفست، نوفر لك العديد من طرق دفع الدورات التدريبية والدبلومات لتختار الطريقة الأنسب لك وتبدأ رحلتك التعليمية بكل سهولة.</p>

<h4>✅ طرق الدفع المتاحة:</h4>
<ul>
<li>📌 الدفع نقداً عند زيارة أحد فروع هارفست.</li>
<li>📌 الدفع عبر فودافون كاش: 01030153018</li>
<li>📌 الدفع عبر فودافون كاش: 01050038465</li>
<li>📌 الدفع عبر اتصالات كاش: 01125504353</li>
<li>📌 التحويل البنكي على حساب CIB رقم: 100034779281</li>
<li>📌 التحصيل من المنزل (تطبق رسوم خدمة إضافية).</li>
<li>📌 الدفع الإلكتروني أونلاين من خلال الموقع الإلكتروني (Website).</li>
</ul>

<h4>💳 أنظمة التقسيط المتاحة للدورات والدبلومات:</h4>
<p>يمكنك تقسيط رسوم البرامج التدريبية من خلال:</p>
<ul>
<li>✓ Valu</li>
<li>✓ Aman</li>
<li>✓ Waseela</li>
<li>✓ Sympl</li>
<li>✓ Contact Now</li>
<li>✓ Tru</li>
<li>✓ Souhoola</li>
<li>✓ Seven</li>
<li>✓ Klivvr</li>
<li>✓ Khazna</li>
<li>✓ Forsa</li>
</ul>

<p>🌟 <strong>ابدأ الآن وسجّل في دبلومتك أو دورتك التدريبية المفضلة مع خيارات دفع متعددة وتقسيط ميسر يناسب جميع الاحتياجات.</strong><br>
هارفست – أفضل برامج التدريب والدبلومات المهنية مع أنظمة سداد مرنة ودفع إلكتروني آمن.</p>
''';

  String get _faqTextEn => '''
<h3>What are the booking and payment methods for training courses at Harvest?</h3>
<p>At Harvest, we provide you with various payment methods for training courses and diplomas so you can choose the most suitable way and start your educational journey with ease.</p>

<h4>✅ Available Payment Methods:</h4>
<ul>
<li>📌 Cash payment upon visiting one of Harvest's branches.</li>
<li>📌 Payment via Vodafone Cash: 01030153018</li>
<li>📌 Payment via Vodafone Cash: 01050038465</li>
<li>📌 Payment via Etisalat Cash: 01125504353</li>
<li>📌 Bank transfer to CIB account number: 100034779281</li>
<li>📌 Home collection (additional service fees apply).</li>
<li>📌 Online payment through the Website.</li>
</ul>

<h4>💳 Available Installment Systems for Courses and Diplomas:</h4>
<p>You can pay the training program fees in installments through:</p>
<ul>
<li>✓ Valu</li>
<li>✓ Aman</li>
<li>✓ Waseela</li>
<li>✓ Sympl</li>
<li>✓ Contact Now</li>
<li>✓ Tru</li>
<li>✓ Souhoola</li>
<li>✓ Seven</li>
<li>✓ Klivvr</li>
<li>✓ Khazna</li>
<li>✓ Forsa</li>
</ul>

<p>🌟 <strong>Start now and register for your favorite diploma or training course with multiple payment and easy installment options to suit all needs.</strong><br>
Harvest – The best training programs and professional diplomas with flexible payment systems and secure online payment.</p>
''';
}
