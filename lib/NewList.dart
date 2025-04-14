import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class AccountListPage extends StatefulWidget {
  final User user;

  AccountListPage({
    required this.user,
  });

  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  List<Account> accounts = [
    // Account(
    //   idNo: "1234567890",
    //   accountName: "IDDI ATHUMANI MDUKA",
    //   zone: "CHALINZE",
    //   dateSubmit: "18-02-2025",
    //   dateUpdate: "18-02-2025",
    //   fingerprint: true,
    //   contract: true,
    //   accountCreated: false,
    //   accountActivation: false,
    //   accountNumber: "01J7000KNJF00",
    // ),
  ];
  late Future<List<Account>> filteredAccounts;
  final Dio _dio = Dio();
  // List<Account> filteredAccounts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _initializeGapi();
    // getData();
    // agents = await fetchAgents();
    filteredAccounts = fetchAccounts();
  }

  Future<List<Account>> fetchAccounts() async {
    try {
      final response = await _dio.get(
          'https://omojadata.pockethost.io/crdbrecruitment/${widget.user.email}');
      // print("https://omojadata.pockethost.io/crdbbase/${widget.user.email}");
      if (response.statusCode == 200) {
        List<dynamic> jsonList = response.data;
        return jsonList.map((json) => Account.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load agents');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  getData() async {
    try {
      accounts = await fetchAccounts();
      filteredAccounts = Future.value(accounts);
      // for (var agent in agents) {
      print(accounts);
      // }
    } catch (e) {
      print(e);
    }
  }

  void filterSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredAccounts = Future.value(accounts.where((account) {
        return account.accountName.toLowerCase().contains(lowerQuery);
      }).toList());
    });
  }

  void showAccountDialog({Account? account, int? index}) {
    final nameController =
        TextEditingController(text: account?.accountName ?? '');
    final zoneController = TextEditingController(text: account?.zone ?? '');
    final dateController =
        TextEditingController(text: account?.dateSubmit ?? '');
    final numberController =
        TextEditingController(text: account?.accountNumber ?? '');
    final phoneController =
        TextEditingController(text: account?.phone.toString() ?? '');
    bool fingerPrint = account?.fingerPrint ?? false;
    bool contract = account?.contract ?? false;
    bool created = account?.accountCreated ?? false;
    bool activated = account?.accountActivation ?? false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(account == null ? 'Add Account' : 'Edit Account'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Account Name')),
                  TextField(
                      controller: zoneController,
                      decoration: InputDecoration(labelText: 'Zone')),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Date Submit'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                        setState(() {
                          dateController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  TextField(
                      controller: numberController,
                      decoration: InputDecoration(labelText: 'Account Number')),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  CheckboxListTile(
                    value: fingerPrint,
                    title: Text("Fingerprint"),
                    onChanged: (val) => setState(() => fingerPrint = val!),
                  ),
                  CheckboxListTile(
                    value: contract,
                    title: Text("Contract"),
                    onChanged: (val) => setState(() => contract = val!),
                  ),
                  CheckboxListTile(
                    value: created,
                    title: Text("Account Created"),
                    onChanged: (val) => setState(() => created = val!),
                  ),
                  CheckboxListTile(
                    value: activated,
                    title: Text("Account Activation"),
                    onChanged: (val) => setState(() => activated = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: isLoading ? CircularProgressIndicator() : Text("Save"),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        final newAccount = Account(
                          idNo: account != null ? account.idNo : 0,
                          accountName: nameController.text,
                          zone: zoneController.text,
                          dateSubmit: dateController.text,
                          fingerPrint: fingerPrint,
                          contract: contract,
                          accountCreated: created,
                          accountActivation: activated,
                          accountNumber: numberController.text,
                          phone: int.tryParse(phoneController.text) ?? 0,
                        );

                        if (account == null) {
                          await postData(
                              'https://omojadata.pockethost.io/crdbrecruitmentinsert',
                              newAccount.toJson());
                        } else if (index != null) {
                          await postData(
                              'https://omojadata.pockethost.io/crdbrecruitmentupdate',
                              newAccount.toJson());
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  postData(String url, Map<String, dynamic> data) async {
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
      if (response.statusCode == 200) {
        setState(() {
          filteredAccounts = fetchAccounts();
        });
        print(response.data);
        print(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agent Updated Successfully')),
        );
        Navigator.of(context).pop();
      }
      // return response; // Return the full response
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update agent: $e')),
      );
      // Handle Dio errors specifically
      // print('Dio error: ${e.message}');
      // if (e.response != null) {
      //   print('Response data: ${e.response?.data}');
      //   print('Response status: ${e.response?.statusCode}');
      // } else {
      //   print('Request failed: ${e.requestOptions}');
      // }
      // rethrow; // Rethrow to allow the calling function to handle the error
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update agent: $e')),
      );
      // Handle other errors
      // print('General error: $e');
      // rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Manager"),
      ),
      body: FutureBuilder<List<Account>>(
        future: filteredAccounts,
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: filterSearch,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final account = data[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                            "${account.accountName}\nAccount Number - ${account.accountNumber}"),
                        subtitle: Text(
                            "Created - ${account.accountCreated}\nActivated - ${account.accountActivation}"),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              showAccountDialog(account: account, index: index),
                        ),
                        // onTap: () =>
                        //     _showEditModal(context, filteredAgents[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showAccountDialog(),
      ),
    );
  }
}
