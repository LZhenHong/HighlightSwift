# Third-Party Notices

HighlightSwift contains:

- First-party Swift source, tests, examples, and repository-level project files licensed under the MIT license in [LICENSE](LICENSE).
- Vendored third-party assets under `Sources/HighlightSwift/Resources/`, which retain their upstream notices and are not relicensed under the repository MIT license.

Bundled copies of the main third-party license texts ship with the package in `Sources/HighlightSwift/Resources/ThirdPartyLicenses/` so downstream source and binary redistributors have a stable place to point to when surfacing acknowledgements.

## Bundled Third-Party Components

### 1. `highlight.js` core, grammars, and project styles

Files:

- `Sources/HighlightSwift/Resources/highlight.min.js`
- `Sources/HighlightSwift/Resources/languages/*.min.js`
- `Sources/HighlightSwift/Resources/styles/*.css`
- `Sources/HighlightSwift/Resources/styles/*.min.css`

License:

- BSD-3-Clause, unless an individual file header states a different upstream license.

Upstream:

- <https://github.com/highlightjs/highlight.js>

Bundled license text:

- `Sources/HighlightSwift/Resources/ThirdPartyLicenses/BSD-3-Clause-highlight.js.txt`

Notes:

- Files such as `default.css`, `1c-light.css`, and `tokyo-night-*.css` explicitly say `License: see project LICENSE`; in this repository that project-level upstream license is the bundled BSD-3-Clause notice above.
- Some theme files under `Resources/styles/` carry their own licenses in file headers. Those exceptions are listed below and keep those original notices.

### 2. `highlightjs/base16-highlightjs` theme pack

Files:

- `Sources/HighlightSwift/Resources/styles/base16/*.css`
- `Sources/HighlightSwift/Resources/styles/base16/*.min.css`

License:

- The generated files keep their original per-file headers, including author attribution and the note `License: ~ MIT (or more permissive) [via base16-schemes-source]`.
- The upstream `base16-highlightjs` repository itself is MIT licensed.

Upstream:

- <https://github.com/highlightjs/base16-highlightjs>

Bundled license text:

- `Sources/HighlightSwift/Resources/ThirdPartyLicenses/MIT-base16-highlightjs.txt`

Notes:

- This repository preserves the upstream per-file attribution headers and does not replace or narrow those notices.

### 3. Nord highlight.js theme

Files:

- `Sources/HighlightSwift/Resources/styles/nord.css`

License:

- MIT

Upstream:

- <https://github.com/arcticicestudio/nord-highlightjs>

Bundled license text:

- `Sources/HighlightSwift/Resources/ThirdPartyLicenses/MIT-Nord-highlightjs.txt`

### 4. Stack Overflow / Stacks themes

Files:

- `Sources/HighlightSwift/Resources/styles/stackoverflow-dark.css`
- `Sources/HighlightSwift/Resources/styles/stackoverflow-dark.min.css`
- `Sources/HighlightSwift/Resources/styles/stackoverflow-light.css`
- `Sources/HighlightSwift/Resources/styles/stackoverflow-light.min.css`

License:

- MIT

Upstream:

- <https://github.com/StackExchange/Stacks>

Bundled license text:

- `Sources/HighlightSwift/Resources/ThirdPartyLicenses/MIT-StackExchange-Stacks.txt`

### 5. Night Owl theme

Files:

- `Sources/HighlightSwift/Resources/styles/night-owl.css`

License:

- MIT

Notes:

- The upstream file already includes its full MIT permission notice in the retained file header, including attribution to Carl Baxter and Sarah Drasner.

### 6. CC BY-SA themes

Files:

- `Sources/HighlightSwift/Resources/styles/kimbie-dark.css`
- `Sources/HighlightSwift/Resources/styles/kimbie-light.css`
- `Sources/HighlightSwift/Resources/styles/nnfx-dark.css`
- `Sources/HighlightSwift/Resources/styles/nnfx-dark.min.css`
- `Sources/HighlightSwift/Resources/styles/nnfx-light.css`
- `Sources/HighlightSwift/Resources/styles/nnfx-light.min.css`

License:

- Creative Commons Attribution-ShareAlike 4.0, as indicated by the retained upstream file headers.

Bundled license text:

- `Sources/HighlightSwift/Resources/ThirdPartyLicenses/CC-BY-SA-4.0.txt`

Notes:

- The `kimbie-*` headers use the wording `Creative Commons Attribution-ShareAlike 4.0 Unported License`.
- The `nnfx-*` headers point to the CC BY-SA 4.0 URL directly.
- Those upstream headers are preserved verbatim in the vendored files.

## Redistribution Guidance

If you redistribute HighlightSwift in source or binary form, do not present the entire package as MIT-only. Preserve the vendored file headers and include the bundled notices from `Sources/HighlightSwift/Resources/ThirdPartyLicenses/`, or provide equivalent acknowledgements in your product's third-party notices page.
