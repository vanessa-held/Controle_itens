import 'package:flutter/material.dart';
import 'package:controle_itens/helpers/snackbar_helper.dart';
import 'package:controle_itens/models/stuff_model.dart';
import 'package:controle_itens/pages/detail_page.dart';
import 'package:controle_itens/widgets/stuff_card.dart';
import '../controllers/home_controller.dart';
import '../core/app_const.dart';
import '../models/stuff_model.dart';
import '../repositories/stuff_repository_impl.dart';
import '../widgets/stuff_listview.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController(StuffRepositoryImpl());

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future _initialize() async {
    await _controller.readAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kTitleHome)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _onCreate,
      ),
      body: RefreshIndicator(
        onRefresh: _initialize,
        child: StuffListView(
          loading: _controller.loading,
          itemCount: _controller.length,
          itemBuilder: _buildStuffCard,
        ),
      ),
    );
  }

  Widget _buildStuffCard(BuildContext context, int index) {
    final stuff = _controller.stuffs[index];
    return StuffCard(
      stuff: stuff,
      onUpdate: () => _onUpdate(stuff),
      onDelete: () => _onDelete(stuff),
    );
  }

  _onCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DetailPage()),
    );
    _initialize();
  }

  _onUpdate(StuffModel stuff) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DetailPage(stuff: stuff)),
    );
    _initialize();
  }

  _onDelete(StuffModel stuff) async {
    await _controller.delete(stuff);
    _initialize();
    SnackbarHelper.showDeleteMessage(
      context: context,
      message: '${stuff.description} excluído!',
      onPressed: () => _onDeleteUndo(stuff),
    );
  }

  _onDeleteUndo(StuffModel stuff) async {
    await _controller.undo(stuff);
    _initialize();
  }
}
