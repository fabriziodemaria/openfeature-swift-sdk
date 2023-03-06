import Foundation

@testable import OpenFeature

class AlwaysBrokenProvider: FeatureProvider {
    var metadata: Metadata = AlwaysBrokenMetadata()
    var hooks: [AnyHook] = []

    func getBooleanEvaluation(key: String, defaultValue: Bool, ctx: OpenFeature.EvaluationContext) throws
        -> OpenFeature.ProviderEvaluation<Bool>
    {
        throw OpenFeatureError.flagNotFoundError(key: key)
    }

    func getStringEvaluation(key: String, defaultValue: String, ctx: OpenFeature.EvaluationContext) throws
        -> OpenFeature.ProviderEvaluation<String>
    {
        throw OpenFeatureError.flagNotFoundError(key: key)
    }

    func getIntegerEvaluation(key: String, defaultValue: Int64, ctx: OpenFeature.EvaluationContext) throws
        -> OpenFeature.ProviderEvaluation<Int64>
    {
        throw OpenFeatureError.flagNotFoundError(key: key)
    }

    func getDoubleEvaluation(key: String, defaultValue: Double, ctx: OpenFeature.EvaluationContext) throws
        -> OpenFeature.ProviderEvaluation<Double>
    {
        throw OpenFeatureError.flagNotFoundError(key: key)
    }

    func getObjectEvaluation(key: String, defaultValue: OpenFeature.Value, ctx: OpenFeature.EvaluationContext) throws
        -> OpenFeature.ProviderEvaluation<OpenFeature.Value>
    {
        throw OpenFeatureError.flagNotFoundError(key: key)
    }
}

extension AlwaysBrokenProvider {
    struct AlwaysBrokenMetadata: Metadata {
        var name: String? = "test"
    }
}