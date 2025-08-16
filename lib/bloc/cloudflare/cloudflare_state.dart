abstract class CloudflareState {}

class CloudFlareInitial extends CloudflareState {}

class CloudFlareLoading extends CloudflareState {}

class CloudFlareLoaded extends CloudflareState {
  final String fileName;
  CloudFlareLoaded({required this.fileName});
}

class CloudFlareError extends CloudflareState {
  final String message;

  CloudFlareError({required this.message});
}
