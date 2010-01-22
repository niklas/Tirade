# FIXME make indepenant von Reseller BS
class JobsController < ManageResourceController::Base
  def create_export
    if current_user.reseller.nil?
      locales = %w( en )
      #locales = %w( en de )

      if Job.create :job => 'StaticExportJob', :argument => "--locales #{locales.join(',')} --syncto websync1:/var/www"
        export_started
      else
        export_failed
      end
    else
      access_denied(SecurityError.new('You are a reseller and cannot export the whole site.'))
    end
  end

  def create_reseller_export
    if current_user.reseller.nil?
      access_denied(SecurityError.new('You are not a reseller, please contact an administrator.'))
    else
      res = current_user.reseller
      locales = ( %w(en) +  res.all_country_codes ).join(',')
      if Job.create :job => 'StaticExportJob', :argument => "--locales #{locales} --mailto #{res.email}"
        export_started
      else
        export_failed
      end
    end
  end

  private
  def export_started
    respond_to do |format|
      format.js do
        render :update do |page|
          page.notification "Exporting", :title => 'Export started..'
        end
      end
      format.html do
        render :text => 'Export started...'
      end
    end
  end

  def export_failed
    flash[:error] = "Export failed. Touch luck!"
    redirect_to root_url
  end
end
