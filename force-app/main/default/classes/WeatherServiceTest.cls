@isTest
private class WeatherServiceTest {

    @isTest
    static void testGetWeatherInfo_NoAccount() {
        Map<String, Object> result = WeatherService.getWeatherInfo('0017R00002z5xm3QAZ');
        System.Assert.areEqual((String) result.get('iconName'), 'error', 'Assertion failed.');
    }
    
    @isTest 
    static void testGetWeatherInfo_NoLatLng() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );

        insert testAccount;

        Map<String, Object> result = WeatherService.getWeatherInfo(testAccount.Id);
        System.Assert.areEqual((String) result.get('iconName'), 'error', 'Assertion failed.');
    }

    @isTest 
    static void testGetWeatherInfo_Success() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingLatitude = 44.4375,
            BillingLongitude = 26.125
        );

        insert testAccount;

        String sampleJsonBody = '{"latitude":44.4375,"longitude":26.125,"generationtime_ms":0.8869171142578125,"utc_offset_seconds":10800,"timezone":"Europe/Bucharest","timezone_abbreviation":"EEST","elevation":85.0,"daily_units":{"time":"iso8601","weathercode":"wmo code"},"daily":{"time":["2023-08-29"],"weathercode":[80]}}';
        Test.setMock(HttpCalloutMock.class, new HttpService.HttpMockResponse(sampleJsonBody, 200));
        Test.startTest();
        Map<String, Object> result = WeatherService.getWeatherInfo(testAccount.Id);
        System.Assert.areEqual((String) result.get('iconName'), 'rain_shower', 'Assertion failed.');
        Test.stopTest();
    }

    @isTest 
    static void testGetWeatherInfo_Error() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingLatitude = 44.4375,
            BillingLongitude = 26.125
        );

        insert testAccount;

        String sampleJsonBody = '{"latitude":44.4375,"longitude":26.125,"generationtime_ms":0.8869171142578125,"utc_offset_seconds":10800,"timezone":"Europe/Bucharest","timezone_abbreviation":"EEST","elevation":85.0,"daily_units":{"time":"iso8601","weathercode":"wmo code"},"daily":{"time":["2023-08-29"],"weathercode":[80]}}';
        Test.setMock(HttpCalloutMock.class, new HttpService.HttpMockResponse(sampleJsonBody, 500));
        Test.startTest();
        Map<String, Object> result = WeatherService.getWeatherInfo(testAccount.Id);
        System.Assert.areEqual((String) result.get('iconName'), 'error', 'Assertion failed.');
        Test.stopTest();
    }
}