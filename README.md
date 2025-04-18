# TaskSystem - Worker system for processing tasks

![Elixir](https://img.shields.io/badge/1.18.3-535353?&logo=elixir&logoColor=white&label=Elixir&labelColor=%234B275F&style=flat-square)
![Erlang](https://img.shields.io/badge/27.2-535353?logo=erlang&logoColor=fff&label=Erlang&labelColor=A90533&style=flat-square)

This is an exercise in adding a task so that it can be processed asynchronously and stopped at any time by manual action.


## 🏬 Architecture

```mermaid
flowchart LR
    subgraph Web API
        TA[TaskApi] -- Request --> TM[TaskManager] 
    end
    
    TM -- add_task/1 --> TQ
    TM -- list_tasks/0 --> TST
    TM -- stop_task/1 --> TW

    subgraph Application
        TS[TaskSupervisor] -- Supervises --> TW[TaskWorker]
        TR[TaskWorkerRegistry] --> TW
        TQ[TaskQueue] -- Consume --> TW
        TW -- Log --> LOG@{ shape: lean-r, label: "task result" }
    end

    subgraph Storage
       DETS[DETS] --> TQ
       TST[(TaskStorage)] <-- Fetch / Insert / Delete --> TW
    end
```

## 📋 Technical choices

1. **Data Storage**
    - For persistence, I used a [DETS](https://www.erlang.org/doc/apps/stdlib/dets.html) because the data is saved directly to a file on disk, which can be retrieved later
    - To be able to retrieve the list of tasks currently being processed and to share the state of the various workers, I used an Agent, which has the advantage of being a wrapper for state management and sharing.

2. **Performance**
    - To manage an excess of tasks that could be sent all at once, I used the [:queue](https://www.erlang.org/doc/apps/stdlib/queue.html) module provided in Erlang, which is a FIFO queue system for queuing and redistributing in the same order the different data that need to be processed
    - For the workers, I used a system of consumers who come to look if there's a message to extract it from the queue and process it afterwards, which makes it possible to have a concurrent system for processing data more quickly.
    - To avoid duplicating processes in workers, I used the [Registry](https://hexdocs.pm/elixir/main/Registry.html) module, which provides a uniqueness constraint, as each registry entry is directly linked to its affiliated process.

3. **Web API**
    - To keep the API as simple as possible, I just used a `plug` and `bandit` as the HTTP server is the one used by default on the Phoenix framework, when generating a new project, but it would have been the same to use `plug_cowboy` (or "cowboy" for short).


## ✅ TODO

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

2. Change Version

Use the versions specified in the `.tool-versions` file with a tool such as [mise](https://github.com/jdx/mise) or [asdf](https://github.com/asdf-vm/asdf).

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

- Create a new task
```bash
curl -X POST http://localhost:4000/tasks -d '{"name": "Jean", "number": "42"}'
```

- Get a list of running tasks
```bash
curl -X GET http://localhost:4000/tasks
```

- Stop a running task
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