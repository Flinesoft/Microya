<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/Microya/main/Logo.png"
      width=396>
</p>

<p align="center">
    <a href="https://github.com/Flinesoft/Microya/actions?query=workflow%3ACI+branch%3Amain">
        <img src="https://github.com/Flinesoft/Microya/workflows/CI/badge.svg?branch=main"
             alt="CI Status">
    </a>    
    <a href="https://codebeat.co/projects/github-com-flinesoft-microya-main">
        <img src="https://codebeat.co/badges/a669e100-d30d-4801-b72d-3625ab7240be"
             alt="codebeat badge">
    </a>
    <a href="https://github.com/Flinesoft/HandySwift/releases">
    <img src="https://img.shields.io/badge/Version-0.4.0-blue.svg"
         alt="Version: 0.4.0">
    <img src="https://img.shields.io/badge/Swift-5.3-FFAC45.svg"
         alt="Swift: 5.3">
    <img src="https://img.shields.io/badge/Platforms-Apple%20%7C%20Linux-FF69B4.svg"
        alt="Platforms: Apple | Linux">
    <a href="https://github.com/Flinesoft/Microya/blob/main/LICENSE.md">
        <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg"
              alt="License: MIT">
    </a>
    <br />
    <a href="https://paypal.me/Dschee/5EUR">
        <img src="https://img.shields.io/badge/PayPal-Donate-orange.svg"
             alt="PayPal: Donate">
    </a>
    <a href="https://github.com/sponsors/Jeehut">
        <img src="https://img.shields.io/badge/GitHub-Become a sponsor-orange.svg"
             alt="GitHub: Become a sponsor">
    </a>
    <a href="https://patreon.com/Jeehut">
        <img src="https://img.shields.io/badge/Patreon-Become a patron-orange.svg"
             alt="Patreon: Become a patron">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#donation">Donation</a>
  • <a href="https://github.com/Flinesoft/Microya/issues">Issues</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#license">License</a>
</p>

# Microya

