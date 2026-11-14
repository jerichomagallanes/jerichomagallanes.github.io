# Trainr site

Served at https://jerichomagallanes.github.io/Trainr/ from this folder, so the
address the apps and both store listings link to never depends on a repository
name. Plain files: this repository has `.nojekyll`.

- `index.html` is the landing page; edit it directly.
- `privacy-policy.html` and `terms-of-use.html` are rendered from the markdown
  in `src/`. Edit the markdown, then re-render the body with
  `npx --yes marked --gfm -i src/<name>.md -o /tmp/body.html` and paste it
  between `<main>` and `</main>`; the head, header and footer are the same on
  both pages. Bump the "Last updated" date in the markdown.
- `assets/` holds the self-hosted fonts (OFL files beside them), the store
  badges, the screenshots and the link-preview image.
