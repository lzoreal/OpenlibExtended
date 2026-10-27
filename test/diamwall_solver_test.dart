import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/diamwall_solver.dart';

void main() {
  tearDown(DiamWallSolver.clearCookieCache);

  test('cookies are reused per host until cleared', () {
    expect(DiamWallSolver.cachedCookies('https://z-lib.gd/book/1'), isNull);

    DiamWallSolver.rememberCookies(
      'https://z-lib.gd/book/1',
      {'c_token': 'seed42', 'c_time': '0.120'},
    );

    final cached = DiamWallSolver.cachedCookies('https://z-lib.gd/s/foo');
    expect(cached?['c_token'], 'seed42');
    expect(DiamWallSolver.cachedCookies('https://other.example/'), isNull);

    DiamWallSolver.clearCookieCache();
    expect(DiamWallSolver.cachedCookies('https://z-lib.gd/book/1'), isNull);
  });
}
