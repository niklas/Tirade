module RjsHelper
  # use other helpers from rjs helper methods, for example
  #
  # def append_link_to_frame
  #   page.select('.frame').append context.link_to(...)
  # end
  #
  # called by
  #  page.append_link_to_frame
  def context
    page.instance_variable_get("@context").instance_variable_get("@template")
  end
end
