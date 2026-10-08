import 'package:flutter/material.dart';
import 'package:hatvest/services/app-service.dart';

class Inquiry {
  final String id;
  final String reqistration;
  final String branchName;
  final String branchPhone;
  final String inquire;
  final String overdue;

  Inquiry({
    required this.id,
    required this.reqistration,
    required this.branchName,
    required this.branchPhone,
    required this.inquire,
    required this.overdue,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'],
      reqistration: json['reqistration'],
      branchName: json['branch_name'],
      branchPhone: json['branch_phone'],
      inquire: json['Inquire'],
      overdue: json['overdue'],
    );
  }
}

class LabelType {
  final int id;
  final String name;

  LabelType({required this.id, required this.name});

  factory LabelType.fromJson(Map<String, dynamic> json) {
    return LabelType(id: json['id'], name: json['name']);
  }
}
