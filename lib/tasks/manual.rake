
namespace :tirade do
  namespace :manual do
    task :build do
      svgs = Dir['manual/Manual*.svg']
      markdowns = {
        'README.markdown' => 'manual/Manual - Page 0.1 - Introduction.pdf',
        'USAGE.markdown' => 'manual/Manual - Page 0.2 - Usage.pdf'
      }
      pdfs = svgs.map {|svg| svg.sub(/\.svg$/, '.pdf')}
      svgs.zip(pdfs).each do |svg,pdf|
        system 'inkscape', '-A', pdf, svg
      end
      markdowns.each do |markdown, pdf|
        system 'markdown2pdf', '-o', pdf, markdown
      end

      system "pdftk manual/Manual\\ -*pdf cat output manual/Manual.pdf"

      pdfs.each do |pdf|
        File.delete(pdf)
      end
      markdowns.values.each do |pdf|
        File.delete(pdf)
      end
    end
  end
end
