# frozen_string_literal: true

require 'fileutils'
require 'time'

module GenerateSitemap
  SITE_URL = 'https://developers.apunto.io'
  LASTMOD = Time.now.utc.strftime('%Y-%m-%d')

  # Slate renders a single HTML page; section anchors help crawlers discover structure.
  SECTION_PATHS = [
    '/',
    '/#introduccion',
    '/#autenticacion',
    '/#operaciones',
    '/#servicios',
    '/#contactos',
    '/#direcciones',
    '/#comentarios-messages',
    '/#tareas-to-dos',
    '/#errores'
  ].freeze

  def self.write!(build_dir)
    urls = SECTION_PATHS.map do |path|
      priority = path == '/' ? '1.0' : '0.8'
      loc = "#{SITE_URL}#{path}"
      <<~XML.strip
        <url>
          <loc>#{loc}</loc>
          <lastmod>#{LASTMOD}</lastmod>
          <changefreq>weekly</changefreq>
          <priority>#{priority}</priority>
        </url>
      XML
    end

    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      #{urls.join("\n")}
      </urlset>
    XML

    destination = File.join(build_dir, 'sitemap.xml')
    FileUtils.mkdir_p(build_dir)
    File.write(destination, xml)
  end
end
