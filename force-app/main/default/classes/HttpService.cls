public with sharing class HttpService {

    static final Integer timeout = 120000;

    public static HttpResponse sendGetRequest(final String endpoint) {
        return sendGetRequestWithHeaders(endpoint, new Map<String, String>());
    }

    public static HttpResponse sendGetRequestWithHeaders(final String endpoint, final Map<String,String> headers) {
        HttpRequest req = createRequestWithHeaders(endpoint, headers);

        req.setMethod('GET');
        
        return new Http().send(req);
    }

    private static HttpRequest createRequestWithHeaders(final String endpoint, final Map<String,String> headers) {
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint);
        req.setTimeout(timeout);
        
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }

        return req;
    }

    public class HttpMockResponse implements HttpCalloutMock {
        private String body;
        private Integer status;

        public HttpMockResponse(String body, Integer status) {
            this.body = body;
            this.status = status;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse result = new HttpResponse();
            result.setBody(body);
            result.setStatusCode(status);
            return result;
        }
    }
}