require File.dirname(__FILE__) + '/../spec_helper'

describe "With Lockdown rules applied" do
  
  describe Lockdown::System.public_access, 'as public rights' do

    it { should include('public') }
    it { should include('public/index') }

    it { should include('stylesheets/toolbox') }
    it { should include('stylesheets/toolbox_colors') }
    it { should include('stylesheets/interface') }
    it { should include('stylesheets/permissions') }
    it { should include('stylesheets/focus') }

    it { should include('javascripts/named_routes') }

    it { should include('images/custom') }

    # Hidden actions, before filters etc
    it { should_not include_any(/check_permissions/) }
    it { should_not include_any(/current_permission_names/) }
    it { should_not include_any(/current_user_may_access\?/) }
    it { should_not include_any(/authorize/) }
    it { should_not include_any(/configure_lockdown/) }
    it { should_not include_any(/object_name/) }
    it { should_not include_any(/route_name/) }
    it { should_not include_any(/check_request_authorization/) }
  end


end

