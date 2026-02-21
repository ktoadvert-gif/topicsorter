import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import ComboBox from "select-kit/components/combo-box";

export default class TopicsorterDropdowns extends Component {
  @service router;
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

  get currentCountry() {
    return this.router.currentRoute?.queryParams?.location_country;
  }

  get currentRegion() {
    return this.router.currentRoute?.queryParams?.location_region;
  }

  get currentCity() {
    return this.router.currentRoute?.queryParams?.location_city;
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
    this.router.transitionTo({
      queryParams: {
        location_country: value || null,
        location_region: null,
        location_city: null
      }
    });
  }

  @action
  onRegionChange(value) {
    this.router.transitionTo({
      queryParams: {
        location_region: value || null,
        location_city: null
      }
    });
  }

  @action
  onCityChange(value) {
    this.router.transitionTo({
      queryParams: {
        location_city: value || null
      }
    });
  }

  // Only show on topic lists like latest, top, categories etc.
  get showFilters() {
    const routeName = this.router.currentRouteName;
    return routeName && routeName.startsWith("discovery.");
  }

  <template>
    {{#if this.showFilters}}
      <div class="topicsorter-filters" style="display: flex; gap: 10px; margin-bottom: 15px; align-items: center;">
        <span style="font-weight: bold;">Location Filters:</span>
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
