## Client performance measurement SDK

Allows you to collect different client metrics during test run and push them to Loki. Anything can be measured - either it unit, integration or e2e test.

Usage:
- `import ProtonCoreTestingToolkitPerformance`

In order to use the library you have to set up the following environment variables either on CI or locally or set in info.plist or in test configuration file:
1. `LOKI_ENDPOINT` - loki endpoint accessible outside of Dev VPN.
2. `CERTIFICATE_IOS_SDK_PASSPHRASE` - loki private key issues for your team.
3. `CERTIFICATE_IOS_SDK` - loki certificate issues for your team.

The main SDK building blocks are:
- [MeasurementContext](MeasurementContext.swift) - the main measurement entry point which allows you to set [MeasurementConfig](MeasurementConfig.swift) and initialises [MeasurementProfile](MeasurementProfile.swift) after setting the workflow. There can be only one instance of [MeasurementContext](MeasurementContext.swift) per the whole test run.
- [MeasurementProfile](MeasurementProfile.swift) - represents a shared set of labels, metadata and metrics which can be measured during the test run. There can be multiple profiles per test run. Each profile can be extended with [CustomMeasurement](measurement/CustomMeasurement.swift) hooks to register your own measurement per [MeasureBlock](MeasureBlock.swift). [MeasurementProfile](MeasurementProfile.swift) keeps a list of measure blocks in order to push their metrics to Loki after each test run.
- [MeasureBlock](MeasureBlock.swift) - represents a single measure block where logs and majority of metrics will be collected. It has `addMetric()` interface to add custom metrics by implementing [CustomMeasurement](measurement/CustomMeasurement.swift).
- [MeasurementConfig](MeasurementConfig.swift) - keeps configuration values to configure [LokiApiClient](client/LokiApiClient.swift) as well as setters and getters for `buildCommitShortSha` (GitLab "CI_COMMIT_SHA"), `environment` (test environment name) and `runId` (GitLab "CI_JOB_ID").
- [Measurement](measurement/Measurement.swift) - allows to register your own custom measurement. See usage example in class. Examples of [Measurement](measurement/Measurement.swift) are: [AppSizeMeasurement](measurement/AppSizeMeasurement.swift), [DurationMeasurement](measurement/DurationMeasurement.swift), [CPUMeasurement](measurement/CPUMeasurement.swift), and [MemoryMeasurement](measurement/MemoryMeasurement.swift).

Usage examples:

1. First you need to set the configuration in base test class or in `setUp` function:
```swift

class MainMeasurementTests: ProtonCoreBaseTestCase {

    private lazy var measurementContext: MeasurementContext = {
        do {
            let config = try MeasurementConfigBuilder()
                .bundle(Bundle(identifier: "ch.protonmail.configurator.ios")!)
                .lokiEndpoint(ProcessInfo.processInfo.environment["LOKI_ENDPOINT"] ?? "")
                .environment("production")
                .certificate("certificate_ios_sdk")
                .certificatePassphrase(ProcessInfo.processInfo.environment["CERTIFICATE_IOS_SDK_PASSPHRASE"] ?? "")
                .build()
            return MeasurementContext(config)
        } catch {
            fatalError("Failed to configure measurement context: \(error)")
        }
    }()
    
    override class func setUp() {
        super.setUp()
        // Configuration is now handled in the lazy property above
    }
 
    func testMeasurement1() async {
        let measurementProfile = measurementContext.setWorkflow("test_iOS", forTest: self.name)

        measurementProfile
            .addMeasurement(DurationMeasurement())
            .setServiceLevelIndicator("measurement_1")

        // Measure the duration
        measurementProfile.measure {
            // Your actual test code here
            sleep(1)
        }
        
        // Clean up after test
        measurementContext.cleanup(forTest: self.name)
    }

    func testMeasurement2() async {
        let measurementProfile = measurementContext.setWorkflow("test_iOS", forTest: self.name)

        measurementProfile
            .addMeasurement(AppSizeMeasurement(bundle: Bundle(identifier: "ch.protonmail.configurator.ios")!))
            .setServiceLevelIndicator("measurement_2")

        // Measure the app size
        measurementProfile.measure {
            // Your actual test code here
            sleep(1)
        }
        
        measurementContext.cleanup(forTest: self.name)
    }

    func testMeasurement3() async {
        let measurementProfile = measurementContext.setWorkflow("test_iOS", forTest: self.name)

        measurementProfile
            .addMeasurement(DurationMeasurement())
            .setServiceLevelIndicator("measurement_3")

        // Measure the duration
        measurementProfile.measure {
            // Your actual test code here
            sleep(1)
        }
        
        measurementContext.cleanup(forTest: self.name)
    }
```

    JSON payload example for 1 measurement:

