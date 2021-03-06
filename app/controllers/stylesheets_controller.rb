class StylesheetsController < ApplicationController
  before_filter :set_headers
  before_filter :set_vars
  skip_before_filter :set_current_permissions
  skip_before_filter :check_permissions
  skip_before_filter :login_required
  after_filter { |controller| controller.cache_page }
  layout nil

  private

  def set_headers
    headers['Content-Type'] = 'text/css; charset=utf-8'
  end

  def set_vars
    # Margins / Paddings
    @tiny   = '0.1em'
    @small  = '0.3em'
    @medium = '0.7em'
    @big    = '1.3em'
    @colors = {
      :base         => '#f0f0f0',

      :hover        => '#90CAFC',
      :perimeter    => '#dedede',

      :toolbox_border => '#cdcdcd',
      :toolbox_border_dark => '#898989',
      :decoration     => '#474747',
      :warning      => '#c72c1e',
      :selected     => '#bdbdbd',
      :text         => '#222222',

      :input        => '#f1f5f6',
      :input_border => '#777777',
      :element      => '#bbbbbb',
      :border_dark  => '#dedede',
      :clickable    => '#133B5E',
      :error        => '#df5f6e',
    }
    @perimeter = "1px solid #{@colors[:perimeter]}" # border around elements
  end
end
