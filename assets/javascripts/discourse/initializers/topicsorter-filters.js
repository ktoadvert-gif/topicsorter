import { withPluginApi } from "discourse/lib/plugin-api";

export default {
    name: "topicsorter-filters",
    initialize() {
        withPluginApi("0.8", (api) => {
            // Add 'location_country', 'location_region', 'location_city' to discovery route query params
            api.addDiscoveryQueryParam("location_country", { replace: true, refreshModel: true });
            api.addDiscoveryQueryParam("location_region", { replace: true, refreshModel: true });
            api.addDiscoveryQueryParam("location_city", { replace: true, refreshModel: true });
        });
    },
};
