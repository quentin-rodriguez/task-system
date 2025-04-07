# TaskSystem

![Elixir](https://img.shields.io/badge/1.18.0-535353?&logo=elixir&logoColor=white&label=Elixir&labelColor=%234B275F&style=flat-square)
![Erlang](https://img.shields.io/badge/27.2-535353?logo=erlang&logoColor=fff&label=Erlang&labelColor=A90533&style=flat-square)

## 🏬 Architecture

```mermaid
flowchart LR
    TWS[TaskWorkerSupervisor] -- Supervises --> TW[TaskWorker]
    TR[TaskWorkerRegistry] --> TW
    TST[(TaskStorage)] <-- Persist --> TD{TaskDispatcher} 
    TD -- Send --> TS[TaskSupervisor]
    TS -- Process --> TW
    TW --> LOG@{ shape: lean-r, label: "Log task result" }
```

