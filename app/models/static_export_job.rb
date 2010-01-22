class StaticExportJob < Struct.new(:argv)

  def perform
    result = %x{#{command}}
    
    if $?.exitstatus != 0
      raise RuntimeError, result
    end
  end

  def command
    %Q[script/export #{argv} RAILS_ENV=#{RAILS_ENV}]
  end
end
