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

  # Allow frontend to pass location params to TopicQuery
  add_to_class(:list_controller, :build_topic_list_options) do
    options = super
    options[:location_country] = params[:location_country] if params[:location_country].present?
    options[:location_region] = params[:location_region] if params[:location_region].present?
    options[:location_city] = params[:location_city] if params[:location_city].present?
    options
  end

  # Filter the database queries based on locations
  if defined?(TopicQuery)
    TopicQuery.add_custom_filter(:location_country) do |results, topic_query|
      if topic_query.options[:location_country].present?
        results = results.joins("INNER JOIN topic_custom_fields tcf_country ON tcf_country.topic_id = topics.id")
                         .where("tcf_country.name = 'location_country' AND tcf_country.value = ?", topic_query.options[:location_country])
      end
      results
    end

    TopicQuery.add_custom_filter(:location_region) do |results, topic_query|
      if topic_query.options[:location_region].present?
        results = results.joins("INNER JOIN topic_custom_fields tcf_region ON tcf_region.topic_id = topics.id")
                         .where("tcf_region.name = 'location_region' AND tcf_region.value = ?", topic_query.options[:location_region])
      end
      results
    end

    TopicQuery.add_custom_filter(:location_city) do |results, topic_query|
      if topic_query.options[:location_city].present?
        results = results.joins("INNER JOIN topic_custom_fields tcf_city ON tcf_city.topic_id = topics.id")
                         .where("tcf_city.name = 'location_city' AND tcf_city.value = ?", topic_query.options[:location_city])
      end
      results
    end
  end
end
