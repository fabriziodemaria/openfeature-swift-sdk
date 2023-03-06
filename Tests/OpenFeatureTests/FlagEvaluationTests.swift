import Foundation
import XCTest

@testable import OpenFeature

final class FlagEvaluationTests: XCTestCase {
    func testSingletonPersists() {
        XCTAssertTrue(OpenFeatureAPI.shared === OpenFeatureAPI.shared)
    }

    func testApiSetsProvider() {
        let provider = NoOpProvider()
        OpenFeatureAPI.shared.provider = provider

        XCTAssertTrue((OpenFeatureAPI.shared.provider as? NoOpProvider) === provider)
    }

    func testProviderMetadata() {
        OpenFeatureAPI.shared.provider = DoSomethingProvider()

        XCTAssertEqual(OpenFeatureAPI.shared.getProviderMetadata()?.name, DoSomethingProvider.name)
    }

    func testHooksPersist() {
        let hook1: AnyHook = .boolean(BooleanHookMock())
        let hook2: AnyHook = .boolean(BooleanHookMock())

        OpenFeatureAPI.shared.addHooks(hooks: hook1)

        XCTAssertEqual(OpenFeatureAPI.shared.hooks.count, 1)

        OpenFeatureAPI.shared.addHooks(hooks: hook2)
        XCTAssertEqual(OpenFeatureAPI.shared.hooks.count, 2)
    }

    func testNamedClient() {
        let client = OpenFeatureAPI.shared.getClient(name: "test", version: nil)
        XCTAssertEqual((client as? OpenFeatureClient)?.name, "test")
    }

    func testClientHooksPersist() {
        let hook1: AnyHook = .boolean(BooleanHookMock())
        let hook2: AnyHook = .boolean(BooleanHookMock())

        let client = OpenFeatureAPI.shared.getClient()
        client.addHooks(hook1)

        XCTAssertEqual(client.hooks.count, 1)

        client.addHooks(hook2)
        XCTAssertEqual(client.hooks.count, 2)
    }

    func testSimpleFlagEvaluation() {
        OpenFeatureAPI.shared.provider = DoSomethingProvider()
        let client = OpenFeatureAPI.shared.getClient()
        let key = "key"

        XCTAssertEqual(client.getBooleanValue(key: key, defaultValue: false), true)
        XCTAssertEqual(client.getBooleanValue(key: key, defaultValue: false, ctx: MutableContext()), true)
        XCTAssertEqual(
            client.getBooleanValue(
                key: key, defaultValue: false, ctx: MutableContext(), options: FlagEvaluationOptions()), true)

        XCTAssertEqual(client.getStringValue(key: key, defaultValue: "test"), "tset")
        XCTAssertEqual(client.getStringValue(key: key, defaultValue: "test", ctx: MutableContext()), "tset")
        XCTAssertEqual(
            client.getStringValue(
                key: key, defaultValue: "test", ctx: MutableContext(), options: FlagEvaluationOptions()), "tset")

        XCTAssertEqual(client.getIntegerValue(key: key, defaultValue: 4), 400)
        XCTAssertEqual(client.getIntegerValue(key: key, defaultValue: 4, ctx: MutableContext()), 400)
        XCTAssertEqual(
            client.getIntegerValue(key: key, defaultValue: 4, ctx: MutableContext(), options: FlagEvaluationOptions()),
            400)

        XCTAssertEqual(client.getDoubleValue(key: key, defaultValue: 0.4), 40.0)
        XCTAssertEqual(client.getDoubleValue(key: key, defaultValue: 0.4, ctx: MutableContext()), 40.0)
        XCTAssertEqual(
            client.getDoubleValue(key: key, defaultValue: 0.4, ctx: MutableContext(), options: FlagEvaluationOptions()),
            40.0)

        XCTAssertEqual(client.getObjectValue(key: key, defaultValue: .structure([:])), .null)
        XCTAssertEqual(client.getObjectValue(key: key, defaultValue: .structure([:]), ctx: MutableContext()), .null)
        XCTAssertEqual(
            client.getObjectValue(
                key: key, defaultValue: .structure([:]), ctx: MutableContext(), options: FlagEvaluationOptions()), .null
        )
    }

