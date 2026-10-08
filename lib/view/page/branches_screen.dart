// screens/branches_screen.dart
import 'package:flutter/material.dart';
import 'package:hatvest/model/branch.dart';
import 'package:hatvest/viewmodel/branches_viewmodel.dart';
import 'package:provider/provider.dart';


class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch branches when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BranchesViewModel>(context, listen: false).fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BranchesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (viewModel.errorMessage.isNotEmpty)
              Text(
                'Error: ${viewModel.errorMessage}',
                style: const TextStyle(color: Colors.red),
              )
            else ...[
              const Text('Select a branch:'),
              const SizedBox(height: 10),
              DropdownMenu<Branch>(
                width: MediaQuery.of(context).size.width - 32,
                initialSelection: viewModel.selectedBranch,
                onSelected: (Branch? branch) {
                  viewModel.selectBranch(branch);
                },
                dropdownMenuEntries: viewModel.branches
                    .map<DropdownMenuEntry<Branch>>((Branch branch) {
                  return DropdownMenuEntry<Branch>(
                    value: branch,
                    label: branch.name.isNotEmpty ? branch.name : 'Unnamed Branch',
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (viewModel.selectedBranch != null) ...[
                Text('Selected Branch: ${viewModel.selectedBranch!.name}'),
                Text('Address: ${viewModel.selectedBranch!.address}'),
                Text('Phone: ${viewModel.selectedBranch!.phone}'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}