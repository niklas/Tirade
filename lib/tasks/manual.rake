
namespace :tirade do
  namespace :manual do
    task :build do
      svgs = Dir['manual/Manual*.svg']
      pdfs = svgs.map {|svg| svg.sub(/\.svg$/, '.pdf')}
      svgs.zip(pdfs).each do |svg,pdf|
        system 'inkscape', '-A', pdf, svg
      end
      system "pdftk manual/Manual\\ -*pdf cat output manual/Manual.pdf"
      pdfs.each do |pdf|
        File.delete(pdf)
      end
    end
  end
end
