xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.template_editions do
    @editions.each do |edition|
      xml.template_edition("edition_key" => edition.id, "status" => Edition::STATUS[edition.status]) do 
        xml.title(edition.edition)
        unless edition.phase.nil?
          xml.phase(edition.phase.phase)
          unless edition.phase.template.nil?
            xml.template(edition.phase.template.name)
            unless edition.phase.template.organisation.nil?
              xml.organisation(edition.phase.template.organisation.full_name)
            end
          end
        end
      end
    end
  end
end