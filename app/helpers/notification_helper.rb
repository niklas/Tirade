module NotificationHelper
  def notification(text, opts={})
    raise "can only add notifications per RJS" unless page
    opts.reverse_merge!({
      :text => text,
      :title => 'Notification'
    })
    page << %Q~$.gritter.add(#{opts.to_json})~
  end
end
