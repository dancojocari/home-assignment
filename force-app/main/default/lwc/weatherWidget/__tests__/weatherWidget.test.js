import { createElement } from 'lwc';
import WeatherWidget from 'c/weatherWidget';

describe('c-weather-widget', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('checks if lightning record edit form is not rendered and edit button is renedered', () => {
        const element = createElement('c-weather-widget', {
            is: WeatherWidget
        });

        document.body.appendChild(element);

        const lb = element.shadowRoot.querySelector('lightning-button');
        const lref = element.shadowRoot.querySelector('lightning-record-edit-form');
        expect(lb).not.toBeNull();
        expect(lref).toBeNull();
    });
});