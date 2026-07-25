# frozen_string_literal: true

# Concatenates Slate Markdown sources into a single file for LLM / tooling consumption.
module LlmsExport
  INCLUDE_ORDER = %w[
    authentication
    operations
    services
    attachments
    cancellation_reasons
    contacts
    addresses
    messages
    to_dos
    errors
  ].freeze

  module_function

  def write!(build_dir)
    root = File.expand_path('..', __dir__)
    includes_dir = File.join(root, 'source', 'includes')
    intro_path = File.join(root, 'source', 'index.html.md')

    intro = File.read(intro_path).sub(/\A---\s*.*?\s*---\n/m, '')
    sections = INCLUDE_ORDER.map do |name|
      path = File.join(includes_dir, "_#{name}.md")
      File.read(path) if File.exist?(path)
    end.compact

    full_body = ([intro] + sections).join("\n\n---\n\n")
    full_header = <<~HEADER
      # Apunto REST API v1 — full reference (Markdown)

      Base URL: https://control.apunto.io/api/v1
      Auth: Authorization: Bearer <token>
      Format: JSON

      This file is generated from source/includes/*.md on each production build.

    HEADER

    File.write(File.join(build_dir, 'llms-full.txt'), full_header + full_body)

    index = <<~INDEX
      # Apunto API — LLM index

      Official human-readable docs: https://developers.apunto.io/
      Machine-readable Markdown export: https://developers.apunto.io/llms-full.txt

      ## Source layout (repo apunto-api-docs)

      - source/index.html.md — introduction, pagination, versioning
      - source/includes/_*.md — resource sections (operations, services, …)

      ## Quick facts

      - Base URL: https://control.apunto.io/api/v1
      - Auth: Bearer token (API token or POST /api/v1/auth)
      - Pagination: page, per_page (default 25, max 100)

      Regenerate llms-full.txt: bundle exec middleman build --clean
    INDEX

    File.write(File.join(build_dir, 'llms.txt'), index)
  end
end
