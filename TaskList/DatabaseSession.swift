import Foundation

struct DatabaseSession {
    
    struct Response {
        
        private var mData: Data?
        private var mHTTPResponse: URLResponse?
        private var mError: Error?
        
        var data: Data? {
            get { return mData }
        }
        var httpResponse: URLResponse? {
            get { return mHTTPResponse }
        }
        var error: Error? {
            get { return mError }
        }
        
        init(data: Data?, httpResponse: URLResponse?, error: Error?) {
            mData = data
            mHTTPResponse = httpResponse
            mError = error
        }
        
    }
    
    private var mURLComponents: URLComponents
    
    init?(with url: String) {
        guard let urlComponents = URLComponents(string: url) else {
            return nil
        }
        self.mURLComponents = urlComponents
    }
    
    mutating func sync(queries: [String: String], method: HTTPMethod) -> Response {
        var result: (Data?, URLResponse?, Error?)?
        let semaphore = DispatchSemaphore(value: 0)
        async(queries: queries, method: method) { data, response, error in
            result = (data, response, error)
            semaphore.signal()
        }
        semaphore.wait()
        return Response(data: result?.0, httpResponse: result?.1, error: result?.2)
    }
    
    mutating func async(queries: [String: String], method: HTTPMethod) {
        async(queries: queries, method: method){_, _, _ in}
    }
    
    mutating func async(queries: [String: String], method: HTTPMethod, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var dataTask: URLSessionDataTask?
        switch method {
        case .get:
            let url = getURL(queries: queries)
            dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        case .post:
            let request = getURLRequest(queries: queries)
            dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        }
        dataTask?.resume()
    }
    
    private mutating func getURL(queries: [String: String]) -> URL {
        var queryItems: [URLQueryItem] = []
        queryItems.reserveCapacity(queries.count)
        for (name, value) in queries {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        mURLComponents.queryItems = queryItems
        return mURLComponents.url!
    }
    
    private func getURLRequest(queries: [String: String]) -> URLRequest {
        let url = mURLComponents.url!
        var components = URLComponents()
        components.queryItems = queries.map {URLQueryItem(name: $0, value: $1)}
        let httpBody = components.query!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody.data(using: .utf8)
        return request
    }
    
}
