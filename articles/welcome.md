# Welcome to the Blog

This is a quiet corner for notes, experiments, and things worth remembering.

## How it works

- The article list reads a JSON index.
- Each link carries a filename-derived slug.
- The reader fetches Markdown from the `articles` folder.

There is no application server here. It is a Jekyll site with a small client-side layer for article loading.

```text
article.html?article=welcome
```
