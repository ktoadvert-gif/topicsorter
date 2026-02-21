# frozen_string_literal: true

# name: discourse-topicsorter
# about: A dummy plugin to verify connection
# version: 0.0.1
# authors: Admin
# url: https://github.com/admin/discourse-topicsorter

enabled_site_setting :discourse_topicsorter_enabled

after_initialize do
  Rails.logger.info("Initializing discourse-topicsorter plugin...")

  # Register custom fields for topics so they can be saved in DB
  register_topic_custom_field_type('location_country', :string)
  register_topic_custom_field_type('location_region', :string)
  register_topic_custom_field_type('location_city', :string)

  # Preload these custom fields in the topic list for performance
  if defined?(TopicList) && TopicList.respond_to?(:preloaded_custom_fields)
    TopicList.preloaded_custom_fields << "location_country"
    TopicList.preloaded_custom_fields << "location_region"
    TopicList.preloaded_custom_fields << "location_city"
  end

  # Serialize custom fields for the frontend (topic lists and single topic view)
  add_to_serializer(:topic_list_item, :location_country) do
    object.custom_fields["location_country"]
  end
  add_to_serializer(:topic_list_item, :location_region) do
    object.custom_fields["location_region"]
  end
  add_to_serializer(:topic_list_item, :location_city) do
    object.custom_fields["location_city"]
  end

  add_to_serializer(:topic_view, :location_country) do
    object.topic.custom_fields["location_country"]
  end
  add_to_serializer(:topic_view, :location_region) do
    object.topic.custom_fields["location_region"]
  end
  add_to_serializer(:topic_view, :location_city) do
    object.topic.custom_fields["location_city"]
  end
end
