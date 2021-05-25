import 'package:brasil_fields/brasil_fields.dart';
import 'package:controle_itens/helpers/validator_helper.dart';
import 'package:flutter/material.dart';
import 'package:controle_itens/controllers/detail_controller.dart';
import 'package:controle_itens/core/app_const.dart';
import 'package:controle_itens/helpers/snackbar_helper.dart';

import 'package:controle_itens/models/stuff_model.dart';
import 'package:controle_itens/repositories/stuff_repository_impl.dart';
import 'package:controle_itens/widgets/date_input_field.dart';
import 'package:controle_itens/widgets/loading_dialog.dart';
import 'package:controle_itens/widgets/photo_input_area.dart';
import 'package:controle_itens/widgets/primary_button.dart';

import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  final StuffModel stuff;

  const DetailPage({
    Key key,
    this.stuff,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = DetailController(StuffRepositoryImpl());

  @override
  void initState() {
    _controller.setId(widget.stuff?.id);
    _controller.setPhoto(widget.stuff?.photoPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stuff == null ? kTitleNewLoad : kTitleDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: _buildForm(),
      ),
    );
  }

  _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PhotoInputArea(
            initialValue: widget.stuff?.photoPath ?? '',
            onChanged: _controller.setPhoto,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: kLabelDescription,
                icon: Icon(Icons.description_outlined, color:Color.alphaBlend(Colors.transparent, Colors.deepPurple[200]))
                ),
            initialValue: widget.stuff?.description ?? '',
            onSaved: _controller.setDescription,
            validator: (text) => ValidatorHelper.isNotEmptyNumber(text),
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: kLabelName, 
                icon: Icon(Icons.person_outline, color:Color.alphaBlend(Colors.transparent, Colors.deepPurple[200]))),
            initialValue: widget.stuff?.contactName ?? '',
            onSaved: _controller.setName,
            validator: (text) => ValidatorHelper.isNotEmptyNumber(text),
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: kLabelTelefone, 
                icon: Icon(Icons.phone_android, color:Color.alphaBlend(Colors.transparent, Colors.deepPurple[200]))),
            keyboardType: TextInputType.number,
            initialValue: widget.stuff?.phoneNumber ?? '',
            onSaved: _controller.setPhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              TelefoneInputFormatter()
            ],
            validator: (text) =>
                ValidatorHelper.isNotEmptyNumber(text) ??
                ValidatorHelper.hasMinLength(text, 14),
          ),
          DateInputField(
            label: kLabelLoadDate,
            initialValue: widget.stuff?.date ?? '',
            onSaved: _controller.setDate,
          ),
          PrimaryButton(
            label: kButtonSave,
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }

  Future _onSave() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      LoadingDialog.show(
        context,
        message: widget.stuff == null ? 'Salvando...' : 'Atualizando...',
      );
      await _controller.save();
      LoadingDialog.hide();
      Navigator.of(context).pop();
      _onSuccessMessage();
    }
  }

  _onSuccessMessage() {
    if (widget.stuff == null) {
      SnackbarHelper.showCreateMessage(
        context: context,
        message: '${_controller.description} criado com sucesso!',
      );
    } else {
      SnackbarHelper.showUpdateMessage(
        context: context,
        message: '${_controller.description} atualizado com sucesso!',
      );
    }
  }
}
