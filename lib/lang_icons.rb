# Small hand-authored SVG marks for the language switcher, ClickUp-reference
# style (icon-first card, no colored-square abbreviation badge). Kept as
# inline SVG (no external icon font/sprite) so the existing GitHub Pages
# static build needs zero new asset pipeline wiring.
#
# All marks share the same 24x24 viewBox and are drawn (or transformed) to
# stay inside an ~18x18 inner box (roughly x/y 3..21). Keeping that inset
# consistent across every icon — instead of some glyphs touching the edges
# and others floating in a chunk of dead space — is what actually makes the
# row read as a matched set instead of "randomly sized and placed" icons.
def lang_icon_svg(key)
  case key.to_s
  when 'shell'
    # Terminal prompt glyph — no background box, so its visual weight
    # matches the free-floating gem/snake/badge marks instead of looking
    # like it's the only one wearing a frame.
    <<~SVG
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <polyline points="7 8 12 12 7 16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
        <line x1="13" y1="16" x2="18" y2="16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
      </svg>
    SVG
  when 'ruby'
    # Simple symmetric gem/kite silhouette instead of the lopsided
    # "house"-shaped pentagon — reads as a gem at a glance.
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 3 18 9 12 21 6 9Z" fill="#CC342D"/>
        <path d="M6 9h12" stroke="#8f241d" stroke-width="0.8" opacity="0.6"/>
        <path d="M9 9 12 21M15 9 12 21" stroke="#8f241d" stroke-width="0.6" opacity="0.45"/>
      </svg>
    SVG
  when 'python'
    # Same two-tone snake mark, just rescaled/recentered into the shared
    # inner box instead of nearly filling the full 24x24 viewBox.
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <g transform="translate(2.4 2.4) scale(0.8)">
          <path d="M12 2c-1.7 0-3.05.27-4.1.75C6.7 3.3 6.1 4.3 6.1 5.7v1.9H12v.7H3.9C2.5 8.9 1.6 10.4 1.6 12.6c0 2.1.85 3.55 2.3 4.2 1.15.55 2.35.65 3.4.65h1.4v-2.2c0-1.5 1.25-2.75 2.75-2.75h4c1.25 0 2.35-1 2.35-2.35V5.7c0-1.4-.6-2.4-1.8-2.95C14.9 2.27 13.6 2 12 2Z" fill="#3776AB"/>
          <path d="M12 22c1.7 0 3.05-.27 4.1-.75 1.2-.55 1.8-1.55 1.8-2.95v-1.9H12v-.7h8.1c1.4 0 2.3-1.5 2.3-3.7 0-2.1-.85-3.55-2.3-4.2-1.15-.55-2.35-.65-3.4-.65h-1.4v2.2c0 1.5-1.25 2.75-2.75 2.75h-4c-1.25 0-2.35 1-2.35 2.35v4.05c0 1.4.6 2.4 1.8 2.95C9.1 21.73 10.4 22 11 22h1z" fill="#FFD43B"/>
          <circle cx="8.3" cy="5.1" r="0.9" fill="#fff"/>
          <circle cx="15.7" cy="18.9" r="0.9" fill="#2b2b2b"/>
        </g>
      </svg>
    SVG
  when 'javascript'
    # Same inset as everything else (was previously nearly edge-to-edge,
    # which made it look bigger than the other three).
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <rect x="3" y="3" width="18" height="18" rx="4" fill="#F7DF1E"/>
        <text x="12" y="15.7" text-anchor="middle" font-family="'Helvetica Neue', Arial, sans-serif" font-size="8.5" font-weight="700" fill="#1a1a1a">JS</text>
      </svg>
    SVG
  when 'node'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 3 19 7.4v9.2L12 21 5 16.6V7.4L12 3Z" fill="#3C873A"/>
        <text x="12" y="15.5" text-anchor="middle" font-family="'Helvetica Neue', Arial, sans-serif" font-size="6.5" font-weight="700" fill="#fff">JS</text>
      </svg>
    SVG
  when 'php'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <ellipse cx="12" cy="12" rx="9" ry="6" fill="none" stroke="#8892BF" stroke-width="1.5"/>
        <text x="12" y="14.2" text-anchor="middle" font-family="Georgia, 'Times New Roman', serif" font-style="italic" font-size="7.5" font-weight="700" fill="#8892BF">php</text>
      </svg>
    SVG
  else
    <<~SVG
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 6 4 12l5 6M15 6l5 6-5 6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    SVG
  end
end
