import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CloudflareEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitCloudflare extends CloudflareEvent {}

class UploadFile extends CloudflareEvent {
  final String fileName;
  final File fileContent;
  final String contentType;
  final String token;

  UploadFile({required this.fileName, required this.fileContent, required this.contentType, required this.token});
}