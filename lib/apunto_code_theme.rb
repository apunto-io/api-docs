# frozen_string_literal: true

# Syntax colors for the examples column. The column stays dark in both page
# themes, so one palette serves light and dark mode. Calm tones close to
# GitHub Dark Dimmed so JSON responses stay readable for long stretches.
module Rouge
  module Themes
    class ApuntoCode < CSSTheme
      name 'apunto.code'

      palette text: '#d6deeb'
      palette muted: '#7d8aa3'
      palette string: '#a5d6a7'
      palette key: '#93c5fd'
      palette number: '#fbbf77'
      palette keyword: '#c4a7ff'
      palette builtin: '#7dd3fc'
      palette error: '#fca5a5'
      palette punctuation: '#a3b0c7'

      style Text, fg: :text
      style Error, fg: :error
      style Comment, Comment::Single, Comment::Multiline, Comment::Preproc, Comment::Special, fg: :muted, italic: true
      style Keyword, Keyword::Constant, Keyword::Declaration, Keyword::Namespace, Keyword::Reserved, Keyword::Type, fg: :keyword
      style Keyword::Pseudo, fg: :keyword
      style Operator, Operator::Word, fg: :punctuation
      style Punctuation, fg: :punctuation
      style Name, fg: :text
      style Name::Attribute, Name::Tag, fg: :key
      style Name::Builtin, Name::Builtin::Pseudo, Name::Function, Name::Class, fg: :builtin
      style Name::Variable, Name::Variable::Global, Name::Variable::Instance, Name::Constant, fg: :text
      style Name::Label, fg: :key
      style Literal::String, Literal::String::Double, Literal::String::Single, Literal::String::Backtick,
            Literal::String::Heredoc, Literal::String::Interpol, Literal::String::Other, Literal::String::Symbol, fg: :string
      style Literal::String::Escape, fg: :number
      style Literal::String::Regex, fg: :number
      style Literal::Number, Literal::Number::Integer, Literal::Number::Float, Literal::Number::Hex, fg: :number
      style Generic::Deleted, fg: :error
      style Generic::Inserted, fg: :string
      style Generic::Heading, Generic::Subheading, fg: :key, bold: true
      style Generic::Emph, italic: true
      style Generic::Strong, bold: true
      style Generic::Prompt, fg: :muted
      style Generic::Output, fg: :muted
    end
  end
end
