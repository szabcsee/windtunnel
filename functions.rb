
def generate_pdf(card)
  content_type 'application/pdf'
  pdf = Prawn::Document.new(:page_size => [550, 870],
                            :page_layout => :landscape,
                            :margin => 0,
                            :info   => {  # A4
                                          :Title    => "Skyward Card",
                                          :Author   => "Skyward",
                                          :Subject  => "Fly Time Card",
                                          :Producer => "digitalyogis",
                                          :Creation => Time.now })
  pdf.font_families.update("Asap" => { :normal => "public/fonts/Asap-Regular.ttf",
                       :italic => "public/fonts/Asap-Italic.ttf",
                       :bold => "public/fonts/Asap-Bold.ttf",
                       :bold_italic => "public/fonts/Asap-BoldItalic.ttf"})
  #pdf.image('public/img/skyward-test-card.jpg', :at  => [0, 550], :fit => [870, 550])
  pdf.fill_color "38363a"
  pdf.font "Asap"
  pdf.draw_text card.amount.to_s + ".-", :at => [330,210], :size => 120, :style => :bold_italic
  pdf.fill_color "38363a"
  pdf.draw_text card.expiry_date, :at => [330,120], :size => 36, :style => :bold
  pdf.draw_text card.booking_code, :at => [330,45], :size => 36, :style => :bold
  pdf.fill_color "38363a"
  pdf.draw_text card.serial_number, :at => [5,5], :size => 12

  pdf.render
end