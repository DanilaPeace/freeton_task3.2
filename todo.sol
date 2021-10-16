pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract todo {

    struct Task {
        string taskName;
        uint32 time;
        bool isDid;
    }

    mapping(int8 => Task) public toDoList;
    int8 taskCount = 0;
    int8 openTaskCount;

    constructor() public{
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
    }

    modifier modifyTasks() {
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
        _;
    }

    function addTask(string taskName) public modifyTasks {
        taskCount++;
        openTaskCount++;
        uint32 taskTime = now;
        // Create new task
        toDoList.getSet(taskCount, Task(taskName, taskTime, false));   
    }

    function getOpenTasksAmount() public returns(int8) {
        return openTaskCount;
    }

    function getToDoList() public returns(mapping (int8=>Task)){
        return toDoList;
    }

    function taskInfo(int8 taskKey) public returns(Task){
        require(toDoList.exists(taskKey), 103, "There is no task with this key!");
        return toDoList[taskKey];
    }

    function removeTask(int8 taskKey) public modifyTasks {
        require(toDoList.exists(taskKey), 103, "There is no task with this key!");
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

    function markAsDid(int8 taskKey) public modifyTasks {
        require(toDoList.exists(taskKey), 103, "There is no task with this key!");
        toDoList[taskKey].isDid = true;
        openTaskCount--;
    }
}
