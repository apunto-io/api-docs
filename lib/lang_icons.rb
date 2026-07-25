# Maps Slate language tab keys to brand icon assets under source/images/lang/.
def lang_icon_asset(key)
  {
    'shell' => 'curl',
    'ruby' => 'ruby',
    'python' => 'python',
    'javascript' => 'javascript',
    'node' => 'javascript',
    'php' => 'php'
  }.fetch(key.to_s, key.to_s)
end
