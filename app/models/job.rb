class Job < Delayed::Job
  attr_accessor :job
  attr_accessor :argument
  attr_accessible :job, :argument, :run_at
  Supported = %w(
    StaticExportJob
  )
  validates_inclusion_of :job, :in => Supported

  def title
    name
  rescue Delayed::DeserializationError => e   # there is no #['handler#] availabe yet
    job
  end

  def has_arguments?
    payload_object && payload_object.respond_to?(:members) && !payload_object.members.blank?
  rescue Delayed::DeserializationError => e   # there is no #['handler#] availabe yet
    false
  end

  def arguments
    if has_arguments?
      payload_object.values
    else
      [argument]
    end
  end

  private
  def apply_payload
    self.payload_object = job_klass.new(argument)
  end
  before_create :apply_payload
  
  def job_klass
    job.constantize
  end
end
