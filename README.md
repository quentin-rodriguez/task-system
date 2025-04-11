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

## 📋


## ✅ TODO list

- [x] Implement a GenServer-based worker (TaskWorker) 
- [x] Implement a supervisor (TaskSupervisor) 
- [x] Implement a public API module (TaskManager)
- [x] Implement a persistent task queue
- [x] Provide a Dockerfile and deployment instructions
- [x] Provide tests covering 
- [x] Include documentation
- [x] Implement a simple Web API  

## 💻 Local development

1. Clone the repository

```bash
git clone https://github.com/quentin-rodriguez/task-system.git
cd task-system
```

2. Change Version for elixir and erlang

If possible, use the versions specified in the `.tool-versions` file with a tool such as [mise](https://github.com/jdx/mise) or [asdf](https://github.com/asdf-vm/asdf).

```bash
mise install
# or
asdf install
```

3. Install dependencies

```bash
mix deps.get
```

4. Start the application

```bash
iex -S mix
```

5. (Optional) Use web API

`curl` requests can be used to communicate with the API

Create a new task
```bash
curl -X POST http://localhost:4000/tasks -d '{"name": "Jean", "number": "42"}'
```

Get a list of running tasks
```bash
curl -X GET http://localhost:4000/tasks
```

Stop a running task
```bash
curl -X DELETE http://localhost:4000/tasks/:id
```

## 📥 Production deployment

1. Install [Fly CLI](https://fly.io/docs/flyctl/install/)
```bash
curl -L https://fly.io/install.sh | sh
```

2. Login with [Fly CLI](https://fly.io/docs/flyctl/install/)
```bash
fly auth login
```

3. Initialize the application
```bash
fly launch
```

4. Deploy the application
```bash
fly deploy
```