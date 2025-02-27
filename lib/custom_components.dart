import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchableAppBar({super.key});

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _searchActivated = false;
  bool _searchEmpty = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = "";
    _searchEmpty = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchActivated) {
      return AppBar(
        leading: BackButton(
          onPressed: () {
            setState(() {
              _searchActivated = false;
            });
          },
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          // TODO: maybe better font
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(color: Colors.white),
          ),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search in titles',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          onChanged: (value) {
            setState(() {
              _searchEmpty = value.isEmpty;
            });
          },
          onSubmitted: (value) {
            // TODO: search
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions:
            _searchEmpty
                ? []
                : [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {
                      setState(() {
                        _controller.text = "";
                        _searchEmpty = true;
                      });
                    },
                  ),
                ],
      );
    }
    // Default app bar - search is not activated
    return AppBar(
      title: Text(
        'NotedOK',
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              _searchActivated = true;
            });
          },
        ),
      ],
    );
  }
}