```json
    {
        "streams":[
            {
                "stream":{
                    "product":"ch.protonmail.configurator.ios",
                    "sli":"measurement_2",
                    "platform":"iOS",
                    "workflow":"test_iOS",
                    "os_version":"iOS 17.4",
                    "device_model":"iPhone"
                },
                "values":[
                    [
                    "1719402402446641920",
                    "{\"app_size\":\"33.83\",\"status\":\"succeeded\"}",
                    {
                        "ci_job_id":"",
                        "id":"BEAF246F-EC37-4BAB-AAB8-919AB1E7D7F4",
                        "test":"MainMeasurementTests_testMeasurement2",
                        "build_commit_sha1":"",
                        "environment":"production",
                        "app_version":"1.0"
                    }
                    ]
                ]
            }
        ]
    }
```

## XCTMetric Integration (iOS 14.0+, macOS 11.0+)

The Performance SDK now supports XCTest's native performance measurement API:

```swift
@available(iOS 14.0, macOS 11.0, *)
func testLoginPerformance() {
    let profile = measurementContext.setWorkflow("login_iOS", forTest: self.name)
    profile.addMeasurement(DurationMeasurement())
    profile.setServiceLevelIndicator("login_duration")
    
    // Create XCTMetric that forwards to Loki
    let xctMetric = profile.asXCTMetric(named: "login_perf")
    
    // Use XCTest's built-in performance measurement
    measure(metrics: [xctMetric]) {
        // Your test code here
        // Simulate login work
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    measurementContext.cleanup(forTest: self.name)
}
```

**Benefits of XCTMetric integration:**
- Multiple iterations with statistical analysis
- Integration with Xcode's performance reporting
- Automatic `xct_metric`, `xct_status`, and `xct_iteration` labels in Loki
- Standardized performance measurement workflow

**Convenience method:**
```swift
let (profile, metric) = measurementContext.createXCTMetricProfile(
    workflow: "user_registration",
    forTest: self.name,
    metricName: "registration_perf",
    measurements: [DurationMeasurement()],
    sli: "registration_duration"
)

measure(metrics: [metric]) {
    // Simulate user registration work
    Thread.sleep(forTimeInterval: 0.2)
}
```

See [XCTMetric Integration Guide](XCTMetric-Integration-Guide.md) for complete documentation.

## Testing with Mock Client

For unit testing or when you don't have access to a Loki endpoint:

```swift
let mockClient = MockLokiClient()
let measurementContext = MeasurementContext(MeasurementConfig.self, lokiClient: mockClient)

// Your test code here

// Verify metrics were captured
XCTAssertEqual(mockClient.pushCallCount, 1)
XCTAssertNotNil(mockClient.lastEntry)
```

## Troubleshooting

### Common Issues

1. **Configuration Errors**: Use `MeasurementConfig.validate()` to check your configuration before creating a context.

2. **Certificate Issues**: Ensure your `.p12` certificate file is included in your test bundle and the passphrase is correct.

3. **Network Errors**: Check that your Loki endpoint is accessible and accepts the certificate.

4. **Memory Issues**: Use `cleanup(forTest:)` after each test to prevent memory leaks in large test suites.

## Recommended Approach: Hybrid Performance Monitoring

**BEST PRACTICE**: Use a hybrid approach combining custom measurements for Loki dashboards and Apple's official XCTest metrics for detailed system analysis.

### Available Custom Measurements

The SDK provides hardened, production-ready custom measurements:

- **✅ `CPUMeasurement`**: Platform-independent CPU usage measurement with overflow protection
- **✅ `MemoryMeasurement`**: Robust memory usage tracking with error handling
- **✅ `DurationMeasurement`**: Precise timing measurements
- **✅ `AppSizeMeasurement`**: Application bundle size tracking

### Why Use the Hybrid Approach?

- **✅ Custom Measurements → Loki**: Reliable system metrics visible in Grafana dashboards
- **✅ Apple's Metrics → Instruments**: Official Apple metrics for detailed system analysis  
- **✅ Production-Ready**: Hardened implementations with proper error handling
- **✅ Platform-Independent**: Works across different iOS/macOS versions
- **✅ Overflow Protection**: Safe calculations for long-running processes

### Complete Example with Hybrid Approach

