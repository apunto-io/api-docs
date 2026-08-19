# AGENTS.md

## Cursor Cloud specific instructions

This repository is the **Apunto API documentation** site, built with **Slate** on top of
**Middleman** (Ruby static-site generator). There is a single service: the Middleman
documentation site. There is no backend/database.

### Runtime / toolchain
- Ruby **3.2** (matches the `Deploy` GitHub Actions workflow) with **Bundler 2.2.22**
  (the version pinned in `Gemfile.lock` under `BUNDLED WITH`). These are already installed
  in the environment snapshot; the startup update script only runs `bundle install`.
- Gems build native extensions (`nokogiri`, `sassc`, `ffi`), so the base image needs
  `build-essential` and the `*-dev` headers. These are already present in the snapshot — do
  not add them to the update script.

### Run / build / lint
- Dev server (primary way to work on the docs): `bundle exec middleman server`
  (or `./start-docs.sh` / `./slate.sh serve`). Serves at http://localhost:4567.
- Static build (also the closest thing to a lint/CI check — CI just runs the build):
  `bundle exec middleman build --clean`. Output goes to `build/` (git-ignored).
- There is no separate test suite; `.github/workflows/build.yml` validates the project
  purely by running `bundle exec middleman build`.

### Non-obvious gotchas
- Content lives in `source/index.html.md` plus partials in `source/includes/_*.md`. A new
  partial only renders if it is added to the `includes:` list in the front-matter of
  `source/index.html.md`.
- The build has a post-build hook (`lib/llms_export.rb`) that emits `build/llms.txt` and
  `build/llms-full.txt`; deprecation warnings about `DidYouMean` and Ruby Sass EOL are
  expected noise and do not indicate failure.
- The deploy scripts (`deploy.sh`, `slate.sh deploy`, `*.sh` DNS helpers) publish to the
  `gh-pages` branch / GitHub Pages. Do not run them during normal development.
