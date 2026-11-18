# GvYoutube Blog

A small Jekyll blog using the default Minima theme. The article index and reader are intentionally lightweight and static.

## Add an article

1. Create `articles/my-article.md`.
2. Start the file with a level-one Markdown heading.
3. Add an entry to `articles/index.json`:

```json
{
  "slug": "my-article",
  "title": "My Article",
  "date": "2026-11-18",
  "description": "A short summary."
}
```

The slug must contain lowercase letters, numbers, and hyphens only.

## Preview locally

```sh
bundle install
bundle exec jekyll serve
```

Open `http://localhost:4000` and select an article.
