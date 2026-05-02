/// Centralised route names + paths used by `go_router`.
///
/// Always reference routes via `AppRoute.<x>.name` and `.path`, never hard
/// code strings — that way refactors propagate automatically.
enum AppRoute {
  splash(name: 'splash', path: '/'),
  signIn(name: 'sign-in', path: '/sign-in'),
  signUp(name: 'sign-up', path: '/sign-up'),
  home(name: 'home', path: '/home'),
  settings(name: 'settings', path: '/settings')
  ;

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
