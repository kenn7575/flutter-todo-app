import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import material for IconData
import 'database_helper.dart';
import 'todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late DatabaseHelper _dbHelper;
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final todoList = await _dbHelper.getTodos();
    setState(() {
      _todos = todoList.map((item) => Todo.fromMap(item)).toList();
    });
  }

  Future<void> _addTodo() async {
    final newTodo = Todo(
      title: 'New Todo',
    );
    await _dbHelper.insertTodo(newTodo.toMap());

    _fetchTodos(); // Refresh the list after adding
  }

  Future<void> _updateTodo(Todo todo) async {
    final updatedTodo = todo;
    await _dbHelper.updateTodo(updatedTodo);

    _fetchTodos(); // Refresh the list after updating
  }

  Future<void> _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _fetchTodos(); // Refresh the list after deleting
  }

  void _editTodoDialog(Todo todo) {
    TextEditingController _controller = TextEditingController(text: todo.title);

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Edit Todo"),
          content: CupertinoTextField(
            controller: _controller,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  todo.title = _controller.text;
                });
                _updateTodo(todo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemIndigo,
        middle: const Text('Todo List'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addTodo,
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return Dismissible(
              key: Key(todo.id.toString()),
              background: slideLeftBackground(),
              secondaryBackground: slideRightBackground(),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  // Left to right swipe - Edit
                  _editTodoDialog(todo);
                  return false; // Don't dismiss the item after edit
                } else {
                  // Right to left swipe - Delete
                  _deleteTodo(todo.id!);
                  return true;
                }
              },
              child: CupertinoListTile(
                title: Text(todo.title),
                trailing: CupertinoSwitch(
                  value: todo.isDone,
                  onChanged: (bool value) {
                    setState(() {
                      todo.isDone = value;
                    });
                    _updateTodo(todo);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: CupertinoColors.systemRed,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            CupertinoIcons.delete_solid,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: CupertinoColors.activeBlue,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            CupertinoIcons.pencil,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;

  const CupertinoListTile({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: CupertinoColors.secondarySystemFill,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
