import 'package:flutter/material.dart';

class MyNotesPage extends StatefulWidget {
  const MyNotesPage({super.key});

  @override
  State<MyNotesPage> createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  late ScrollController _scrollController;
//----------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          // _textColor = _isSliverAppBarExpanded ? Colors.white : Colors.blue;
        });
      });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.95),
            foregroundColor: Colors.white.withOpacity(0.95),
            title: _isSliverAppBarExpanded
                ? const Text('My Notes', style: TextStyle(color: Colors.black))
                : null,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.blue,
                ),
                onPressed: () {
                  // Add your settings action here
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                margin: const EdgeInsets.only(top: 40),
                color: Colors.grey.withOpacity(0.1),
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      if (!_isSliverAppBarExpanded)
                        const Text('My Notes',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 28)),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          hintText: 'Search your notes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Add your other Sliver widgets here
          const SliverFillRemaining(
            child: Center(
              child: Text('Your Notes Content Here'),
            ),
          ),
        ],
      ),
    );
  }
}