    func testDetailedFlagEvaluation() {
        OpenFeatureAPI.shared.provider = DoSomethingProvider()
        let client = OpenFeatureAPI.shared.getClient()
        let key = "key"

        let booleanDetails = FlagEvaluationDetails(flagKey: key, value: true, variant: nil)
        XCTAssertEqual(client.getBooleanDetails(key: key, defaultValue: false), booleanDetails)
        XCTAssertEqual(client.getBooleanDetails(key: key, defaultValue: false, ctx: MutableContext()), booleanDetails)
        XCTAssertEqual(
            client.getBooleanDetails(
                key: key, defaultValue: false, ctx: MutableContext(), options: FlagEvaluationOptions()), booleanDetails)

        let stringDetails = FlagEvaluationDetails(flagKey: key, value: "tset", variant: nil)
        XCTAssertEqual(client.getStringDetails(key: key, defaultValue: "test"), stringDetails)
        XCTAssertEqual(client.getStringDetails(key: key, defaultValue: "test", ctx: MutableContext()), stringDetails)
        XCTAssertEqual(
            client.getStringDetails(
                key: key, defaultValue: "test", ctx: MutableContext(), options: FlagEvaluationOptions()), stringDetails)

        let integerDetails = FlagEvaluationDetails(flagKey: key, value: Int64(400), variant: nil)
        XCTAssertEqual(client.getIntegerDetails(key: key, defaultValue: 4), integerDetails)
        XCTAssertEqual(client.getIntegerDetails(key: key, defaultValue: 4, ctx: MutableContext()), integerDetails)
        XCTAssertEqual(
            client.getIntegerDetails(
                key: key, defaultValue: 4, ctx: MutableContext(), options: FlagEvaluationOptions()), integerDetails)

        let doubleDetails = FlagEvaluationDetails(flagKey: key, value: 40.0, variant: nil)
        XCTAssertEqual(client.getDoubleDetails(key: key, defaultValue: 0.4), doubleDetails)
        XCTAssertEqual(client.getDoubleDetails(key: key, defaultValue: 0.4, ctx: MutableContext()), doubleDetails)
        XCTAssertEqual(
            client.getDoubleDetails(
                key: key, defaultValue: 0.4, ctx: MutableContext(), options: FlagEvaluationOptions()), doubleDetails)

        let objectDetails = FlagEvaluationDetails(flagKey: key, value: Value.null, variant: nil)
        XCTAssertEqual(client.getObjectDetails(key: key, defaultValue: .structure([:])), objectDetails)
        XCTAssertEqual(
            client.getObjectDetails(key: key, defaultValue: .structure([:]), ctx: MutableContext()), objectDetails)
        XCTAssertEqual(
            client.getObjectDetails(
                key: key, defaultValue: .structure([:]), ctx: MutableContext(), options: FlagEvaluationOptions()),
            objectDetails)
    }

    func testHooksAreFired() {
        OpenFeatureAPI.shared.provider = NoOpProvider()
        let client = OpenFeatureAPI.shared.getClient()

        let clientHook = BooleanHookMock()
        let invocationHook = BooleanHookMock()

        client.addHooks(.boolean(clientHook))
        _ = client.getBooleanValue(
            key: "key",
            defaultValue: false,
            ctx: MutableContext(),
            options: FlagEvaluationOptions(hooks: [.boolean(invocationHook)]))

        XCTAssertEqual(clientHook.beforeCalled, 1)
        XCTAssertEqual(invocationHook.beforeCalled, 1)
    }

    func testBrokenProvider() {
        OpenFeatureAPI.shared.provider = AlwaysBrokenProvider()
        let client = OpenFeatureAPI.shared.getClient()

        XCTAssertFalse(client.getBooleanValue(key: "testkey", defaultValue: false))
        let details = client.getBooleanDetails(key: "testkey", defaultValue: false)

        XCTAssertEqual(details.errorCode, .flagNotFound)
        XCTAssertEqual(details.reason, Reason.error.rawValue)
        XCTAssertEqual(details.errorMessage, "Could not find flag for key: testkey")
    }

    func testClientMetadata() {
        let client1 = OpenFeatureAPI.shared.getClient()
        XCTAssertNil(client1.metadata.name)

        let client = OpenFeatureAPI.shared.getClient(name: "test", version: nil)
        XCTAssertEqual(client.metadata.name, "test")
    }

    func testMultilayerContextMergesCorrectly() {
        let provider = DoSomethingProvider()
        OpenFeatureAPI.shared.provider = provider

        let apiCtx = MutableContext()
        apiCtx.add(key: "common", value: .string("1"))
        apiCtx.add(key: "common2", value: .string("1"))
        apiCtx.add(key: "api", value: .string("2"))
        OpenFeatureAPI.shared.evaluationContext = apiCtx

        var client = OpenFeatureAPI.shared.getClient()
        let clientCtx = MutableContext()
        clientCtx.add(key: "common", value: .string("3"))
        clientCtx.add(key: "common2", value: .string("3"))
        clientCtx.add(key: "client", value: .string("4"))
        client.evaluationContext = clientCtx

        let invocationCtx = MutableContext()
        invocationCtx.add(key: "common", value: .string("5"))
        invocationCtx.add(key: "invocation", value: .string("6"))

        _ = client.getBooleanValue(key: "key", defaultValue: false, ctx: invocationCtx)

        let merged = provider.mergedContext
        XCTAssertEqual(merged?.getValue(key: "invocation")?.asString(), "6")
        XCTAssertEqual(merged?.getValue(key: "common")?.asString(), "5")
        XCTAssertEqual(merged?.getValue(key: "client")?.asString(), "4")
        XCTAssertEqual(merged?.getValue(key: "common2")?.asString(), "3")
        XCTAssertEqual(merged?.getValue(key: "api")?.asString(), "2")
    }
}