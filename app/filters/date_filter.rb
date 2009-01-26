module DateFilter
  # TODO make nice_date depend on locale
  def nice_date(date=nil)
    if date
      date.strftime '%d.%m.%Y - %H:%M'
    else
      ''
    end
  end
end
