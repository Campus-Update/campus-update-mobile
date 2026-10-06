// The login and register calls carry a password up and tokens back, so what
// the console prints is worth a test: a leak there is silent and permanent.
import 'package:campus_update/core/network/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a password never reaches the log', () {
    final out =
        LoggingInterceptor.redact({'email': 'a@b.com', 'password': 'hunter2'})
            as Map;
    expect(out['email'], 'a@b.com');
    expect(out['password'], '<redacted>');
  });

  test('tokens never reach the log', () {
    final out =
        LoggingInterceptor.redact({
              'userId': 'u1',
              'accessToken': 'eyJhbGci',
              'refreshToken': 'jtFMXQ',
              'expiresAt': '2026-10-01T12:30:11Z',
            })
            as Map;
    expect(out['userId'], 'u1');
    expect(out['expiresAt'], isNotNull);
    expect(out['accessToken'], '<redacted>');
    expect(out['refreshToken'], '<redacted>');
  });

  test('secrets nested inside a response are caught too', () {
    final out =
        LoggingInterceptor.redact({
              'data': {
                'session': {'accessToken': 'x'},
                'users': [
                  {'name': 'Ada', 'password': 'p'},
                ],
              },
            })
            as Map;
    final data = out['data'] as Map;
    expect((data['session'] as Map)['accessToken'], '<redacted>');
    expect(((data['users'] as List).first as Map)['password'], '<redacted>');
    expect(((data['users'] as List).first as Map)['name'], 'Ada');
  });

  test('ordinary values pass through untouched', () {
    expect(LoggingInterceptor.redact('plain'), 'plain');
    expect(LoggingInterceptor.redact(42), 42);
    expect(LoggingInterceptor.redact(null), isNull);
  });
}
