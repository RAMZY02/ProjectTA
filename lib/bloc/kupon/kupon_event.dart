abstract class KuponEvent{}

class Initial extends KuponEvent {}

class FetchKupon extends KuponEvent{
  final String token;
  final int userId;

  FetchKupon({required this.token, required this.userId});
}