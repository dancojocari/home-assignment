import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import icons from '@salesforce/resourceUrl/icons';

import getWeatherInfo from '@salesforce/apex/WeatherService.getWeatherInfo';

import WeatherWidgetTitle from '@salesforce/label/c.WeatherWidgetTitle';
import WeatherWidgetEditBillingAddress from '@salesforce/label/c.WeatherWidgetEditBillingAddress';
import WeatherWidgetRefresh from '@salesforce/label/c.WeatherWidgetRefresh';
import WeatherWidgetSave from '@salesforce/label/c.WeatherWidgetSave';
import WeatherWidgetSuccess from '@salesforce/label/c.WeatherWidgetSuccess';
import WeatherWidgetSuccessMessage from '@salesforce/label/c.WeatherWidgetSuccessMessage';

export default class WeatherWidget extends LightningElement {

    label = {
        WeatherWidgetTitle, 
        WeatherWidgetEditBillingAddress, 
        WeatherWidgetRefresh, 
        WeatherWidgetSave, 
        WeatherWidgetSuccess, 
        WeatherWidgetSuccessMessage
    };

    @api recordId;
    
    isLoading = false;
    isEditAddressMode = false;
    onceLoaded = false;

    weatherMessage = '';
    iconName = '';
    iconFullPath = '';

    icons = icons;

    connectedCallback() {
        if (this.isEditAddressMode) {
            return;
        }

        this.refreshWeatherMessage();
    }    

    async refreshWeatherMessage() {
        this.isLoading = true;

        const params = {
            accountId: this.recordId
        };

        const response = await getWeatherInfo(params);
        
        this.weatherMessage = response?.weatherMessage;
        this.iconName = response?.iconName;

        this.iconFullPath = `${this.icons}/${this.iconName}.png`;
    }

    handleEditAddressClick(event) {
        this.isEditAddressMode = true;
    }

    handleRefreshButtonClick(event) {
        this.refreshWeatherMessage();
    }

    handleFormLoad(event) {
        if (this.onceLoaded) {
            return;
        }
        
        this.onceLoaded = true;

        this.refreshWeatherMessage();
    }

    handleFormSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleFormSuccess() {
        this.refreshWeatherMessage();
        this.isEditAddressMode = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: this.label.WeatherWidgetSuccess,
                message: this.label.WeatherWidgetSuccessMessage,
                variant: 'success'
            })
        );
    }
}