```swift
func testPerformanceWithHybridApproach() {
    // Custom system metrics → Loki dashboard (visible in Grafana)
    let profile = measurementContext.setWorkflow("comprehensive_test", forTest: self.name)
    profile.addMeasurement(DurationMeasurement())                              // Duration → Loki
    profile.addMeasurement(CPUMeasurement(useHighResolutionTiming: false))     // CPU data → Loki
    profile.addMeasurement(MemoryMeasurement())                                // Memory data → Loki
    profile.addMeasurement(AppSizeMeasurement(bundle: Bundle.main))            // App size → Loki
    profile.setServiceLevelIndicator("comprehensive_performance")
    
    let xctMetric = profile.asXCTMetric(named: "hybrid_perf")
    
    // Use Apple's official metrics alongside your custom Loki metrics
    measure(metrics: [
        xctMetric,                      // Custom metrics (CPU, Memory, Duration) → Loki
        XCTClockMetric(),               // Wall clock time → Instruments
        XCTCPUMetric(),                 // CPU usage → Instruments
        XCTMemoryMetric(),              // Memory usage → Instruments
        XCTStorageMetric(),             // Disk I/O → Instruments
        XCTApplicationLaunchMetric(),   // App launch performance → Instruments
        XCTOSSignpostMetric()           // Custom signposts → Instruments
    ]) {
        // Your test code - measured by ALL metrics
        // Your actual test operation here
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    // Results go to both Loki (custom metrics) and Xcode Instruments (Apple metrics)!
}
```

### Available Apple's Official XCTest Metrics

| Metric | Description | Use Case |
|--------|-------------|----------|
| **`XCTClockMetric()`** | Wall clock time measurement | General timing |
| **`XCTCPUMetric()`** | CPU usage during test execution | Performance bottlenecks |
| **`XCTMemoryMetric()`** | Memory usage and allocation patterns | Memory leaks, optimization |
| **`XCTStorageMetric()`** | Disk I/O operations | File system performance |
| **`XCTApplicationLaunchMetric()`** | App launch performance | Startup optimization |
| **`XCTOSSignpostMetric()`** | Custom signpost intervals | Custom performance markers |
| **`XCTHitchMetric()`** | UI responsiveness (iOS 15+) | Scroll/animation smoothness |

### When to Use Each Approach

| Approach | Use Case | Data Destination |
|----------|----------|------------------|
| **Loki Only** | Business metrics, custom SLIs, CI/CD dashboards | Loki → Grafana |
| **Apple Only** | System performance, Xcode debugging, local analysis | Xcode Instruments |
| **Apple + Loki (Recommended)** | Comprehensive monitoring, production insights + debugging | Both Loki + Instruments |

### Enhanced Custom Measurements

The current implementation provides **hardened, production-ready custom measurements** with significant improvements:

```swift
// ✅ Current approach (Hardened custom measurements + Apple's official metrics)
let profile = measurementContext.setWorkflow("test", forTest: self.name)
profile.addMeasurement(DurationMeasurement())                              // Precise timing → Loki
profile.addMeasurement(CPUMeasurement(useHighResolutionTiming: true))      // Platform-independent CPU → Loki
profile.addMeasurement(MemoryMeasurement())                                // Robust memory tracking → Loki
profile.addMeasurement(AppSizeMeasurement(bundle: Bundle.main))            // App size → Loki
profile.setServiceLevelIndicator("test_sli")

let xctMetric = profile.asXCTMetric(named: "perf")

measure(metrics: [
    xctMetric,         // Hardened custom metrics (CPU, Memory, Duration) → Loki/Grafana
    XCTCPUMetric(),    // Apple's CPU analysis → Instruments  
    XCTMemoryMetric()  // Apple's memory analysis → Instruments
]) {
    // Your test code
}
```

### Key Improvements in Custom Measurements

- **🛡️ Platform-Independent**: No magic constants, works across iOS/macOS versions
- **🛡️ Overflow Protection**: Safe calculations for long-running processes  
- **🛡️ Error Handling**: Proper logging and graceful failure handling
- **🛡️ High-Resolution Timing**: Optional nanosecond-precision timing with `mach_absolute_time()`
- **🛡️ Memory Safety**: Prevents crashes from sandbox restrictions or API failures

### Best Practices

- **Always set a Service Level Indicator** before measuring
- **Use meaningful workflow and SLI names** for easier analysis
- **Clean up profiles after tests** to prevent memory issues (not needed with XCTMetric integration)
- **Use the builder pattern** for cleaner configuration
- **Consider using MockLokiClient** for unit tests
- **Use hybrid approach** for comprehensive performance monitoring
- **Combine multiple Apple metrics** to get complete system resource picture
