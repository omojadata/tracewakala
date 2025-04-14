import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main.dart';
import 'models.dart';

class AgentListPage extends StatefulWidget {
  final User user;

  AgentListPage({
    required this.user,
  });

  @override
  _AgentListPageState createState() => _AgentListPageState();
}

class _AgentListPageState extends State<AgentListPage> {
  // Sample agent data
  // final Map<String, dynamic> agentData = {
  //   "AgentAccount": "01J7668357500",
  //   "AgentName": "A+ TRADERS",
  //   "Phone": "255753611646",
  //   "LOCATION": "BAGAMOYO",
  //   "ZONE": "BAGAMOYO",
  //   "CRDB SERVED": "SERVED",
  //   "TRACE SERVED": "Served",
  //   "CRDB ACTIVE": "",
  //   "TRACE ACTIVE": "Inactive",
  //   "STATUS": "",
  //   "GROUP": false,
  //   "GROUP NO": ""
  // };
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  final Dio _dio = Dio();
  List<AgentData> agents = [];
  late Future<List<AgentData>> filteredAgents;
  @override
  void initState() {
    super.initState();
    // _initializeGapi();
    // getData();
    // agents = await fetchAgents();
    filteredAgents = fetchAgents();
  }

  Future<List<AgentData>> fetchAgents() async {
    try {
      final response = await _dio
          .get('https://omojadata.pockethost.io/crdbbase/${widget.user.email}');
      // print("https://omojadata.pockethost.io/crdbbase/${widget.user.email}");
      if (response.statusCode == 200) {
        List<dynamic> jsonList = response.data;
        return jsonList.map((json) => AgentData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load agents');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  getData() async {
    try {
      agents = await fetchAgents();
      filteredAgents = Future.value(agents);
      // for (var agent in agents) {
      print(agents);
      // }
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  // final List<Map<String, dynamic>> agentsdata = [
  // {
  //     "AgentAccount": "01J7668357500",
  //     "AgentName": "A+ TRADERS",
  //     "Phone": "255718582169",
  //     "Location": "BAGAMOYO",
  //     "Zone": "BAGAMOYO",
  //     "IsToActive": true,
  //     "CrdbServed": "Unserved",
  //     "TraceServed": "Served",
  //     "CrdbActive": "Active",
  //     "TraceActive": "Active",
  //     "TraceStatus": "Mbovu",
  //     "TraceComment": "",
  //     "Group": false,
  //     "TraceGroupNo": "0714373728"
  //   },
  //   {
  //     "AgentAccount": "01J7245850704",
  //     "AgentName": "AABDULAZIZ MOHAMED LIGUO",
  //     "Phone": "255718583000",
  //     "Location": "BAGAMOYO",
  //     "Zone": "CHALINZE",
  //     "IsToActive": false,
  //     "CrdbServed": "Served",
  //     "TraceServed": "Unserved",
  //     "CrdbActive": "Inactive",
  //     "TraceActive": "Inactive",
  //     "TraceStatus": "Mbovu",
  //     "TraceComment": "",
  //     "Group": false,
  //     "TraceGroupNo": "0714373728"
  //   }
  // ];

  String? selectedCrdbActive;
  String? selectedTraceActive;
  String? selectedTraceServed;
  String? selectedCrdbServed;
  String? selectedStatus;
  String query = "";
  TextEditingController _searchController = TextEditingController();

  changeData() {
    setState(() {
      filteredAgents = Future.value(agents.where((agent) {
        return (selectedStatus == null ||
                agent.traceStatus == selectedStatus) &&
            (selectedCrdbActive == null ||
                agent.crdbActive == selectedCrdbActive) &&
            (selectedTraceActive == null ||
                agent.traceActive == selectedTraceActive &&
                    agent.isToActive == true) &&
            (selectedTraceServed == null ||
                agent.traceServed == selectedTraceServed) &&
            (selectedCrdbServed == null ||
                agent.crdbServed == selectedCrdbServed) &&
            (query.isEmpty ||
                agent.agentAccount.contains(query) ||
                agent.agentName.toLowerCase().contains(query.toLowerCase()));
      }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    // void _searchAgents(String query) {
    //   if (query.isEmpty) {
    //     setState(() {
    //       searchAgents = filteredAgents;
    //     });
    //   } else {
    //     setState(() {
    //       _filteredAgents = _agents
    //           .where((agent) =>
    //       agent.agentAccount.toLowerCase().contains(query.toLowerCase()) ||
    //           agent.agentName.toLowerCase().contains(query.toLowerCase()))
    //           .toList();
    //     });
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text("CRDB BASE"),
      ),
      body: FutureBuilder<List<AgentData>>(
          future: filteredAgents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;

            return Column(children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (value) {
                          // setState(() {
                          query = value;
                          // });
                          changeData();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return StatefulBuilder(
                                builder: (stfContext, stfSetState) {
                              // The .sw comes from flutter screen utils package... similar
                              // to mediaquery height and width
                              return AlertDialog(
                                title: Text("Filter Options"),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      // _buildDropdown(selectedCrdbActive,"CrdbActive", ['All','Active', 'Inactive'], (value) {
                                      //   if(value=="All"){
                                      //     setState(() {
                                      //       selectedCrdbActive = null;
                                      //     });
                                      //   }else{
                                      //     setState(() {
                                      //       selectedCrdbActive = value;
                                      //     });
                                      //   }
                                      // }),
                                      _buildDropdown(selectedStatus, "Status", [
                                        'All',
                                        'Good/No Comment',
                                        'Hapatikani',
                                        'Hapokei',
                                        'Mbovu',
                                        'Hataki',
                                        'Kafunga(Mdaa Mfupi)',
                                        'Kaacha Uwakala',
                                        'Mbali'
                                      ], (value) {
                                        if (value == "All") {
                                          stfSetState(() {
                                            selectedStatus = null;
                                          });
                                          // setState(() {
                                          selectedStatus = null;
                                          // });
                                        } else {
                                          stfSetState(() {
                                            selectedStatus = value;
                                          });
                                          // setState(() {
                                          selectedStatus = value;
                                          // });
                                        }
                                        changeData();
                                      }),
                                      _buildDropdown(
                                          selectedTraceActive,
                                          "ACTIVE",
                                          ['All', 'Active', 'Inactive'],
                                          (value) {
                                        if (value == "All") {
                                          stfSetState(() {
                                            selectedTraceActive = null;
                                          });
                                          // setState(() {
                                          selectedTraceActive = null;
                                          // });
                                        } else {
                                          stfSetState(() {
                                            selectedTraceActive = value;
                                          });
                                          // setState(() {
                                          selectedTraceActive = value;
                                          // });
                                        }
                                        changeData();
                                      }),
                                      _buildDropdown(
                                          selectedTraceServed,
                                          "Serve",
                                          ['All', 'Served', 'Unserved'],
                                          (value) {
                                        if (value == "All") {
                                          stfSetState(() {
                                            selectedTraceServed = null;
                                          });
                                          // setState(() {
                                          selectedTraceServed = null;
                                          // });
                                        } else {
                                          stfSetState(() {
                                            selectedTraceServed = value;
                                          });
                                          // setState(() {
                                          selectedTraceServed = value;
                                          // });
                                        }
                                        changeData();
                                      }),
                                      // _buildDropdown(selectedCrdbServed,"CrdbServed", ['All','Served', 'Unserved'], (value) {
                                      //   if(value=="All"){
                                      //     setState(() {
                                      //       selectedCrdbServed = null;
                                      //     });
                                      //   }else{
                                      //     setState(() {
                                      //       selectedCrdbServed = value;
                                      //     });
                                      //   }
                                      // }),
                                    ],
                                  ),
                                ),
                                actions: [],
                              );
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       labelText: "Search",
              //       border: OutlineInputBorder(),
              //     ),
              //     onChanged: (value) {
              //       setState(() {
              //         query = value;
              //       });
              //     },
              //   ),
              // ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final agent = data[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title:
                            Text("${agent.agentName}\n${agent.agentAccount}"),
                        subtitle: Text(
                            "${agent.zone}\n ${agent.traceServed} -- ${agent.isToActive ? agent.traceActive : ""}"),
                        leading: IconButton(
                          icon: Icon(Icons.phone),
                          onPressed:
                              () {}, // Implement call functionality if needed
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditModal(context, agent),
                        ),
                        // onTap: () =>
                        //     _showEditModal(context, filteredAgents[index]),
                      ),
                    );
                  },
                ),
              )
            ]);
          }
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // Show the EditAgentPage as a popup dialog
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: Text("Edit Agent"),
          //             content: EditAgentPage(agentData: agentData),
          //           );
          //         },
          //       );
          //     },
          //     child: Text("Open Edit Agent Modal"),
          //   ),
          ),
    );
  }

