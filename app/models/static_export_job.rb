class StaticExportJob < Struct.new(:argv)

  def perform
    result = %x{#{command}}
    
    if $?.exitstatus != 0
      update_attribute :last_error, result
    end
  end

  def command
    %Q[echo '#{argv}'; exit 99]
  end
end
