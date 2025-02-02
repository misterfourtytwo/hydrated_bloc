import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {}

class MockStorage extends Mock implements HydratedBlocStorage {}

void main() {
  MockStorage storage;
  HydratedBlocDelegate delegate;
  MockBloc bloc;

  setUp(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    String response = '.';

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return response;
    });

    storage = MockStorage();
    delegate = HydratedBlocDelegate(storage);
    bloc = MockBloc();
  });

  tearDown(() {
    if (File('./.hydrated_bloc.json').existsSync()) {
      File('./.hydrated_bloc.json').deleteSync();
    }
  });

  group('HydratedBlocDelegate', () {
    test(
        'should call storage.write when onTransition is called using the static build',
        () async {
      delegate = await HydratedBlocDelegate.build();
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
    });

    test('should call storage.write when onTransition is called', () {
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      verify(storage.write('MockBloc', json.encode(expected))).called(1);
    });
  });
}
