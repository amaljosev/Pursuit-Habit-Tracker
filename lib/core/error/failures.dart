class Failure {
  final String message;
  const Failure({this.message = 'Something went wrong'});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}
