pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Todo {
    struct Task {
        string taskName;
        uint32 time;
        bool isDid;
    }

    mapping(int8 => Task) public toDoList;
    int8 taskCount = 0;
    int8 openTaskCount;
    
    modifier onlyOwner() {
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
        _;
    }

    modifier taskExistenceChecking(int8 taskKey) {
        require(toDoList.exists(taskKey), 103, "There is no task with this key!");
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
        toDoList.getSet(taskCount, Task(taskName, taskTime, false));   
    }

    function getOpenTasksAmount() public returns(int8) {
        return openTaskCount;
    }

    function getToDoList() public returns(string[]){
        string[] taskList;
        for((int8 key, Task task) : toDoList) {
            taskList.push(format("{}. {}.", key, task.taskName));               
        }

        return taskList;
    }

    function taskInfo(int8 taskKey) public view taskExistenceChecking(taskKey) returns(Task){
        return toDoList[taskKey];
    }

    function removeTask(int8 taskKey) public onlyOwner taskExistenceChecking(taskKey){
        delete toDoList[taskKey];

        // Change the toDoList: all tasks are shifted to one element
        mapping(int8 => Task) newToDoList;

        int8 newTaskCounter = 1; 
        for((int8 key, Task task) : toDoList) {
            newToDoList[newTaskCounter++] = task;
        }
        toDoList = newToDoList;
        taskCount--;
        openTaskCount--;
    }

    function markAsDid(int8 taskKey) public onlyOwner taskExistenceChecking(taskKey){
        require(!toDoList[taskKey].isDid, 104, "This task is already completed!");
        toDoList[taskKey].isDid = true;
        openTaskCount--;
    }
}
