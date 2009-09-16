class EditRecordFrameRenderer < RecordFrameRenderer
  def partial
    'form'
  end

  def links
    [
      template.link_to_cancel
    ]
  end

  def title
    if record.new_record?
      super
    else
      "Edit #{super}"
    end
  end
end
