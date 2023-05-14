class Success<T> extends DataResult<T> {
  final T data;

  Success(this.data);
}

class Failure<T> extends DataResult<T> {
  final Exception exception;

  Failure(this.exception);
}

class Loading<T> extends DataResult<T> {
  final T? data;

  Loading(this.data);
}

abstract class DataResult<T> {
  static Success<T> success<T>(T data) => Success<T>(data);

  static Failure<T> error<T>(Exception message) => Failure<T>(message);

  static Loading<T> loading<T>([T? data = null]) => Loading<T>(data);

  bool get isLoading => this is Loading<T>;

  bool get isError => this is Failure<T>;

  bool get isSuccess => this is Success<T>;

  T? get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else if (this is Loading<T>) {
      return (this as Loading<T>).data;
    } else {
      return null;
    }
  }
}
