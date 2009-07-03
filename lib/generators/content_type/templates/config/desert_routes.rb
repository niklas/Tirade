# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>
#
# These file is automatically loaded from tirade's routes.rb if it lies in a 
# plugin directory named tirade_

resources :<%= table_name %>, :path_prefix => '/manage'
