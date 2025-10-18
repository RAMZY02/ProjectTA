import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class CloudflareEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitCloudflare extends CloudflareEvent {}

class UploadFile extends CloudflareEvent {
  final String fileName;
  final File? fileContent;
  final Uint8List? fileWeb;
  final String contentType;
  final String token;

  UploadFile({required this.fileName, this.fileContent, this.fileWeb, required this.contentType, required this.token});
}