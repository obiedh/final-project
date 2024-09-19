import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

List<String> _list = ['Dog', "Cat", "Mouse", 'Lion'];

class _DropDownState extends State<DropDown> {
  bool isStretchedDropDown = false;
  String title = 'Select Animals';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Custom Drop Down",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SafeArea(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isStretchedDropDown = !isStretchedDropDown;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffbbbbbb)),
                    borderRadius: BorderRadius.all(Radius.circular(27)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffbbbbbb)),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        constraints: BoxConstraints(
                          minHeight: 45,
                          minWidth: double.infinity,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text(
                                  title,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Icon(isStretchedDropDown
                                ? Icons.arrow_upward
                                : Icons.arrow_downward),
                          ],
                        ),
                      ),
                      if (isStretchedDropDown)
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 120,
                            minHeight: 0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffbbbbbb)),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(27)),
                          ),
                          child: ListView.builder(
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return RadioListTile(
                                title: Text(_list[index]),
                                value: _list[index],
                                groupValue: title,
                                onChanged: (val) {
                                  setState(() {
                                    title = val.toString();
                                    isStretchedDropDown = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
