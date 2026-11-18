require "json"
require "yaml"
require "date"

module GvYoutube
  class ArticleIndexGenerator < Jekyll::Generator
    priority :high

    def generate(site)
      article_dir = File.join(site.source, "articles")
      entries = Dir.glob(File.join(article_dir, "*.md")).sort.reverse.filter_map do |path|
        build_entry(path, site)
      end

      page = Jekyll::Page.new(site, site.source, "articles", "index.json")
      page.data["layout"] = nil
      page.content = JSON.pretty_generate(entries)
      site.pages << page
    end

    private

    def build_entry(path, site)
      source = File.read(path, encoding: "utf-8")
      metadata = read_front_matter(source)
      body = source.sub(/\A---\s*\n.*?\n---\s*\n/m, "")

      h1 = body.match(/^#\s+(.+?)\s*$/)
      title = h1 ? clean_inline(h1[1]) : metadata["title"] || File.basename(path, ".md")
      slug = File.basename(path, ".md")
      return unless slug.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)

      preview = body
        .sub(/^#\s+.+?\s*$/, "")
        .lines
        .map(&:strip)
        .find { |line| !line.empty? && !line.start_with?("#", "```", ">", "-", "*", "[") }

      preview = preview ? clean_inline(preview) : ""
      preview = preview.length > 220 ? "#{preview[0, 217].rstrip}..." : preview
      date = metadata["date"] || filename_date(slug)

      {
        "slug" => slug,
        "title" => title,
        "date" => date ? date.to_s : nil,
        "description" => preview
      }
    end

    def read_front_matter(source)
      match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
      return {} unless match

      YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: false) || {}
    rescue Psych::Exception
      {}
    end

    def filename_date(slug)
      match = slug.match(/\A(\d{4}-\d{2}-\d{2})/)
      match && match[1]
    end

    def clean_inline(value)
      value
        .gsub(/!\[([^\]]*)\]\([^)]*\)/, '\1')
        .gsub(/\[([^\]]+)\]\([^)]*\)/, '\1')
        .gsub(/[*_`]/, "")
        .gsub(/<[^>]+>/, "")
        .strip
    end
  end
end
