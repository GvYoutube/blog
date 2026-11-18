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

      Dir.glob(File.join(article_dir, "*.md")).each do |path|
        filename = File.basename(path)
        site.static_files << Jekyll::StaticFile.new(site, site.source, "articles", filename)
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
      date = normalize_date(date) if date

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

    def normalize_date(value)
      text = value.is_a?(Date) ? value.iso8601 : value.to_s.strip
      return value.iso8601 if value.is_a?(Date)
      return nil if text.empty?

      iso = text.match(/\A(\d{4})[-.](\d{1,2})[-.](\d{1,2})\z/)
      if iso
        year, middle, final = iso.captures.map(&:to_i)
        if middle <= 12
          date = Date.new(year, middle, final) rescue nil
          return date.iso8601 if date
        elsif middle <= 31 && final <= 12
          date = Date.new(year, final, middle) rescue nil
          return date.iso8601 if date
        end
      end

      slash = text.match(/\A(\d{1,2})\/(\d{1,2})\/(\d{2}|\d{4})\z/)
      if slash
        first, second, year = slash.captures
        year = year.to_i
        year += year >= 70 ? 1900 : 2000 if year < 100
        month, day = first.to_i, second.to_i
        month, day = day, month if month > 12 && day <= 12
        date = Date.new(year, month, day) rescue nil
        return date.iso8601 if date
      end

      separated = text.match(/\A(\d{1,2})[-.](\d{1,2})[-.](\d{4})\z/)
      if separated
        day, month, year = separated.captures.map(&:to_i)
        date = Date.new(year, month, day) rescue nil
        return date.iso8601 if date
      end

      text
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
