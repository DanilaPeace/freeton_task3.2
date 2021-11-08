pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Todo {
    struct Task {
        string taskName;
        uint32 time;
        bool isDone;
    }

    mapping(int8 => Task) public m_toDoList;
    int8 taskCount = 0;
    int8 openTaskCount;
    
    modifier onlyOwner() {
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
        _;
    }

    modifier taskExistenceChecking(int8 taskKey) {
        require(m_toDoList.exists(taskKey), 103, "There is no task with this key!");
        _;
    }

    constructor() public{
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
    }


    function addTask(string taskName) public onlyOwner {
        taskCount++;
        openTaskCount++;
        uint32 taskTime = now;
        // Create new task
        m_toDoList[taskCount] = Task(taskName, taskTime, false);
    }

    function getOpenTasksAmount() public returns(int8) {
        return openTaskCount;
    }

    function getToDoList() public returns(string[] taskList){
        for((int8 key, Task task) : m_toDoList) {
            taskList.push(format("{}. {}.", key, task.taskName));               
        }
    }

    function taskInfo(int8 taskKey) public view taskExistenceChecking(taskKey) returns(Task){
        return m_toDoList[taskKey];
    }

    function removeTask(int8 taskKey) public onlyOwner taskExistenceChecking(taskKey) returns(string){
        delete m_toDoList[taskKey];
        // Change the toDoList: all tasks are shifted to one element
        mapping(int8 => Task) newToDoList;

        int8 newTaskCounter = 0; 
        for((int8 key, Task task) : m_toDoList) {
            newTaskCounter++;
            newToDoList[newTaskCounter] = task;
        }
        m_toDoList = newToDoList;
        taskCount--;
        openTaskCount--;
    }

    function markAsDid(int8 taskKey) public onlyOwner taskExistenceChecking(taskKey){
        require(!m_toDoList[taskKey].isDone, 104, "This task is already completed!");
        m_toDoList[taskKey].isDone = true;
        openTaskCount--;
    }
}