A micro version of the [Moya](https://github.com/Moya/Moya) network abstraction layer written in Swift.

## Installation

Installation is only supported via [SwiftPM](https://github.com/apple/swift-package-manager).

## Usage

### Step 1: Defining your Endpoints
Create an Api `enum` with all supported endpoints as `cases` with the request parameters/data specified as parameters.

For example, when writing a client for the [Microsoft Translator API](https://docs.microsoft.com/en-us/azure/cognitive-services/translator/reference/v3-0-languages):

```Swift
enum MicrosoftTranslatorApi {
    case languages
    case translate(texts: [String], from: Language, to: [Language])
}
```

### Step 2: Making your Api `Endpoint` compliant

Add an extension for your Api `enum` that makes it `Endpoint` compliant, which means you need to add implementations for the following protocol:

```Swift
public protocol Endpoint {
    associatedtype ClientErrorType: Decodable
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    var baseUrl: URL { get }
    var headers: [String: String] { get }
    var subpath: String { get }
    var method: HttpMethod { get }
    var queryParameters: [String: QueryParameterValue] { get }
}
```

Use `switch` statements over `self` to differentiate between the cases (if needed) and to provide the appropriate data the protocol asks for (using [Value Bindings](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html#ID133)).

<details>
<summary>Toggle me to see an example</summary>

```Swift
extension MicrosoftTranslatorEndpoint: Endpoint {
    typealias ClientErrorType = EmptyResponseType

    var decoder: JSONDecoder {
        return JSONDecoder()
    }

    var encoder: JSONEncoder {
        return JSONEncoder()
    }

    var baseUrl: URL {
        return URL(string: "https://api.cognitive.microsofttranslator.com")!
    }

    var headers: [String: String] {
        switch self {
        case .languages:
            return [:]

        case .translate:
            return [
                "Ocp-Apim-Subscription-Key": "<SECRET>",
                "Content-Type": "application/json"
            ]
        }
    }

    var subpath: String {
        switch self {
        case .languages:
            return "/languages"

        case .translate:
            return "/translate"
        }
    }

    var method: HttpMethod {
        switch self {
        case .languages:
            return .get

        case let .translate(texts, _, _):
            return .post(try! encoder.encode(texts))
        }
    }

    var queryParameters: [String: QueryParameterValue] {
        var queryParameters: [String: QueryParameterValue] = ["api-version": "3.0"]

        switch self {
        case .languages:
            break

        case let .translate(_, sourceLanguage, targetLanguages, _):
            queryParameters["from"] = .string(sourceLanguage.rawValue)
            queryParameters["to"] = .array(targetLanguages.map { $0.rawValue })
        }

        return queryParameters
    }
}
```

</details>

### Step 3: Calling your API endpoint with the Result type

Call an API endpoint providing a `Decodable` type of the expected result (if any) by using one of the methods pre-implemented in the `ApiProvider` type:

```Swift
/// Performs the asynchornous request for the chosen endpoint and calls the completion closure with the result.
performRequest<ResultType: Decodable>(
    on endpoint: EndpointType,
    decodeBodyTo: ResultType.Type,
    completion: @escaping (Result<ResultType, ApiError<ClientErrorType>>) -> Void
)

/// Performs the request for the chosen endpoint synchronously (waits for the result) and returns the result.
public func performRequestAndWait<ResultType: Decodable>(
    on endpoint: EndpointType,
    decodeBodyTo bodyType: ResultType.Type
)
```

There's also extra methods for endpoints where you don't expect a response body:

```swift
/// Performs the asynchronous request for the chosen write-only endpoint and calls the completion closure with the result.
performRequest(on endpoint: EndpointType, completion: @escaping (Result<EmptyBodyResponse, ApiError<ClientErrorType>>) -> Void)

/// Performs the request for the chosen write-only endpoint synchronously (waits for the result).
performRequestAndWait(on endpoint: EndpointType) -> Result<EmptyBodyResponse, ApiError<ClientErrorType>>
```

The `EmptyBodyResponse` returned here is just an empty type, so you can just ignore it.

Here's a full example of a call you could make with Mircoya:

```Swift
let provider = ApiProvider<MicrosoftTranslatorEndpoint>()
let endpoint = MicrosoftTranslatorEndpoint.translate(texts: ["Test"], from: .english, to: [.german, .japanese, .turkish])

provider.performRequest(on: endpoint, decodeBodyTo: [String: String].self) { result in
    switch result {
    case let .success(translationsByLanguage):
        // use the already decoded `[String: String]` result

    case let .failure(apiError):
        // error handling
    }
}

// OR, if you prefer a synchronous call, use the `AndWait` variant

switch provider.performRequestAndWait(on: endpoint, decodeBodyTo: [String: String].self) {
case let .success(translationsByLanguage):
    // use the already decoded `[String: String]` result

case let .failure(apiError):
    // error handling
}
```

Note that you can also use the throwing `get()` function of Swift 5's `Result` type instead of using a `switch`:

```Swift
provider.performRequest(on: endpoint, decodeBodyTo: [String: String].self) { result in
    let translationsByLanguage = try result.get()
    // use the already decoded `[String: String]` result
}

// OR, if you prefer a synchronous call, use the `AndWait` variant

let translationsByLanguage = try provider.performRequestAndWait(on: endpoint, decodeBodyTo: [String: String].self).get()
// use the already decoded `[String: String]` result
```

There's even useful functional methods defined on the `Result` type like `map()`, `flatMap()` or `mapError()` and `flatMapError()`. See the "Transforming Result" section in [this](https://www.hackingwithswift.com/articles/161/how-to-use-result-in-swift) article for more information.

### Plugins

The initializer of `ApiProvider` accepts an array of `Plugin` objects. You can implement your own plugins or use one of the existing ones in the [Plugins](https://github.com/Flinesoft/Microya/tree/main/Sources/Microya/Plugins) directory. Here's are the callbacks a custom `Plugin` subclass can override:

```swift
/// Called to modify a request before sending.
modifyRequest(_ request: inout URLRequest, endpoint: EndpointType)

/// Called immediately before a request is sent.
willPerformRequest(_ request: URLRequest, endpoint: EndpointType)

/// Called after a response has been received & decoded, but before calling the completion handler.
didPerformRequest<ResultType: Decodable>(
    urlSessionResult: (data: Data?, response: URLResponse?, error: Error?),
    typedResult: Result<ResultType, ApiError<EndpointType.ClientErrorType>>,
    endpoint: EndpointType
)
```

<details>
<summary>Toggle me to see a full custom plugin example</summary>

Here's a possible implementation of a `RequestResponseLoggerPlugin` that logs using `print`:

```swift
class RequestResponseLoggerPlugin<EndpointType: Endpoint>: Plugin<EndpointType> {
    override func willPerformRequest(_ request: URLRequest, endpoint: EndpointType) {
        print("Endpoint: \(endpoint), Request: \(request)")
    }

    override func didPerformRequest<ResultType: Decodable>(
        urlSessionResult: ApiProvider<EndpointType>.URLSessionResult,
        typedResult: ApiProvider<EndpointType>.TypedResult<ResultType>,
        endpoint: EndpointType
    ) {
        print("Endpoint: \(endpoint), URLSession result: \(urlSessionResult), Typed result: \(typedResult)")
    }
}

```

</details>



### Shortcuts

`Endpoint` provides default implementations for most of its required methods, namely:

```swift
public var decoder: JSONDecoder { JSONDecoder() }

public var encoder: JSONEncoder { JSONEncoder() }

public var plugins: [Plugin<Self>] { [] }

public var headers: [String: String] {
    [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Accept-Language": Locale.current.languageCode ?? "en"
    ]
}

public var queryParameters: [String: QueryParameterValue] { [:] }
```

So technically, the `Endpoint` type only requires you to specify the following 4 things:

```swift
protocol Endpoint {
    associatedtype ClientErrorType: Decodable
    var baseUrl: URL { get }
    var subpath: String { get }
    var method: HttpMethod { get }
}
```

This can be a time (/ code) saver for simple APIs you want to access.
You can also use `EmptyBodyResponse` type for `ClientErrorType` to ignore the client error body structure.

## Donation

Microya was brought to you by [Cihat Gündüz](https://github.com/Jeehut) in his free time. If you want to thank me and support the development of this project, please **make a small donation on [PayPal](https://paypal.me/Dschee/5EUR)**. In case you also like my other [open source contributions](https://github.com/Flinesoft) and [articles](https://medium.com/@Jeehut), please consider motivating me by **becoming a sponsor on [GitHub](https://github.com/sponsors/Jeehut)** or a **patron on [Patreon](https://www.patreon.com/Jeehut)**.

Thank you very much for any donation, it really helps out a lot! 💯


## Contributing

See the file [CONTRIBUTING.md](https://github.com/Flinesoft/Microya/blob/main/CONTRIBUTING.md).


## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