  Widget _buildDropdown(String? values, String label, List<String> options,
      ValueChanged<String?> onChanged) {
    return Column(
      children: [
        Text(label),
        DropdownButton<String>(
          // decoration: InputDecoration(labelText: "Trace Status"),

          hint: Text(values ?? "All"),
          value: options.contains(label) ? label : null,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        )
      ],
    );
  }

  void _showFilterDialog() {}

  void _showEditModal(BuildContext context, AgentData agentData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Agent"),
          content: EditAgentPage(agentData: agentData),
        );
      },
    );
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (context) => EditAgentPage(agentData: agentData),
    // );
  }
}

class EditAgentPage extends StatefulWidget {
  final AgentData agentData;

  const EditAgentPage({Key? key, required this.agentData}) : super(key: key);

  @override
  _EditAgentPageState createState() => _EditAgentPageState();
}

class _EditAgentPageState extends State<EditAgentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _traceCommentController;
  late TextEditingController _traceGroupNoController;
  bool isLoading = false;

  bool _groupChecked = false;
  String _traceActive = '';
  String _traceStatus = '';
  String _traceServed = '';
  String _zone = '';

  final List<String> _dropdownServedOptions = ['Served', 'Unserved'];
  final List<String> _dropdownActiveOptions = ['Active', 'Inactive'];
  final List<String> _dropdownZoneOptions = [
    'BAGAMOYO',
    'CHALINZE',
    'IKWIRIRI',
    'KIBAHA',
    'MAFIA',
    'MLANDIZI',
    'OUTZONE'
  ];

  final List<String> _dropdownStatusOptions = [
    'Good/No Comment',
    'Hapatikani',
    'Hapokei',
    'Mbovu',
    'Hataki',
    'Kafunga(Mdaa Mfupi)',
    'Kaacha Uwakala',
    'Mbali'
  ];

  @override
  void initState() {
    super.initState();
    _traceCommentController =
        TextEditingController(text: widget.agentData.traceComment);
    _traceGroupNoController =
        TextEditingController(text: widget.agentData.traceGroupNo);
    _groupChecked = widget.agentData.group;
    _traceActive = widget.agentData.traceActive;
    _traceServed = widget.agentData.traceServed;
    _traceStatus = widget.agentData.traceStatus;
    _zone = widget.agentData.zone;
  }

  @override
  void dispose() {
    _traceCommentController.dispose();
    _traceGroupNoController.dispose();

    super.dispose();
  }

  Future<Response> postData(String url, Map<String, dynamic> data) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Adjust headers as needed
            //'Authorization': 'Bearer YOUR_TOKEN', // Example: Authorization header
          },
        ),
      );
      return response; // Return the full response
    } on DioException catch (e) {
      // Handle Dio errors specifically
      print('Dio error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      } else {
        print('Request failed: ${e.requestOptions}');
      }
      rethrow; // Rethrow to allow the calling function to handle the error
    } catch (e) {
      // Handle other errors
      print('General error: $e');
      rethrow;
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedAgent = AgentData(
        agentAccount: widget.agentData.agentAccount,
        agentName: widget.agentData.agentName,
        phone: widget.agentData.phone,
        location: widget.agentData.location,
        zone: _zone,
        isToActive: widget.agentData.isToActive,
        crdbServed: widget.agentData.crdbServed,
        traceServed: _traceServed,
        crdbActive: widget.agentData.crdbActive,
        traceActive: _traceActive,
        traceStatus: _traceStatus,
        traceComment: _traceCommentController.text,
        group: _groupChecked,
        traceGroupNo: _traceGroupNoController.text,
      );

      try {
        final response = await postData(
            'https://omojadata.pockethost.io/crdbbaseupdate',
            updatedAgent.toJson());
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agent Updated Successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update agent: $e')),
        );
      }
    }
  }

  // Future<List<Map<String, dynamic>>> fetchAgents() async {
  //   try {
  //     final response = await _dio.get('https://omojadata.pockethost.io/crdbbase/${widget.user.email}');
  //     // print("https://omojadata.pockethost.io/crdbbase/${widget.user.email}");
  //     if (response.statusCode == 200) {
  //       List<Map<String, dynamic>> agents =
  //       List<Map<String, dynamic>>.from(response.data);
  //       return agents;
  //     } else {
  //       throw Exception('Failed to load agents');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching data: $e');
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _traceStatus,
              decoration: InputDecoration(labelText: "Trace Status"),
              items: _dropdownStatusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _traceStatus = newValue!;
                });
              },
            ),
            // TextFormField(
            //   controller: _traceCommentController,
            //   maxLines: 3,
            //   decoration: InputDecoration(border: OutlineInputBorder()),
            // ),
            SizedBox(height: 16),
            Text("Comment"),
            TextFormField(
              controller: _traceCommentController,
              maxLines: 2,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _zone,
              decoration: InputDecoration(labelText: "Zone"),
              items: _dropdownZoneOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _zone = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: CheckboxListTile(
                title: Text("Is In Group"),
                value: _groupChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _groupChecked = value ?? false;
                  });
                },
              )),
              Expanded(
                child: Column(
                  children: [
                    Text("Group Number"),
                    TextFormField(
                      controller: _traceGroupNoController,
                      maxLines: 1,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    )
                  ],
                ),
              ),
            ]),
            SizedBox(height: 16),
            // Row for the two Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _traceActive,
                    decoration: InputDecoration(labelText: "Trace Active"),
                    items: _dropdownActiveOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _traceActive = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16), // Space between the dropdowns
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _traceServed,
                    decoration: InputDecoration(labelText: "Trace Served"),
                    items: _dropdownServedOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _traceServed = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        await _saveForm();
                        setState(() {
                          isLoading = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
