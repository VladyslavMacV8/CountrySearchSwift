//
//  APIManager.swift
//  CountrySearch
//
//  Created by Vladyslav Kudelia on 10/10/18.
//  Copyright © 2018 Wezom Mobile. All rights reserved.
//

import Moya
import ReactiveSwift
import Result

// MARK: - Provider setup
private func JSONResponseDataFormatter(data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data as Data, options: [])
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData as Data
    } catch {
        return data // fallback to original data if it cant be serialized
    }
}

// MARK: - Provider support
private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

public enum ApiManager {
    case byName(String)
    case byRegion(String)
    case byCode(String)
    case byCodes(String)
}

extension ApiManager: TargetType {
    public var task: Task {
        return Task.requestPlain
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: Constants.baseURL)!
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var path: String {
        switch self {
        case .byName(let title):
            return "name/\(title)"
        case .byRegion(let title):
            return "region/\(title)"
        case .byCode(let code):
            return "alpha/\(code)"
        case .byCodes(_):
            return "alpha"
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var parameters: Task {
        switch self {
        case .byName(_):
            return .requestPlain
        case .byRegion(_):
            return .requestPlain
        case .byCode(_):
            return .requestPlain
        case .byCodes(let code):
            return .requestCompositeData(bodyData: Data(), urlParameters: [ApiManagerKey.codes: code])
        }
    }
}

let plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]

let networkProvider = MoyaProvider<ApiManager>(endpointClosure: endpointClosure, plugins: plugins)

func processing(observer: Signal<(), ErrorEntity>.Observer, result: Result<Moya.Response, MoyaError>, closure: ((Any)->())?) {
    switch(result) {
    case let .success(response):
        do {
            let json = try response.mapJSON()
            closure?(json)
            observer.sendCompleted()
        } catch {
            observer.send(error: ErrorEntity.otherError("Error with casting to \"Any\""))
        }
    case .failure(let error):
        observer.send(error: ErrorEntity.otherError(error.localizedDescription))
    }
}
