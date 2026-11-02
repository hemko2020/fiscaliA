abstract class FiscalAgent<TInput, TOutput> {
  const FiscalAgent();

  String get id;
  String get nom;
  String get description;

  Future<TOutput> execute(TInput input);
}
