# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).


## Unreleased
### Changed
- Connection worker processes are no longer spawned under a supervisor. This
  also fixes the issue of one connection terminating also terminating other
  connections.
- Implementing `Crow.Plugin.Name/0` is now mandatory.

### Fixed
- Application configuration is now pulled via the `:crow` application key (in
  `Application.get_env` calls) instead of `Crow`, preventing a compiler warning.

### Removed
- The `Crow.Helpers` plugin.


## v0.1.1 - 2019-04-06
### Fixed
- Adjust output of initial banner to be what `munin-update` expects.
- Ignore arguments to `list` and `cap` for now.


## v0.1.0 - 2019-04-06
### Added
- Initial release with a basic munin node implementation.



<!-- vim: set textwidth=80 sw=2 ts=2: -->
