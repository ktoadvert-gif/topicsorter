# frozen_string_literal: true

# name: discourse-topicsorter
# about: A dummy plugin to verify connection
# version: 0.0.1
# authors: Admin
# url: https://github.com/admin/discourse-topicsorter

after_initialize do
  Rails.logger.info("Initializing discourse-topicsorter plugin...")
end
