import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/blocs/sign_in_bloc.dart';
import 'package:news_app/utils/icons.dart';
import 'package:provider/provider.dart';



  class BuildReadMarkIcon extends StatelessWidget {
    final String collectionName;
    final String? uid;
    final String? timestamp;

    const BuildReadMarkIcon({
      Key? key, 
      required this.collectionName, 
      required this.uid,
      required this.timestamp
      
      }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      final sb = context.watch<SignInBloc>();
      String _type = 'read marked items';
      if(sb.isSignedIn == false) return ReadMarkIcon().normal;
      return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, AsyncSnapshot snap) {
        if (uid == null) return ReadMarkIcon().normal;
        if (!snap.hasData) return ReadMarkIcon().normal;
        List d = [];
        try {
          d = snap.data[_type];
        } catch(e) {

        }

        if (d.isEmpty) return ReadMarkIcon().normal;

        if (d.contains(timestamp)) {
          return ReadMarkIcon().bold;
        } else {
          return ReadMarkIcon().normal;
        }
      },
    );
    }

    
  }
