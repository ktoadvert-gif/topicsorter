import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import ComboBox from "select-kit/components/combo-box";

export default class TopicsorterComposer extends Component {
  @service siteSettings;

  get taxonomy() {
    try {
      const setting = this.siteSettings.topicsorter_taxonomy;
      return setting ? JSON.parse(setting) : [];
    } catch (e) {
      console.error("Failed to parse topicsorter_taxonomy", e);
      return [];
    }
  }

  get model() {
    return this.args.outletArgs.model;
  }

  get currentCountry() {
    return this.model.location_country;
  }

  get currentRegion() {
    return this.model.location_region;
  }

  get currentCity() {
    return this.model.location_city;
  }

  get countries() {
    return this.taxonomy.map(item => {
      return { id: item.country, name: item.country };
    });
  }

  get regions() {
    if (!this.currentCountry) return [];
    const countryObj = this.taxonomy.find(c => c.country === this.currentCountry);
    if (!countryObj || !countryObj.regions) return [];
    
    return countryObj.regions.map(r => {
      return { id: r.region, name: r.region };
    });
  }

  get cities() {
    if (!this.currentCountry || !this.currentRegion) return [];
    const countryObj = this.taxonomy.find(c => c.country === this.currentCountry);
    if (!countryObj || !countryObj.regions) return [];
    
    const regionObj = countryObj.regions.find(r => r.region === this.currentRegion);
    if (!regionObj || !regionObj.cities) return [];
    
    return regionObj.cities.map(city => {
      return { id: city, name: city };
    });
  }

  get countryOptions() {
    return {
      none: "select_country",
      clearable: true,
      nameProperty: "name",
      valueProperty: "id"
    };
  }

  get regionOptions() {
    return {
      none: "select_region",
      clearable: true,
      nameProperty: "name",
      valueProperty: "id"
    };
  }

  get cityOptions() {
    return {
      none: "select_city",
      clearable: true,
      nameProperty: "name",
      valueProperty: "id"
    };
  }

  @action
  onCountryChange(value) {
    this.model.set("location_country", value || null);
    this.model.set("location_region", null);
    this.model.set("location_city", null);
  }

  @action
  onRegionChange(value) {
    this.model.set("location_region", value || null);
    this.model.set("location_city", null);
  }

  @action
  onCityChange(value) {
    this.model.set("location_city", value || null);
  }

  get showFields() {
    // Only show these fields when creating a new topic or editing the first post
    return this.model.action === "createTopic" || this.model.creatingTopic || (this.model.action === "edit" && this.model.isFirstPost);
  }

  <template>
    {{#if this.showFields}}
      <div class="topicsorter-composer-fields" style="display: flex; gap: 10px; margin-bottom: 10px; width: 100%;">
        <ComboBox
          @options={{this.countryOptions}}
          @content={{this.countries}}
          @value={{this.currentCountry}}
          @onChange={{this.onCountryChange}}
          class="topicsorter-country-drop"
        />

        {{#if this.currentCountry}}
          <ComboBox
            @options={{this.regionOptions}}
            @content={{this.regions}}
            @value={{this.currentRegion}}
            @onChange={{this.onRegionChange}}
            class="topicsorter-region-drop"
          />
        {{/if}}

        {{#if this.currentRegion}}
          <ComboBox
            @options={{this.cityOptions}}
            @content={{this.cities}}
            @value={{this.currentCity}}
            @onChange={{this.onCityChange}}
            class="topicsorter-city-drop"
          />
        {{/if}}
      </div>
    {{/if}}
  </template>
}
