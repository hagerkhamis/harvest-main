// // To parse this JSON data, do
// //
// //     final adultPtModel = adultPtModelFromJson(jsonString);

// import 'dart:convert';

// AdultPtModel adultPtModelFromJson(String str) => AdultPtModel.fromJson(json.decode(str));

// String adultPtModelToJson(AdultPtModel data) => json.encode(data.toJson());

// class AdultPtModel {
//     List<Grammer> vocab;
//     List<Grammer> grammer;
//     List<Reading> reading;
//     List<Listening> listening;
//     List<Writing> writing;
//     int applicationId;
//     int remainDuration;
//     String message;

//     AdultPtModel({
//         required this.vocab,
//         required this.grammer,
//         required this.reading,
//         required this.listening,
//         required this.writing,
//         required this.applicationId,
//         required this.remainDuration,
//         required this.message,
//     });

//     factory AdultPtModel.fromJson(Map<String, dynamic> json) => AdultPtModel(
//         vocab: List<Grammer>.from(json["Vocab"].map((x) => Grammer.fromJson(x))),
//         grammer: List<Grammer>.from(json["Grammer"].map((x) => Grammer.fromJson(x))),
//         reading: List<Reading>.from(json["Reading"].map((x) => Reading.fromJson(x))),
//         listening: List<Listening>.from(json["Listening"].map((x) => Listening.fromJson(x))),
//         writing: List<Writing>.from(json["Writing"].map((x) => Writing.fromJson(x))),
//         applicationId: json["applicationId"],
//         remainDuration: json["RemainDuration"],
//         message: json["message"],
//     );

//     Map<String, dynamic> toJson() => {
//         "Vocab": List<dynamic>.from(vocab.map((x) => x.toJson())),
//         "Grammer": List<dynamic>.from(grammer.map((x) => x.toJson())),
//         "Reading": List<dynamic>.from(reading.map((x) => x.toJson())),
//         "Listening": List<dynamic>.from(listening.map((x) => x.toJson())),
//         "Writing": List<dynamic>.from(writing.map((x) => x.toJson())),
//         "applicationId": applicationId,
//         "RemainDuration": remainDuration,
//         "message": message,
//     };
// }

// class Grammer {
//     String id;
//     Skill skill;
//     Photo photo;
//     String questionText;
//     List<Answer> answers;

//     Grammer({
//         required this.id,
//         required this.skill,
//         required this.photo,
//         required this.questionText,
//         required this.answers,
//     });

//     factory Grammer.fromJson(Map<String, dynamic> json) => Grammer(
//         id: json["id"],
//         skill: skillValues.map[json["skill"]]!,
//         photo: photoValues.map[json["photo"]]!,
//         questionText: json["question_text"],
//         answers: List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "skill": skillValues.reverse[skill],
//         "photo": photoValues.reverse[photo],
//         "question_text": questionText,
//         "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
//     };
// }

// class Answer {
//     int id;
//     String answer;

//     Answer({
//         required this.id,
//         required this.answer,
//     });

//     factory Answer.fromJson(Map<String, dynamic> json) => Answer(
//         id: json["id"],
//         answer: json["answer"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "answer": answer,
//     };
// }

// enum Photo {
//     EMPTY,
//     THE_68_XX_CM_MXL_KQC_IP1_E_JKM2_J_WNGQ_W_MR_CEN_BS5_C92_C5_B_JPG,
//     USC_CRPQY_BZ_XK_QS8_HG_C_YPS_F3_G5_BE2_I_DR_YB2_L_TTG3_N_PNG,
//     V_VG_Z4_YOLSDWW_JXNZM7_EM_WH_HL0_FHR_N9_KJNV_F5_RY9_W_PNG,
//     WIGX_V558_QK_YZCW_DM_VB_GD_OZ_DQZFJ_US_C_QB48_R_ALCEH_PNG
// }

