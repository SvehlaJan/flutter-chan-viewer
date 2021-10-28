import 'dart:async';

import 'package:flutter_chan_viewer/data/remote/resource.dart';

class NetworkBoundResources<ResultType, RequestType> {
  late StreamController<Resource<ResultType>> _result;

  Future<Resource<ResultType?>> asFuture({
    required FutureOr<ResultType> Function() loadFromDb,
    required bool shouldFetch(ResultType data),
    required FutureOr<RequestType> Function() createCall,
    ResultType processResponse(RequestType result)?,
    required FutureOr saveCallResult(RequestType item),
  }) {
    assert(
      RequestType == ResultType || (!(RequestType == ResultType) && processResponse != null),
      "You need to specify the `processResponse` when the types are different",
    );
    processResponse ??= (value) => value as ResultType;
    return Resource.asFuture<ResultType?>(() async {
      final value = await loadFromDb();
      return shouldFetch(value)
          ? await (_fetchFromNetwork(createCall as Future<RequestType> Function(),
              saveCallResult as Future<dynamic> Function(RequestType), value) as FutureOr<ResultType?>)
          : value;
    }) as Future<Resource<ResultType?>>;
  }

  Stream<Resource<ResultType>> asStream({
    required Stream<ResultType> Function() loadFromDb,
    required bool shouldFetch(ResultType data),
    required FutureOr<RequestType> Function() createCall,
    ResultType processResponse(RequestType result)?,
    required FutureOr saveCallResult(RequestType item),
  }) {
    assert(
      RequestType == ResultType || (!(RequestType == ResultType) && processResponse != null),
      "You need to specify the `processResponse` when the types are different",
    );
    processResponse ??= (value) => value as ResultType;

    late StreamSubscription localListener;

    _result = StreamController<Resource<ResultType>>(
      onCancel: () {
        if (!_result.hasListener) {
          _result.close();
          localListener.cancel();
        }
      },
    );

    final localStream = loadFromDb().transform(
      StreamTransformer<ResultType, Resource<ResultType>>.fromHandlers(
        handleData: (event, sink) async {
          if (shouldFetch(event)) {
            print("Fetch data and call loading");
            sink.add(Resource.loading(data: event));
            try {
              var result = await _fetchFromNetwork(createCall as Future<RequestType> Function(),
                  saveCallResult as Future<dynamic> Function(RequestType), event);
              print("Fetching success");
              sink.add(Resource.success(data: processResponse!(result)));
            } on Exception catch (e) {
              print("Fetching failed");
              sink.addError(Resource.failed(data: null, error: e));
            }
          } else {
            print("Fetching data its not necessary");
            sink.add(Resource.success(data: event));
          }
        },
      ),
    );

    _result.sink.add(Resource.loading());

    print("Call loading...");

    localListener = localStream.listen(_result.sink.add);

    return _result.stream;
  }

  Future<RequestType> _fetchFromNetwork(Future<RequestType> Function() createCall,
      Future Function(RequestType item) saveCallResult, ResultType unconfirmedResult) async {
    saveCallResult(unconfirmedResult as RequestType);
    return await createCall().then((value) async {
      if (value != unconfirmedResult) {
        await saveCallResult(value);
      }
      return value;
    });
  }
}
