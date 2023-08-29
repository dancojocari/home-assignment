public with sharing class WeatherService {

    final static String nameCredentialsPrefix = 'callout:WeatherAPI';
    final static String servicePath = '/v1/forecast';
    
    @AuraEnabled
    public static Map<String, Object> getWeatherInfo(Id accountId) {
        String errorMessage = null;
        try {
            List<Account> acc = [
                SELECT
                    BillingLatitude,
                    BillingLongitude
                FROM
                    Account
                WHERE 
                    Id = :accountId
            ];

            if (acc.isEmpty()) {
                throw new WeatherException(System.Label.WeatherWidgetNoAccount);
            }

            if (acc[0].BillingLatitude == null || acc[0].BillingLongitude == null) {
                throw new WeatherException(System.Label.WeatherWidgetMissingLatLng);
            }
            
            String endpoint = getComputedEndpoint(acc[0].BillingLatitude, acc[0].BillingLongitude);

            HttpResponse response = HttpService.sendGetRequest(endpoint);

            if (response.getStatusCode() == 200) {

                String responseBody = response.getBody();

                WeatherData weatherData = (WeatherData) JSON.deserialize(responseBody, WeatherData.class);

                return getWeatherMessageFromCode(weatherData.daily.weathercode[0]);
            } else {
                errorMessage = System.Label.WeatherWidgetFailedCalloutMessage + response.getStatusCode();
                LogController.log('WeatherService.getWeatherInfo', errorMessage);
            }
        } catch (Exception e) {
            errorMessage = e.getMessage();
            LogController.log('WeatherService.getWeatherInfo', e);
        }

        return new Map<String, Object> {
            'weatherMessage' => errorMessage,
            'iconName' => 'error'
        };
    }

    private static Map<String, Object> getWeatherMessageFromCode(Integer weatherCode) {
        List<Weather_Codes_Mapping_Setting__mdt> cmtRecords = [
            SELECT 
                Code__c,
                Icon_Name__c,
                Description__c
            FROM
                Weather_Codes_Mapping_Setting__mdt
            WHERE 
                Code__c = :weatherCode
        ];

        if (cmtRecords.isEmpty()) {
            throw new WeatherException(System.Label.WeatherWidgetMissingMetadataType);
        }

        return new Map<String, Object> {
            'weatherMessage' => cmtRecords[0].Description__c,
            'iconName' => cmtRecords[0].Icon_Name__c
        };
    }

    private static String getComputedEndpoint(Decimal latitude, Decimal longitude) {
        String startDate = Datetime.now().addDays(1).format('yyyy-MM-dd');
        String endDate = startDate;

        Map<String, String> parametersMap = new Map<String, String> {
            'latitude' => String.valueOf(latitude), 
            'longitude' => String.valueOf(longitude), 
            'daily' => 'weathercode',
            'timezone' => EncodingUtil.urlEncode(String.valueOf(UserInfo.getTimeZone()), 'UTF-8'),
            'start_date' => startDate,
            'end_date' => endDate
        };

        return nameCredentialsPrefix + servicePath + '?' + getUrlParametersString(parametersMap);
    }

    private static String getUrlParametersString(final Map<String, String> parametersMap) {
        List<String> parameterPairList = new List<String>();

        for (String key : parametersMap.keySet()) {
            parameterPairList.add(key + '=' + parametersMap.get(key));
        }

        return String.join(parameterPairList, '&');
    }

    public class WeatherData {
        public Decimal latitude;
        public Decimal longitude;
        public Decimal generationtime_ms;
        public Integer utc_offset_seconds;
        public String timezone;
        public String timezone_abbreviation;
        public Double elevation;
        public DailyUnits daily_units;
        public DailyData daily;
    }

    public class DailyUnits {
        public String timeStandard;
        public String weathercode;
    }

    public class DailyData {
        public List<String> timeValue;
        public List<Integer> weathercode;
    }

    public class WeatherException extends Exception {}
}