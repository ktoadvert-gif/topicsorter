import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "topicsorter-filters",
  initialize() {
    withPluginApi("0.8", (api) => {
      // Add 'location_country', 'location_region', 'location_city' to discovery route query params
      api.modifyClass("route:discovery", {
        pluginId: "discourse-topicsorter",

        queryParams: Object.assign(
          {},
          this._super(...arguments) || {},
          {
            location_country: { refreshModel: true, replace: true },
            location_region: { refreshModel: true, replace: true },
            location_city: { refreshModel: true, replace: true },
          }
        ),
      });
    });
  },
};
