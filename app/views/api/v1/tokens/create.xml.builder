xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end
  unless @token.blank?
    xml.api_key(@token)
  end
end