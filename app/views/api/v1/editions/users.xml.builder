xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.template_edition("edition_key" => @edition.id) do 
    @users.each do |u|
      xml.user("email" => u.email)
    end
  end
end