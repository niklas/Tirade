module PublicHelper
  def dangling_id
    @dangling_id ||= (@controller.instance_variable_get('@item_id')) || 
      (@controller.params.andand[:path].andand.last.andand =~ /^(\d+)$/ ? $1.to_i : nil)
  end

  def title
    returning '' do |title|
      if @page
        title << @page.title unless @page.title.blank?
      end
      if main = Settings.title || 'Tirade'
        title << " - #{main}"
      end
    end
  end
end
