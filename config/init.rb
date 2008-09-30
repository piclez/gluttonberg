# Turn on UTF-8 with this opaque assignment here
$KCODE = "UTF-8"

use_orm :datamapper
use_test :rspec
use_template_engine :haml

dependency 'dm-is-tree'
dependency 'dm-observer'
dependency 'dm-is-list'
dependency 'dm-validations'
dependency 'dm-timestamps'
dependency 'dm-types'
dependency 'merb-assets'
dependency 'merb-action-args'
dependency 'merb_helpers'
# Some additional load paths for auto-loading
# Merb.push_path(:lib, (Merb.root / "lib"), "**/*.rb")
dependency 'lib/core_ext'
dependency 'lib/admin_controller'
dependency 'lib/content'

Merb::Config.use do |c|
  c[:session_id_key] = 'low_fat_content_management'
  c[:session_secret_key]  = 'cbf85572c84cd403a94c32a68e50775f642c4f59'
  c[:session_store] = 'cookie'
end

Merb::BootLoader.after_app_loads do
  Glutton::Content.setup
  Merb.logger.info("Force DM associations to load")
  # This is a temporary fix, to force DM to load all the association properties
  descendants = DataMapper::Resource.descendants.dup
  descendants.each do |model|
    descendants.merge(model.descendants) if model.respond_to?(:descendantss)
  end
  descendants.each do |model|
    model.relationships.each_value { |r| r.child_key if r.child_model == model }
  end
end
