# frozen_string_literal: true

require 'yaml'

# Concatenates the Markdown sources into one file for LLMs and tooling.
# The section order is the `includes` list of source/index.html.md, so a new
# section is exported without touching this file.
module LlmsExport
  module_function

  def write!(build_dir)
    root = File.expand_path('..', __dir__)
    index_source = File.read(File.join(root, 'source', 'index.html.md'))
    frontmatter = index_source[/\A---\s*\n(.*?)\n---\s*\n/m, 1].to_s
    includes = Array(YAML.safe_load(frontmatter)['includes'])
    intro = index_source.sub(/\A---\s*.*?\s*---\n/m, '')

    sections = includes.map do |name|
      path = File.join(root, 'source', 'includes', "_#{name}.md")
      strip_html(File.read(path)) if File.exist?(path)
    end.compact

    header = <<~HEADER
      # Apunto REST API v1 — referencia completa (Markdown)

      Base URL: https://control.apunto.io/api/v1
      Auth: Authorization: Bearer <token>
      Formato: JSON

      Generado desde source/includes/*.md en cada build de producción.

    HEADER
    File.write(File.join(build_dir, 'llms-full.txt'), header + ([intro] + sections).join("\n\n---\n\n"))

    File.write(File.join(build_dir, 'llms.txt'), <<~INDEX)
      # Apunto API — índice para LLMs

      Documentación: https://developers.apunto.io/
      Referencia completa en Markdown: https://developers.apunto.io/llms-full.txt

      - Base URL: https://control.apunto.io/api/v1
      - Auth: Bearer token (Configuración → Tokens de API, o POST /api/v1/auth)
      - Paginación: page, per_page (25 por omisión, máximo 100)
      - Sincronización: updated_since / deleted_since (ISO 8601)
      - Errores: JSON con error, message, errors y request_id
    INDEX
  end

  # Endpoint blocks and cards are HTML in the Markdown; keep their text.
  def strip_html(markdown)
    markdown
      .gsub(%r{<div class="endpoint" data-method="(\w+)">.*?<code[^>]*>(.*?)</code>.*?</div>}m) { "`#{Regexp.last_match(1)} #{Regexp.last_match(2)}`" }
      .gsub(/<[^>]+>/, '')
  end
end
