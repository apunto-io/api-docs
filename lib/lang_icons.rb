# Small hand-authored SVG marks for the language switcher, ClickUp-reference
# style (icon-first card, no colored-square abbreviation badge). Kept as
# inline SVG (no external icon font/sprite) so the existing GitHub Pages
# static build needs zero new asset pipeline wiring.
def lang_icon_svg(key)
  case key.to_s
  when 'shell'
    # Terminal prompt glyph — reads clearly for cURL/shell examples.
    <<~SVG
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect x="1.5" y="1.5" width="21" height="21" rx="5" stroke="currentColor" stroke-width="1.4" opacity="0.35"/>
        <polyline points="6.5 8.5 11 12 6.5 15.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <line x1="12.5" y1="15.5" x2="17.5" y2="15.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
      </svg>
    SVG
  when 'ruby'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2.2 4.3 8.1 7 21.6h10L19.7 8.1 12 2.2Z" fill="#CC342D"/>
        <path d="M4.3 8.1 12 2.2l7.7 5.9-7.7 2.5-7.7-2.5Z" fill="#E0524A" opacity="0.9"/>
        <path d="M7 21.6 12 12l5 9.6H7Z" fill="#9B1B14" opacity="0.55"/>
        <path d="M4.3 8.1 12 12l-5 9.6-2.7-13.5Z" fill="#B3271F" opacity="0.55"/>
        <path d="M19.7 8.1 12 12l5 9.6 2.7-13.5Z" fill="#B3271F" opacity="0.4"/>
      </svg>
    SVG
  when 'python'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2c-1.7 0-3.05.27-4.1.75C6.7 3.3 6.1 4.3 6.1 5.7v1.9H12v.7H3.9C2.5 8.9 1.6 10.4 1.6 12.6c0 2.1.85 3.55 2.3 4.2 1.15.55 2.35.65 3.4.65h1.4v-2.2c0-1.5 1.25-2.75 2.75-2.75h4c1.25 0 2.35-1 2.35-2.35V5.7c0-1.4-.6-2.4-1.8-2.95C14.9 2.27 13.6 2 12 2Z" fill="#3776AB"/>
        <path d="M12 22c1.7 0 3.05-.27 4.1-.75 1.2-.55 1.8-1.55 1.8-2.95v-1.9H12v-.7h8.1c1.4 0 2.3-1.5 2.3-3.7 0-2.1-.85-3.55-2.3-4.2-1.15-.55-2.35-.65-3.4-.65h-1.4v2.2c0 1.5-1.25 2.75-2.75 2.75h-4c-1.25 0-2.35 1-2.35 2.35v4.05c0 1.4.6 2.4 1.8 2.95C9.1 21.73 10.4 22 12 22Z" fill="#FFD43B"/>
        <circle cx="8.3" cy="5.1" r="0.85" fill="#fff"/>
        <circle cx="15.7" cy="18.9" r="0.85" fill="#2b2b2b"/>
      </svg>
    SVG
  when 'javascript'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <rect x="1.5" y="1.5" width="21" height="21" rx="4.5" fill="#F7DF1E"/>
        <text x="12" y="16.5" text-anchor="middle" font-family="'Helvetica Neue', Arial, sans-serif" font-size="9.5" font-weight="700" fill="#1a1a1a">JS</text>
      </svg>
    SVG
  when 'node'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2 20.5 6.9v10.2L12 22 3.5 17.1V6.9L12 2Z" fill="#3C873A"/>
        <text x="12" y="16" text-anchor="middle" font-family="'Helvetica Neue', Arial, sans-serif" font-size="7" font-weight="700" fill="#fff">JS</text>
      </svg>
    SVG
  when 'php'
    <<~SVG
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <ellipse cx="12" cy="12" rx="10.5" ry="7" fill="none" stroke="#8892BF" stroke-width="1.6"/>
        <text x="12" y="14.5" text-anchor="middle" font-family="Georgia, 'Times New Roman', serif" font-style="italic" font-size="8.5" font-weight="700" fill="#8892BF">php</text>
      </svg>
    SVG
  else
    <<~SVG
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.5 6 3.5 12l5 6M15.5 6l5 6-5 6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    SVG
  end
end
