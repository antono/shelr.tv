class HTMLWithAlbinoRenderer < Redcarpet::Render::HTML
  def block_code(code, lexer)
    Albino.colorize(code, lexer || :text)
  end
end
