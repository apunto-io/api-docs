# frozen_string_literal: true

require 'nokogiri'

# Sidebar data for the docs layout.
#
# Every h1 is a section and every h2 below it an entry. An h2 takes the HTTP
# method of the first endpoint block (<div class="endpoint" data-method="GET">)
# that follows it, so the sidebar can show a method pill.
#
# Sections are grouped by the `navigation` list in the page frontmatter:
#
#   navigation:
#     - title: Primeros pasos
#       sections: [introduccion, guia-rapida]
#
# A section that no group names is listed at the end under "Más", so a new
# include never disappears from the sidebar.
#
# @param page_content [String] rendered HTML of the page
# @param groups [Array<Hash>, nil] frontmatter navigation
# @return [Array<Hash>] [{title:, sections: [{id:, title:, children: [{id:, title:, method:}]}]}]
def nav_data(page_content, groups)
  sections = nav_sections(page_content)
  by_id = sections.to_h { |section| [section[:id], section] }
  used = []

  grouped = Array(groups).map do |group|
    group = group.to_h.transform_keys(&:to_s)
    ids = Array(group['sections']).map(&:to_s)
    used.concat(ids)
    {title: group['title'].to_s, sections: ids.map { |id| by_id[id] }.compact}
  end

  rest = sections.reject { |section| used.include?(section[:id]) }
  grouped << {title: 'Más', sections: rest} if rest.any?
  grouped.reject { |group| group[:sections].empty? }
end

# @param page_content [String]
# @return [Array<Hash>]
def nav_sections(page_content)
  doc = Nokogiri::HTML::DocumentFragment.parse(page_content)
  sections = []
  pending = nil

  doc.css('h1, h2, div.endpoint').each do |node|
    case node.name
    when 'h1'
      sections << {id: node['id'].to_s, title: node.text.strip, children: []}
      pending = nil
    when 'h2'
      next if sections.empty?

      pending = {id: node['id'].to_s, title: node.text.strip, method: nil}
      sections.last[:children] << pending
    else
      next if pending.nil? || pending[:method]

      pending[:method] = node['data-method'].to_s.upcase.presence
    end
  end

  sections
end
