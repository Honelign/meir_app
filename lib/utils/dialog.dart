


import 'package:flutter/material.dart';

void openDialog (context, title, message){
  showDialog(
    context: context,
    
    builder: (BuildContext context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22.0))),
        content: Text(message),
        title: Text(title),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('OK'))
        ],

      );
    }
    
    );
}