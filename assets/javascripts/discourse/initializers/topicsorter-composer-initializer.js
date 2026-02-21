import { withPluginApi } from "discourse/lib/plugin-api";

export default {
    name: "topicsorter-composer-initializer",
    initialize() {
        withPluginApi("0.8", (api) => {
            // Send fields to the backend on Topic Create
            api.serializeOnCreate("location_country");
            api.serializeOnCreate("location_region");
            api.serializeOnCreate("location_city");

            // Send fields to the backend on Topic Update
            api.serializeOnUpdate("location_country");
            api.serializeOnUpdate("location_region");
            api.serializeOnUpdate("location_city");

            // Restore fields from draft if user closes composer
            api.serializeToDraft("location_country");
            api.serializeToDraft("location_region");
            api.serializeToDraft("location_city");

            // Load current fields when editing a topic
            api.serializeToTopic("location_country", "topic.location_country");
            api.serializeToTopic("location_region", "topic.location_region");
            api.serializeToTopic("location_city", "topic.location_city");
        });
    },
};
