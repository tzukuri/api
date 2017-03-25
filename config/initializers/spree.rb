# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # by default, automatically captue payments (instead of two-step auth/capture)
  config.auto_capture = true

  # use AUD by default
  config.currency = "AUD"


end

Spree.user_class = "Spree::User"

# use larger than default product images
Spree::Image.attachment_definitions[:attachment][:styles] = {
  mini: '48x48',
  small: '110x110',
  product: '635x500',
  large: '650x650'
}
