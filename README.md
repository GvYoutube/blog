# GvYoutube Blog

A small Jekyll blog using the default Minima theme. The article index and reader are intentionally lightweight and static.

## Add an article

1. Create `articles/my-article.md`.
2. Start the file with a level-one Markdown heading: `# My Article`.
3. Write the article normally. The article list automatically uses the H1 as its title and the first plain-text paragraph as its preview.

The slug must contain lowercase letters, numbers, and hyphens only.
An optional date can be provided in YAML front matter:

```yaml
---
date: 2026-11-18
---
```

## Preview locally

```sh
bundle install
bundle exec jekyll serve
```

Open `http://localhost:4000` and select an article.