// final photoValues = EnumValues({
//     "": Photo.EMPTY,
//     "68XxCmMxlKqcIp1eJKM2jWngqWMrCENBs5c92C5b.jpg": Photo.THE_68_XX_CM_MXL_KQC_IP1_E_JKM2_J_WNGQ_W_MR_CEN_BS5_C92_C5_B_JPG,
//     "uscCrpqyBzXkQs8HgCYpsF3G5be2iDRYb2lTTG3N.png": Photo.USC_CRPQY_BZ_XK_QS8_HG_C_YPS_F3_G5_BE2_I_DR_YB2_L_TTG3_N_PNG,
//     "vVgZ4yolsdwwJxnzm7EmWHHl0fhrN9KjnvF5Ry9w.png": Photo.V_VG_Z4_YOLSDWW_JXNZM7_EM_WH_HL0_FHR_N9_KJNV_F5_RY9_W_PNG,
//     "WigxV558QkYzcwDmVbGDOzDqzfjUsCQb48RAlceh.png": Photo.WIGX_V558_QK_YZCW_DM_VB_GD_OZ_DQZFJ_US_C_QB48_R_ALCEH_PNG
// });

// enum Skill {
//     GRAMMAR,
//     LISTENING,
//     READING,
//     VOCABULARY
// }

// final skillValues = EnumValues({
//     "Grammar": Skill.GRAMMAR,
//     "Listening": Skill.LISTENING,
//     "Reading": Skill.READING,
//     "Vocabulary": Skill.VOCABULARY
// });

// class Listening {
//     String questionId;
//     String text;
//     String record;
//     Skill skill;
//     List<Grammer> questions;

//     Listening({
//         required this.questionId,
//         required this.text,
//         required this.record,
//         required this.skill,
//         required this.questions,
//     });

//     factory Listening.fromJson(Map<String, dynamic> json) => Listening(
//         questionId: json["question_id"],
//         text: json["text"],
//         record: json["record"],
//         skill: skillValues.map[json["skill"]]!,
//         questions: List<Grammer>.from(json["questions"].map((x) => Grammer.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "question_id": questionId,
//         "text": text,
//         "record": record,
//         "skill": skillValues.reverse[skill],
//         "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
//     };
// }

// class Reading {
//     String id;
//     Skill skill;
//     String photo;
//     String paragraph;
//     List<Grammer> questions;

//     Reading({
//         required this.id,
//         required this.skill,
//         required this.photo,
//         required this.paragraph,
//         required this.questions,
//     });

//     factory Reading.fromJson(Map<String, dynamic> json) => Reading(
//         id: json["id"],
//         skill: skillValues.map[json["skill"]]!,
//         photo: json["photo"],
//         paragraph: json["paragraph"],
//         questions: List<Grammer>.from(json["questions"].map((x) => Grammer.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "skill": skillValues.reverse[skill],
//         "photo": photo,
//         "paragraph": paragraph,
//         "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
//     };
// }

// class Writing {
//     String questionId;
//     String text;
//     String photo;
//     List<dynamic> questions;

//     Writing({
//         required this.questionId,
//         required this.text,
//         required this.photo,
//         required this.questions,
//     });

//     factory Writing.fromJson(Map<String, dynamic> json) => Writing(
//         questionId: json["question_id"],
//         text: json["text"],
//         photo: json["photo"],
//         questions: List<dynamic>.from(json["questions"].map((x) => x)),
//     );

//     Map<String, dynamic> toJson() => {
//         "question_id": questionId,
//         "text": text,
//         "photo": photo,
//         "questions": List<dynamic>.from(questions.map((x) => x)),
//     };
// }

// class EnumValues<T> {
//     Map<String, T> map;
//     late Map<T, String> reverseMap;

//     EnumValues(this.map);

//     Map<T, String> get reverse {
//             reverseMap = map.map((k, v) => MapEntry(v, k));
//             return reverseMap;
//     }
// }
