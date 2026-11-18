# Building a Static Blog

A static blog can be fast without feeling too heavy. Markdown keeps writing simple, while Jekyll handles the page shell and the default theme.

## A simple content format

Every article lives in the `articles` folder and uses a hyphenated filename as its slug.

For example:

- `articles/welcome.md` becomes `article=welcome`
- `articles/building-a-static-blog.md` becomes `article=building-a-static-blog`

## API-like, not an API

The index behaves like a tiny data endpoint, and the article page behaves like a resource reader. Behind it is still just static HTML, JSON, and Markdown.

That makes the site inexpensive to host, straightforward to deploy, and easy to maintain.
