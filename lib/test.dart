import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestScreen extends ConsumerWidget {
  TestScreen({super.key});

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> uploadData(WidgetRef ref)async {
    // Get the current user
    // final user = supabase.auth.currentUser;
    // final userState = ref.read(userViewModelProvider);

    // final data = await supabase
    // .from('users')
    // .select('name')
    // .eq('program_id', userState.user!.program_id);

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final slotState = ref.watch(slotsProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () async{
                  uploadData(ref);
                },
                child: Text(
                  "upsert data"
                )
            )
          ],
        ),
      ),
    );
  }
}
