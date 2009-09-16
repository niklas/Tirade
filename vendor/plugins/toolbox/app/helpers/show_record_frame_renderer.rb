class ShowRecordFrameRenderer < RecordFrameRenderer
  def partial
    'show'
  end

  def links
    [
      template.link_to_edit(record),
      template.link_to_destroy(record)
    ]
  end
end

