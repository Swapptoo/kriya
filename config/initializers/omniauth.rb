Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.facebook_id, Rails.application.secrets.facebook_secret, {
    scope: "public_profile,email",
    info_fields: "name,email,first_name,last_name",
    image_size: {width: 100, height: 100}
  }
  provider :twitter, Rails.application.secrets.twitter_id, Rails.application.secrets.twitter_secret
  provider :linkedin, Rails.application.secrets.linkedin_id, Rails.application.secrets.linkedin_secret, {
    scope: "r_basicprofile r_emailaddress",
    fields: ['id', 'email-address', 'first-name', 'last-name', 'headline', 'picture-urls::(original)']
  }
end