# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).


## Unreleased

### Added

- Plugins can now accept configuration options. **Note this requires each
  plugin, even if not using options, to accept an additional argument in
  `c:name/1`, `c:config/1` and `c:values/1`**.

- Added the `Crow.Plugin.options` type.

- Added the `Crow.Config` module that helps with finding plugins.

## Changed

- Every plugin is now passed options in all of its functions. This can be used
  to, for example, configure the same ETS table plugin that monitors different
  ETS tables for different apps at the same time. See `crow_plugins` for more
  information.



## v0.1.4 - 2023-10-04
### Changed
- Only log peer connection in the worker, skip logging the acceptor part.
### Removed
- Support for Elixir < 1.12


## v0.1.3 - 2021-06-20
### Changed
- Log connection of peers at `DEBUG` log level.


## v0.1.2 - 2019-05-16
### Changed
- Connection worker processes are no longer spawned under a supervisor. This
  also fixes the issue of one connection terminating also terminating other
  connections.
- Implementing `Crow.Plugin.name/0` is now mandatory.

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
