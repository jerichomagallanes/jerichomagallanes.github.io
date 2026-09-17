# jerichomagallanes.github.io

The developer site at the root of the domain. It is named after the developer,
not after any one app, and every app I publish lives underneath it.

## What lives where

| URL | Served from | Contents |
| --- | --- | --- |
| `/` | this repo | the developer index: one card per app |
| `/app-ads.txt` | this repo | the AdMob authorised-seller record |
| `/assets/` | this repo | each app's logo for its card |
| `/Trainr/` | the `Trainr` repo, `/docs` | Trainr's page, privacy policy, terms |

## Why this repo has to exist

Two reasons, both permanent:

- **`app-ads.txt` is per publisher, not per app.** The single line in it
  authorises `pub-3543227308769883` to sell inventory in *every* app published
  under that AdMob account. A second app needs no second file.
- **GitHub Pages serves a domain root only from a repository named
  `<username>.github.io`.** A project site always sits under a path, and
  Google strips the path and fetches `<domain>/app-ads.txt`, so the file cannot
  live in an app's own repository.

## Adding a new app

1. In the new app's repository, turn on Pages for `/docs` on the default
   branch. It publishes at `/<RepoName>/` with no work here.
2. Drop its logo in `assets/`.
3. Copy the `<a class="app">` block in `index.html`, point it at
   `<RepoName>/`, and give it the new app's accent colour.

Nothing else changes: the domain, the `app-ads.txt` record and the AdMob
publisher ID stay exactly as they are.
