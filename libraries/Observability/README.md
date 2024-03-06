#  ProtonCore Observability

This framework adds in the capability to send reports to Prometheus.
Requests are sent through an unauthenticated session to the `/data/v1/metrics` endpoint.

## Dependency Graph

```mermaid
%% For now we can't use the elk renderer as it's not supported by the version of mermaid that Gitlab uses 🤷
flowchart BT

%% Networking
F --> NET[ProtonCore-Networking]
AF["AlamoFire"] --> NET
TR --> NET
TK[TrustKit] --> NET
LOG & U --> NET

%% Utilities
F --> U[ProtonCore-Utilties]
LOG ---> U

%% Log
F[" Foundation"] --> LOG[ProtonCore-Log] 

%% Translation
F --> TR[ProtonCore-CoreTranslation] 

NET --> OBS[ProtonCore-Observability]
FS & U --> OBS
```
