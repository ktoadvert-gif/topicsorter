import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
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

  // Use get() to read from the Ember model safely in case it hasn't been initialized
  @tracked selectedCountry = this.model.get ? this.model.get("location_country") : this.model.location_country;
  @tracked selectedRegion = this.model.get ? this.model.get("location_region") : this.model.location_region;
  @tracked selectedCity = this.model.get ? this.model.get("location_city") : this.model.location_city;

  get currentCountry() {
    return this.selectedCountry;
  }

  get currentRegion() {
    return this.selectedRegion;
  }

  get currentCity() {
    return this.selectedCity;
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
    this.selectedCountry = value || null;
    this.selectedRegion = null;
    this.selectedCity = null;
    this.updateModel();
  }

  @action
  onRegionChange(value) {
    this.selectedRegion = value || null;
    this.selectedCity = null;
    this.updateModel();
  }

  @action
  onCityChange(value) {
    this.selectedCity = value || null;
    this.updateModel();
  }

  updateModel() {
    if (this.model.set) {
      this.model.set("location_country", this.selectedCountry);
      this.model.set("location_region", this.selectedRegion);
      this.model.set("location_city", this.selectedCity);
    } else {
      this.model.location_country = this.selectedCountry;
      this.model.location_region = this.selectedRegion;
      this.model.location_city = this.selectedCity;
    }
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
