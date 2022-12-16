//
//  NetworkManager.swift
//  AKNetworkManager
//
//  Created by Amit Garg on 12/12/22.
//

import Foundation
import Alamofire

public struct BlankResult : Codable {
}

public enum MediaType : String {
    case image = "Image"
    case video = "Video"
    case document = "Document"
}

public typealias MediaParameter = (Data, MediaType, String)

public enum DataError: Equatable, Error
{
  case BadRequest(String)
  case NetworkError(String)
  case ParsingRequest(String)
  case UnknownError(String)
    
    func errorMessage() -> String {
        switch self {
        case .BadRequest(let msg):
            return msg
        case .NetworkError(let msg):
            return msg
        case .ParsingRequest(let msg):
            return msg
        case .UnknownError(let msg):
            return msg
        }
    }
}

public enum DataResult<U:Codable>
{
  case Success(result: ResponseObject<U>)
  case Failure(error: DataError)
}


public struct ResponseObject<U:Codable>: Codable {
    public var status: Int64? = 0
    public var message: String? = ""
    public var data : U? = nil
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data = "responseData"
    }
}

public typealias DataCompletionHandler<Data:Codable> = (DataResult<Data>) -> Void
public typealias ProgressCompletionHandler = (Double) -> Void

public class NetworkManager {
    
    var baseURL = ""
    var key: String?
    var version: String?
    var token: String?
    var language: String?
    let deviceType = "iOS"
    
    public static let shared = NetworkManager()
    
    public func setup(url: String,
                      key: String? = nil,
                      version: String? = nil,
                      token: String? = nil,
                      language: String? = nil) {
        self.baseURL = url
        self.key = key
        self.version = version
        self.token = token
        self.language = language
    }
    
    open func request<U>(_ API: String,
                      method: HTTPMethod = .post,
                      parameters: Parameters? = nil,
                      isAuthorizationRequired:Bool = true,
                      encoding: ParameterEncoding = JSONEncoding.default,
                      block: @escaping DataCompletionHandler<U>
                      ) -> DataRequest {
     
        if baseURL.isEmpty {
            fatalError("Configure URL")
        }
        
        print("Base API ----\(NetworkManager.shared.baseURL+API)")
        var param = [String:Any]()
        if let paramLoc = parameters {
            param = paramLoc
        }
        param["device_type"] = deviceType
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        if let key {
            headers["api-key"] = key
        }
        if let version {
            headers["version"] = version
        }
        if let language {
            headers["X-localization"] = language
        }
    
        if isAuthorizationRequired == true {
            if let token {
                headers["access-token"] = token
            }
        }
    
        return AF.request(NetworkManager.shared.baseURL+API,
                          method:method,
                          parameters: param,
                          encoding: encoding,
                          headers: headers)
        .responseData(completionHandler: { [weak self] response in
            if let error = response.error {
                if let desc = error.errorDescription {
                    block(DataResult.Failure(error: DataError.NetworkError(desc)))
                } else {
                    block(DataResult.Failure(error: DataError.UnknownError("Unknow error")))
                }
                return
            }
            if let data = response.data {
                do {
                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                       print(string)
                    }
                    
                    let result: ResponseObject<U> = try JSONDecoder().decode(ResponseObject<U>.self, from: data)
                    if result.status != 200 {
                        block(DataResult.Failure(error: DataError.UnknownError(result.message ?? "Unknow error!")))
                    } else {
                        block(DataResult.Success(result: result))
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                    self?.validateJsonWithBlankStructure(ForData: data, block: block)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self?.validateJsonWithBlankStructure(ForData: data, block: block)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self?.validateJsonWithBlankStructure(ForData: data, block: block)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    self?.validateJsonWithBlankStructure(ForData: data, block: block)
                } catch  {
                    self?.validateJsonWithBlankStructure(ForData: data, block: block)
                }
            }
        })
    }
    
    func uploadRequest<U>(api:String, params: [String: Any], isAuthorizationRequired:Bool = true, progressBlock: ProgressCompletionHandler? = nil, block: @escaping DataCompletionHandler<U>) {
        
        if baseURL.isEmpty {
            fatalError("Configure URL")
        }
        
        print("API ----\(NetworkManager.shared.baseURL+api)")
        print("Parameter ----\(params)")
        var parameters = params
        var headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Accept": "application/json"
        ]
        if let key {
            headers["api-key"] = key
        }
        if let version {
            headers["version"] = version
        }
        if let language {
            headers["X-localization"] = language
        }
    
        if isAuthorizationRequired == true {
            if let token {
                headers["access-token"] = token
            }
        }
        parameters["device_type"] = deviceType
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                } else if value is Int {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                } else if value is Int64 {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                } else if let data = value as? MediaParameter {
                    if data.1 == .image {
                        multipartFormData.append(data.0, withName: key, fileName: data.2, mimeType: "image/jpg")
                    } else if data.1 == .video {
                        multipartFormData.append(data.0, withName: key, fileName: data.2, mimeType: "video/mp4")
                    } else if data.1 == .document {
                        if let ext = data.2.getExtension() {
                            if ext == "pdf" {
                               multipartFormData.append(data.0, withName: key, fileName: data.2, mimeType: "application/pdf")
                            } else {
                                multipartFormData.append(data.0, withName: key, fileName: data.2, mimeType: "application/msword")
                            }
                        }
                    }
                }
            }
        }, to: NetworkManager.shared.baseURL + api,
            method: .post,
            headers: headers)
        .responseData(completionHandler: { response in
            if let err = response.error  {
                if let desc = err.errorDescription {
                    block(DataResult.Failure(error: DataError.NetworkError(desc)))
                } else {
                    block(DataResult.Failure(error: DataError.UnknownError("Unknow error")))
                }
                return
            }
            if let data = response.data {
                do {
                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                       print(string)
                    }
                    
                    let result: ResponseObject<U> = try JSONDecoder().decode(ResponseObject<U>.self, from: data)
                    if result.status != 200 {
                        block(DataResult.Failure(error: DataError.UnknownError(result.message ?? "Unknow error!")))
                    } else {
                        block(DataResult.Success(result: result))
                    }
                } catch  {
                    do {
                           let result: ResponseObject<BlankResult> = try JSONDecoder().decode(ResponseObject<BlankResult>.self, from: data)
                           if result.status != 200 {
                               block(DataResult.Failure(error: DataError.UnknownError(result.message ?? "Unknow error!")))
                           } else {
                               block(DataResult.Failure(error: DataError.UnknownError("Response is not in expected format")))
                           }
                       } catch  {
                           block(DataResult.Failure(error: DataError.ParsingRequest("Unable to parse.")))
                       }
                }
            }
        })
        .uploadProgress(closure: { progress in
            progressBlock?(progress.fractionCompleted)
        })
    }
    
    func cancelRequest() {
        AF.cancelAllRequests()
    }
}

extension NetworkManager {
    
    fileprivate func validateJsonWithBlankStructure<U>(ForData data:Data, block: @escaping DataCompletionHandler<U> ) {
        do {
            let result: ResponseObject<BlankResult> = try JSONDecoder().decode(ResponseObject<BlankResult>.self, from: data)
            if result.status != 200 {
                block(DataResult.Failure(error: DataError.UnknownError(result.message ?? "Unknow error!")))
            } else {
                block(DataResult.Failure(error: DataError.UnknownError("Response is not in expected format")))
            }
            
        } catch  {
            block(DataResult.Failure(error: DataError.ParsingRequest("Unable to parse.")))
        }
    }
}
