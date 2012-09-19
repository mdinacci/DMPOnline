# encoding: utf-8
class OfficeOpenXML
  
  def self.transform(xml, newdoc, template, media_logo)
    docx = new(xml, newdoc, template, media_logo)
    docx.build_docx
  end

  def initialize(xml, newdoc, template, media_logo)
    @xml, @newdoc = xml, newdoc

    @tpl = File.expand_path(File.join(File.dirname(__FILE__), "../templates/#{template}"))
    @media_logo = File.file?(media_logo) ? media_logo : ''
#    FileUtils.copy("#{@tpl}/dmp.docx", @newdoc)    
  end

  # Previously this was done by only updating certain files in a copy of the ZIP file.
  # This worked with zipruby, but rubyzip corrupts the other entries with this method
  # So we create a new ZIP file and transfer all entries from the template ZIP file
  # transforming those that need to be as we go
  def build_docx
    templates = %w[document header1 footer1 styles]

    Zip::ZipInputStream::open("#{@tpl}/dmp.docx") do |source|
      Zip::ZipOutputStream::open(@newdoc) do |dest|

        while (entry = source.get_next_entry)
          new_xml = ""

          entry.name.match(/word\/(.*)\.xml/) do |m|
            if templates.include?(m[1])
              xslt = Nokogiri::XSLT.parse(File.open("#{@tpl}/#{m[1]}.xsl"))
              new_xml = xslt.transform(Nokogiri::XML.parse(@xml))
            end
          end
          
          if @media_logo.present? && entry.name =~ /word\/media\/image1.png/
            dest.put_next_entry(entry.name)
            image = File.open(@media_logo, 'rb')
            dest << image.read
            image.close
          elsif new_xml.blank?
            dest.copy_raw_entry(entry)
          else
            dest.put_next_entry(entry.name)
            dest.write new_xml.to_s
          end
        end
      end
    end
  end


end
