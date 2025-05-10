/// A sealed class representing a value of one of two possible types (a disjoint union).
/// Instances of `Either` are either an instance of `Left` or `Right`.
///
/// The `Either` type is often used as an alternative to `Option` for dealing with possible missing values.
/// In this usage, `Left` is used for failure and `Right` is used for success.
///
/// Example usage:
/// ```dart
/// Either<String, int> divide(int a, int b) {
///   if (b == 0) {
///     return Left("Cannot divide by zero");
///   } else {
///     return Right(a ~/ b);
///   }
/// }
///
/// void main() {
///   final result = divide(4, 2);
///
///   result.fold(
///     (left) => print("Error: $left"),
///     (right) => print("Result: $right"),
///   );
/// }
/// ```
///
/// The `fold` method allows you to apply a function based on whether the value is `Left` or `Right`.
///
/// Example usage of `fold`:
/// ```dart
/// final either = Right<String, int>(42);
///
/// final result = either.fold(
///   (left) => "Error: $left",
///   (right) => "Success: $right",
/// );
///
/// print(result); // Output: Success: 42
/// ```
abstract class Either<L, R> {
  const Either();

  /// Apply a function based on whether the value is `Left` or `Right`
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnL(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnR(value);
}
